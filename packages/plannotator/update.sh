#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq nix gnused coreutils
# Bump plannotator (and the sem sidecar it ships with) to the latest release,
# or to the version given as $1. Mirrors nixpkgs' update.sh convention:
#
#   ./update.sh            # latest release
#   ./update.sh 0.28.43    # specific version
#
# Writes sources.json next to this script and ../sem/sources.json.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

REPO="backnotprop/plannotator"
SEM_REPO="Ataraxy-Labs/sem"

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

# sem: follow the version and checksums upstream's own installer pins for
# this tag, so we never pair plannotator with a sem it wasn't released with.
install_sh=$(curl_gh "https://raw.githubusercontent.com/$REPO/$tag/scripts/install.sh")
sem_version=$(sed -n 's/^SEM_VERSION="v\{0,1\}\([^"]*\)"$/\1/p' <<<"$install_sh" | head -n1)
[ -n "$sem_version" ] || { echo "could not find SEM_VERSION in install.sh for $tag" >&2; exit 1; }

declare -A sem_assets=(
    [aarch64-darwin]=sem-darwin-arm64.tar.gz
    [aarch64-linux]=sem-linux-arm64.tar.gz
    [x86_64-linux]=sem-linux-x86_64.tar.gz
)
sem='{}'
for system in "${!sem_assets[@]}"; do
    asset="${sem_assets[$system]}"
    hex=$(sed -n "s/^[[:space:]]*${asset//./\\.})[[:space:]]*echo \"\([0-9a-f]\{64\}\)\".*/\1/p" <<<"$install_sh" | head -n1)
    if [ -z "$hex" ]; then
        # Not pinned upstream (e.g. a newly added platform): hash the asset.
        echo "  $asset: no pinned checksum in install.sh, prefetching" >&2
        # nix-prefetch-url prints nix32, which to_sri also accepts.
        hex=$(nix-prefetch-url --type sha256 \
            "https://github.com/$SEM_REPO/releases/download/v$sem_version/$asset" 2>/dev/null)
    fi
    sem=$(jq --arg s "$system" --arg a "$asset" --arg h "$(to_sri "$hex")" \
        '.[$s] = {asset: $a, hash: $h}' <<<"$sem")
done

jq -nS --arg v "$version" --argjson b "$binaries" \
    '{version: $v, binaries: $b}' >sources.json.tmp
mv sources.json.tmp sources.json
echo "Wrote $(realpath sources.json)"

jq -nS --arg v "$sem_version" --argjson a "$sem" \
    '{version: $v, archives: $a}' >../sem/sources.json.tmp
mv ../sem/sources.json.tmp ../sem/sources.json
echo "Wrote $(realpath ../sem/sources.json) (sem $sem_version)"

