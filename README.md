## Starting a Desktop on Cloud9

### 1. Create a Cloud9 environment

Use the options:
* `Create a new no-ingress EC2 instance for environment (access via Systems Manager)`

This ensures there is no inbound access to the Cloud9 instance

* Instance size `t3.small` (or larger)  
* Use `Amazon Linux 2` (required)

----

### 2. Install additional software on the Cloud9 IDE

**Clone the repo**

```bash
cd ~/environment
git clone https://github.com/awsandy/cloud9-tunnel-desktop.git
```

**Install the desktop software and some sample apps**

```bash
cd cloud9-tunnel-desktop
./install-cloud9-desktop.sh
```

This script:

* Installs the AWS cli (v2)
* Increases the root disk size to 32GB
* Installs the Amazon Linux 2 minimal Desktop software
* Installs some sample apps:
* * The Chrome browser 
* * DBeaver - an open source database management tools
* * Microsoft's Visual Studio Code IDE
* * LENS a tool for managing Kubernetes clusters (including EKS)
  
You may see some yum lock errors during the install of the sample apps, these should resolve themselves after seeing the error 3 or 4 times.


**Create a password for the user `ec2-user`.**

```bash
sudo passwd ec2-user
```

Enter a password twice ....

```
Changing password for user ec2-user.
New password: 
Retype new password: 
passwd: all authentication tokens updated successfully.
```

----

### 3. Check your permissions 

Ensure you have these permissions for your IAM user or role you use on your local machine:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ssm:StartSession",
                "ssm:TerminateSession",
                "ssm:ResumeSession",
                "ssm:DescribeSessions",
                "ssm:GetConnectionStatus"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
```

*Best Practice: reduce the scope of these permissions using a more specific resource and/or adding a condition clause.*

Note: IAM Permissions may take a few minutes to propagate. 


-----

### 3. Tunnel to your desktop from your local machine securely using SSM

Login to AWS using the AWS cli from your local machine

clone the repo to your local machine

```
git clone https://github.com/awsandy/cloud9-tunnel-desktop.git
```

Then use the helper script (bash) to start the tunnel, use either the instance id:

```bash
./tunnel-ssm.sh i-xxxxxxxxxxxxx
```
or the "Name" of the instance

```bash
./tunnel-ssm.sh aws-cloud9-test-xxxxxxxxxxxxxxxxxxx
```

Finally connect to your desktop using your RDP client software using `localhost:9999`

Login as ec2-user and the password you specified in step 1.



Windows users use a command similar to:

```
aws ssm start-session --target "Your Instance ID" --document-name AWS-StartPortForwardingSession --parameters "portNumber"=["3389"],"localPortNumber"=["9999"]
```

please see this blog post for further details on SSM port forwarding: 
https://aws.amazon.com/blogs/aws/new-port-forwarding-using-aws-system-manager-sessions-manager/


----

### Customize your Desktop with the new applications

In your desktop open the file browser
Navigate to `/usr/share/applications`

You should see icons for the applications we installed (Chrome, DBeaver, LENS and Visual Studio Code)

Right click on the applications icon and `Copy to Desktop`


