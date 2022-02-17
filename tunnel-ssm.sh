if [[ "$1" == "" ]];then
	echo "must pass name from EC2 Name tag or instance id" && exit
fi
# find the instance ID based on Tag Name
if [[ $1 != "i-"* ]];then
    INSTANCE_ID=$(aws ec2 describe-instances \
               --filter "Name=tag:Name,Values=$1" \
               --query "Reservations[].Instances[?State.Name == 'running'].InstanceId[]" \
               --output text)
else
    INSTANCE_ID=`echo $1`
fi

if [[ "$INSTANCE_ID" == "i-"* ]]; then
echo "Instance=$INSTANCE_ID"
# create the port forwarding tunnel
aws ssm start-session --target $INSTANCE_ID \
                       --document-name AWS-StartPortForwardingSession \
                       --parameters '{"portNumber":["3389"],"localPortNumber":["9999"]}' &
echo "Use localhost:9999"
else
    echo "Did not find Instance ID"
fi
