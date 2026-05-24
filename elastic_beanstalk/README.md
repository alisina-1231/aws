# Install EB CLI

```sh
sudo dnf install python3-pip -y
pip3 install awsebcli --user

echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc

eb --version

eb init

# Choose:

    Region: us-east-1
    Application name: eb-python-lab
    Platform: Python
    Platform branch: Python 3.12
    SSH: yes
    Step 9 — Create Environment
    eb create eb-python-env

# Open Application
eb open

# Check Environment Status
eb status

# Logs
eb logs
# Tail logs live
eb logs --stream

# Change the code and redeploy
eb deploy

# SSH Into EC2 Instance
eb ssh

# Terminate Environment

eb terminate eb-python-env
```