function __devbox_await_state --argument-names instance_id want
	while true
		set -l state (aws ec2 describe-instances --instance-id $instance_id | jq -r ".Reservations[0].Instances[0].State.Name")
		if [ $state = $want ]
			return 0
		end
		echo "Waiting for instance to be $want; got: $state"
		sleep 1
	end
end

function devbox --description 'manage AWS devbox' --argument-names action
	set -x AWS_PROFILE sandbox-cloud
	set -x AWS_REGION us-east-2
	set -l instance_name "chrisseto-devbox"

	set -l instance_id (aws ec2 describe-instances --filters Name=tag:Name,Values="$instance_name" | jq -r ".Reservations[0].Instances[0].InstanceId")
	or begin
		echo "Instance $instance_name not found"
	end

	switch $action
		case 'start'
			aws ec2 start-instances --instance-id $instance_id

			__devbox_await_state $instance_id "running"

		case 'stop'
			aws ec2 stop-instances --instance-id $instance_id

			__devbox_await_state $instance_id "stopped"

		case 'port-forward'
			aws ssm start-session --target $instance_id --document-name AWS-StartPortForwardingSession --parameters "portNumber"=["8770"],"localPortNumber"=["8770"]

		case '*'
			echo "unknown action: $action"
			exit 1
	end
end
