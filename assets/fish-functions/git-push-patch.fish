# function git-push-patch -d "git-push-patch pushes a stacked git patch to a branch on the given remote"
# 	argparse -n "git-push-patch" -N 2 --ignore-unknown -- $argv
# 	or return
#
# 	set -l remote $argv[1]
# 	set -l patch $argv[2]
# 	set -l branch (git branch --show-current)
# 	set -l prefix "chris/p"
#
# 	# Remove remote and patch from the $argv so we can pass extra flags to
# 	# git-push.
# 	set -e argv[1]
# 	set -e argv[1]
#
# 	echo "git push $remote refs/patches/$branch/$patch:refs/heads/$prefix/$patch $argv"
# end
#
