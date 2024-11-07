choco install jq -y
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

cd /pythonScript
python3 -m venv venv
venv\Scripts\activate
pip3 install datasets