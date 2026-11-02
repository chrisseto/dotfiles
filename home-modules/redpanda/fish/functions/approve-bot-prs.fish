function approve-bot-prs
	set -l bot_prs "$(gh pr list --app github-actions -a @me --json number,url,title,autoMergeRequest,reviews)"

	# Approve any unreviewed.
	echo "$bot_prs" | jq -c '.[] | select(.reviews | length == 0)' | while read -l pr
		set -l url (echo "$pr" | jq -r .url)
		set -l title (echo "$pr" | jq -r .title)
		set -l number (echo "$pr" | jq -r .number)

		# TODO pretty print Link + URL.
		gh pr review --approve "$number"
	end

	# Enable auto merge for any not already enabled.
	echo "$bot_prs" | jq -c '.[] | select(.autoMergeRequest == null)' | while read -l pr
		set -l url (echo "$pr" | jq -r .url)
		set -l title (echo "$pr" | jq -r .title)
		set -l number (echo "$pr" | jq -r .number)

		# TODO pretty print Link + URL.
		gh pr merge --auto --rebase "$number"
	end
end
