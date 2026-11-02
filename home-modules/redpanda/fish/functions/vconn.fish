function vconn
	set -l vclus (vcluster list --output json | jq -r '.[] | .Name' | fzf)
	vcluster connect -n $vclus $vclus -- $SHELL
end
