function ccd --description "cd into a claude-code session's work tree"
	set -l agents "$(claude agents --cwd (pwd) --json)"

	set -l dir (echo "$agents" | jq -r '.[] | [.status, .name, .cwd] | @tsv' | fzf -d '\t' --with-nth='{1}: {2}' --accept-nth=3)

	if test -n "$dir"
		cd "$dir"
	end
end
