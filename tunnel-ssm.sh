if [[ "$1" == "" ]];then
	echo "must pass name from EC2 Name tag" && exit
fi
# find the instance ID based on Tag Name
INSTANCE_ID=$(aws --profile rds --region eu-west-2 ec2 describe-instances \
               --filter "Name=tag:Name,Values=$1" \
               --query "Reservations[].Instances[?State.Name == 'running'].InstanceId[]" \
               --output text)
echo "Instance=$INSTANCE_ID"
if [[ "$INSTANCE_ID" == "i-"* ]]; then
# create the port forwarding tunnel
aws --profile rds --region eu-west-2 ssm start-session --target $INSTANCE_ID \
                       --document-name AWS-StartPortForwardingSession \
                       --parameters '{"portNumber":["3389"],"localPortNumber":["9999"]}' &
fi
