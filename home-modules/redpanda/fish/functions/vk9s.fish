function vk9s
	set -l vclus (vcluster list --output json | jq -r '.[] | .Name' | fzf)
	vcluster connect -n $vclus $vclus -- k9s -A
end
