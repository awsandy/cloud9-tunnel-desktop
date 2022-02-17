## Starting a Desktop on Cloud9

### 1. Create a Cloud9 environment

* Use the option `Create a new no-ingress EC2 instance for environment (access via Systems Manager)`

This ensures there is no inbound access to the Cloud9 instance


### 2. Install additional software

Clone the repo

```bash
cd ~environment
git clone https://github.com/awsandy/cloud9-tunnel-desktop.git

```

Install the desktop software and some sample apps

```bash
cd cloud9-tunnel-desktop
./install-cloud9-desktop.sh
```

Create a password for the user `ec2-user`.

```bash
passwd ec2-user

```


----

### 3. Check your permissions

Ensure you have these permissions for your IAM user or role:

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

*Best Practice: reduce the scope of these permissions using a more specific resource and or adding a condition clause.*

Note: IAM Permissions may take a few minutes to propagate. 


-----

### 3. Tunnel to your desktop securely using SSM

Use the helper script to start the tunnel, use either the instance id:

```bash
./tunnel-ssm.sh i-xxxxxxxxxxxxx
```
or the "Name" of thr instance

```bash
./tunnel-ssm.sh 
```

Finally connect to your desktop using your RDP client software using `localhost:9999`

Login as ec2-user and the password you specified in step 1.




