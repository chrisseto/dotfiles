#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq nix git
# Bump herdr-core to the latest release, or to the version given as $1:
#
#   ./update.sh            # latest release
#   ./update.sh 0.1.16     # specific version
#
# Reads the same release manifest install.sh does and writes sources.json.
set -euo pipefail

# Run from this package's directory in the git checkout. `nix-update -u`
# executes a read-only /nix/store copy of the flake, so map a store path
# back to the same relative path in the checkout of the current directory.
here=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
if [[ "$here" == /nix/store/* ]]; then
    here="$(git rev-parse --show-toplevel)/${here#/nix/store/*/}"
fi
cd "$here"

releases="${HERDR_RELEASES_URL:-https://releases.herdr.dev}"

if [ $# -gt 0 ]; then
    manifest_url="$releases/core/${1#v}/manifest.json"
else
    manifest_url="$releases/core/latest.json"
fi
manifest=$(curl -fsSL "$manifest_url")
version=$(jq -r .version <<<"$manifest")

current=$(jq -r .version sources.json 2>/dev/null || echo "")
if [ "$current" = "$version" ] && [ -z "${FORCE:-}" ]; then
    echo "herdr-core is already at $version (set FORCE=1 to refresh hashes)"
    exit 0
fi
echo "Updating herdr-core ${current:-<none>} -> $version"

# install.sh's "$os-$arch" target names -> nix systems.
jq -S --arg v "$version" '
    {
      "aarch64-darwin": "macos-aarch64",
      "x86_64-darwin":  "macos-x86_64",
      "aarch64-linux":  "linux-aarch64",
      "x86_64-linux":   "linux-x86_64"
    } as $systems
    | {
        version: $v,
        targets: ($systems | with_entries(
          .value as $t
          | ($manifest.targets[$t] // error("no build for \($t) in manifest")) as $e
          | .value = {url: $e.url, hash: $e.sha256}
        ))
      }' --argjson manifest "$manifest" -n >sources.json.tmp

# Convert the manifest's hex sha256 to SRI.
for system in $(jq -r '.targets | keys[]' sources.json.tmp); do
    hex=$(jq -r --arg s "$system" '.targets[$s].hash' sources.json.tmp)
    sri=$(nix --extra-experimental-features nix-command hash convert --hash-algo sha256 --to sri "$hex")
    jq -S --arg s "$system" --arg h "$sri" '.targets[$s].hash = $h' sources.json.tmp >sources.json.tmp2
    mv sources.json.tmp2 sources.json.tmp
done
mv sources.json.tmp sources.json
echo "Wrote sources.json"
