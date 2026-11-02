function devbox-ssh-proxy --description 'ssh ProxyCommand: log in, start the devbox, tunnel over SSM' --argument-names profile region instance_id port
	# NB: stdout is the ssh stream; everything else must go to stderr.
	set -lx AWS_PROFILE $profile
	set -lx AWS_REGION $region

	if not aws sts get-caller-identity >/dev/null 2>&1
		aws sso login </dev/null >&2
		or return 1
	end

	set -l state (aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].State.Name' --output text)
	or return 1

	switch $state
		case running
		case pending
			echo "devbox: waiting for $instance_id to be running" >&2
			aws ec2 wait instance-running --instance-ids $instance_id >&2
			or return 1
		case stopping stopped
			if test $state = stopping
				echo "devbox: waiting for $instance_id to stop" >&2
				aws ec2 wait instance-stopped --instance-ids $instance_id >&2
				or return 1
			end
			echo "devbox: starting $instance_id" >&2
			aws ec2 start-instances --instance-ids $instance_id >/dev/null
			or return 1
			aws ec2 wait instance-running --instance-ids $instance_id >&2
			or return 1
		case '*'
			echo "devbox: $instance_id is $state" >&2
			return 1
	end

	# NB: "running" precedes the agent registering; start-session fails with
	# TargetNotConnected until it does.
	while test (aws ssm describe-instance-information --filters Key=InstanceIds,Values=$instance_id --query 'InstanceInformationList[0].PingStatus' --output text) != Online
		echo "devbox: waiting for SSM agent on $instance_id" >&2
		sleep 2
	end

	exec aws ssm start-session --target $instance_id --document-name AWS-StartSSHSession --parameters portNumber=$port
end
