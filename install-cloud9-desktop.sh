#!/bin/bash

set +x
cd ~/environment
sudo yum install -q -y wget smartmontools deltarpm jq nmap
sudo yum reinstall python3-pip -y
# Increase the disk size to 32GB
# ------  resize OS disk -----------

# Specify the desired volume size in GiB as a command-line argument. If not specified, default to 20 GiB.
VOLUME_SIZE=${1:-32}

# Get the ID of the environment host Amazon EC2 instance.
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data//instance-id)

# Get the ID of the Amazon EBS volume associated with the instance.
VOLUME_ID=$(aws ec2 describe-instances \
  --instance-id $INSTANCE_ID \
  --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" \
  --output text)

# Resize the EBS volume.
aws ec2 modify-volume --volume-id $VOLUME_ID --size $VOLUME_SIZE

# Wait for the resize to finish.
while [ \
  "$(aws ec2 describe-volumes-modifications \
    --volume-id $VOLUME_ID \
    --filters Name=modification-state,Values="optimizing","completed" \
    --query "length(VolumesModifications)"\
    --output text)" != "1" ]; do
sleep 1
done

$(readlink -f /dev/xvda) 2> /dev/null
if [[ $? -eq 0 ]];then
  # Rewrite the partition table so that the partition takes up all the space that it can.
  sudo growpart /dev/xvda 1
 
  # Expand the size of the file system.
  sudo resize2fs /dev/xvda1

else
  # Rewrite the partition table so that the partition takes up all the space that it can.
  sudo growpart /dev/nvme0n1 1

  # Expand the size of the file system.
  # sudo resize2fs /dev/nvme0n1p1 #(Amazon Linux 1)
  sudo xfs_growfs /dev/nvme0n1p1 #(Amazon Linux 2)
fi

echo "Install aws cli v2"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -qq awscliv2.zip
sudo ./aws/install
rm -f awscliv2.zip

date
echo "======= X11 mate desktop install ..."
sudo amazon-linux-extras install -y mate-desktop1.x > /dev/null

sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -q

sudo systemctl set-default graphical.target
echo "======= xrdp"
sudo yum -y install xrdp tigervnc-server -q 2> /dev/null
#yum -y install xrdp
sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo netstat -antup | grep 3389

echo "X11 stuff again ......"
sudo amazon-linux-extras install -y mate-desktop1.x
echo "PREFERRED=/usr/bin/mate-session" | sudo tee -a /etc/sysconfig/desktop

echo "Install chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -q
sudo yum install google-chrome-stable_current_*.rpm -y -q 
echo "Install DBeaver"
wget https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm -q
sudo yum install dbeaver-ce-latest-stable.x86_64.rpm  -y -q 2> /dev/null
echo "Install Lens"
wget https://api.k8slens.dev/binaries/Lens-5.3.4-latest.20220120.1.x86_64.rpm -q
sudo yum  install Lens-5.3.4-latest.20220120.1.x86_64.rpm  -y -q 2> /dev/null
echo "Install VS Code"
wget -O vscode.rpm https://go.microsoft.com/fwlink/?LinkID=760867 -q
sudo yum install vscode.rpm  -y -q 2> /dev/null
sudo cat /etc/sysconfig/desktop
pw=$(date | base64 | head -c${1:-32};echo;)
echo $pw > /home/ec2-user/.ec2user-creds && chmod 600 /home/ec2-user/.ec2user-creds
sudo chown ec2-user /home/ec2-user/.ec2user-creds
echo -e "${pw}\n${pw}" | sudo passwd ec2-user
echo "ec2-user password: $pw   (also stored in /home/ec2-user/.ec2user-creds)"
echo "Instance ID = $INSTANCE_ID"