#!/usr/bin/env bash
# Open a new WezTerm pane/tab/window in this Claude session's working directory.
#
# Usage: open.sh [right|bottom|tab|window] [percent] [dir]
#
# Positional args are all optional and order-independent-ish: the first arg that
# matches a known placement wins, the first bare number is the split percentage,
# and anything else is treated as the target directory (default: $PWD).
set -euo pipefail

input=$(cat)
args=$(jq -r '.command_args' <<<"$input")

placement=bottom
percent=
dir=

for arg in "$args"; do
	case "$arg" in
	right | left | bottom | top | tab | window) placement="$arg" ;;
	[0-9] | [0-9][0-9] | 100) percent="$arg" ;;
	*) dir="$arg" ;;
	esac
done

# --cwd wants an absolute path; wezterm does not expand ~ or resolve relatives.
dir="${dir:-$PWD}"
dir="${dir/#\~/$HOME}"
case "$dir" in
/*) ;;
*) dir="$PWD/$dir" ;;
esac

if [[ ! -d $dir ]]; then
	echo "open: no such directory: $dir" >&2
	exit 1
fi

if [[ -z ${WEZTERM_PANE:-} ]]; then
	echo "open: not running under WezTerm (WEZTERM_PANE is unset)" >&2
	exit 1
fi

# Omitting --pane-id makes wezterm target $WEZTERM_PANE, i.e. this session's pane,
# which is what keeps the new pane in the same tab and window.
case "$placement" in
tab) set -- spawn ;;
window) set -- spawn --new-window ;;
*) set -- split-pane "--$placement" ${percent:+--percent "$percent"} ;;
esac

pane=$(wezterm cli "$@" --cwd "$dir")

# Block the expansion so Claude never sees it
echo '{"decision": "block", "reason": "Opened '"$dir"'"}'
exit 0
