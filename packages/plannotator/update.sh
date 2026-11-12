#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq nix coreutils git
# Bump plannotator to the latest release, or to the version given as $1.
# Mirrors nixpkgs' update.sh convention:
#
#   ./update.sh            # latest release
#   ./update.sh 0.28.43    # specific version
#
# Writes sources.json next to this script.
set -euo pipefail

# Run from this package's directory in the git checkout. `nix-update -u`
# executes a read-only /nix/store copy of the flake, so map a store path
# back to the same relative path in the checkout of the current directory.
here=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
if [[ "$here" == /nix/store/* ]]; then
    here="$(git rev-parse --show-toplevel)/${here#/nix/store/*/}"
fi
cd "$here"

REPO="backnotprop/plannotator"

curl_gh() {
    local auth=()
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
    fi
    curl -fsSL "${auth[@]}" "$@"
}

to_sri() {
    nix --extra-experimental-features nix-command hash convert --hash-algo sha256 --to sri "$1"
}

if [ $# -gt 0 ]; then
    version="${1#v}"
else
    version=$(curl_gh "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name | ltrimstr("v")')
fi
tag="v$version"

current=$(jq -r '.version' sources.json 2>/dev/null || echo "")
if [ "$current" = "$version" ] && [ -z "${FORCE:-}" ]; then
    echo "plannotator is already at $version (set FORCE=1 to refresh hashes)"
    exit 0
fi
echo "Updating plannotator ${current:-<none>} -> $version"

# Release binaries: upstream publishes <asset>.sha256 next to each one.
declare -A plannotator_assets=(
    [aarch64-darwin]=plannotator-darwin-arm64
    [x86_64-darwin]=plannotator-darwin-x64
    [aarch64-linux]=plannotator-linux-arm64
    [x86_64-linux]=plannotator-linux-x64
)
binaries='{}'
for system in "${!plannotator_assets[@]}"; do
    asset="${plannotator_assets[$system]}"
    hex=$(curl_gh "https://github.com/$REPO/releases/download/$tag/$asset.sha256" | cut -d' ' -f1)
    binaries=$(jq --arg s "$system" --arg a "$asset" --arg h "$(to_sri "$hex")" \
        '.[$s] = {asset: $a, hash: $h}' <<<"$binaries")
done

jq -nS --arg v "$version" --argjson b "$binaries" \
    '{version: $v, binaries: $b}' >sources.json.tmp
mv sources.json.tmp sources.json
echo "Wrote $(realpath sources.json)"

