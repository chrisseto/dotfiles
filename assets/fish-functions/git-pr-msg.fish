function git-pr-msg
	set -l usage 'usage: git-pr-msg [FROM] [--target TARGET]'

    argparse 't/target=' -- $argv; or begin
		echo $usage >&2
		return 1
	end

	argparse --min-args 0 --max-args 1 -- $argv; or begin
		echo $usage >&2
		return 1
	end

	if set -q _flag_target[1]
		set target $_flag_target[1]
	else 
		set target origin/(git remote show origin | rg -or '$1' 'HEAD branch: ([\S]+)')
	end

	set base HEAD
	if test (count $argv) -eq 1
		set base $argv[1]
	end

	set -l forkpoint (git merge-base --fork-point $target $base)

	git log "$base...$forkpoint" --pretty=format:"**%s**%n%b"
end
