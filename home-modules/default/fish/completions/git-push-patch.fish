# TODO It's unclear how to tell fish to respect completion of additional
# arguments. It seems likely that -n with something will do the trick but there
# doesn't seem to be a built in command for "Hey, how many arguments have been
# specified?"
complete -c git-push-patch -k -x -d "Patch" -a "(stg series -P --color never)"
complete -c git-push-patch -k -x -d "Remote" -a "(__fish_git_remotes)"

# See here for an example of a completion that checks # of args.
# https://github.com/asdf-vm/asdf/blob/ccdd47df9b73d0a22235eb06ad4c48eb57360832/completions/asdf.fish#L23-L26
