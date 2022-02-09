#!/bin/bash
set +x
cd ~/environment
sudo yum install -q -y wget smartmontools deltarpm jq nmap
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

if [ $(readlink -f /dev/xvda) = "/dev/xvda" ]
then
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



echo "aws cli"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -qq awscliv2.zip
./aws/install

date
echo "======= X11 mate "
sudo which  amazon-linux-extras
sudo amazon-linux-extras install -y mate-desktop1.x
sudo echo "PREFERRED=/usr/bin/mate-session" > /etc/sysconfig/desktop

sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sudo systemctl set-default graphical.target
echo "======= xrdp"
sudo yum -y install xrdp tigervnc-server
#yum -y install xrdp
sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo netstat -antup | grep xrdp

echo "X11 stuff again ......"
sudo amazon-linux-extras install -y mate-desktop1.x
sudo echo "PREFERRED=/usr/bin/mate-session" > /etc/sysconfig/desktop

echo "install chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -q
sudo yum install google-chrome-stable_current_*.rpm -y -q
echo "DB Beaver"
wget https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm -q
sudo yum install dbeaver-ce-latest-stable.x86_64.rpm  -y -q
echo "Lens"
wget https://api.k8slens.dev/binaries/Lens-5.3.4-latest.20220120.1.x86_64.rpm -q
sudo yum  install Lens-5.3.4-latest.20220120.1.x86_64.rpm  -y -q
#
echo "VS Code"
wget -O vscode.rpm https://go.microsoft.com/fwlink/?LinkID=760867 -q
sudo yum install vscode.rpm  -y -q

date
# /usr/bin/google-chrome-stable
echo "look in /usr/share/applications"
