
#!/bin/bash

set -ex

sudo apt-get update -y
sudo apt install openjdk-17-jre-headless -y

# --- JENKINS INSTALLATION STEPS ---
echo "Waiting for 30 seconds before installing the jenkins package..."
sleep 30
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
yes | sudo apt-get install jenkins
sleep 30
sudo systemctl enable jenkins
sudo systemctl start jenkins

# --- DOCKER INSTALLATION STEPS ---
echo "Waiting for 3 seconds before installing the docker package..."
sleep 3
sudo apt  install docker.io -y
echo "Waiting for 10 seconds before adding User: ubuntu and jenkkins inside docker group..."
sleep 3
for u in ubuntu jenkins; do
  sudo usermod -aG docker $u
done

# --- TRIVY INSTALLATION STEPS ---
echo "Installing Trivy in 3 seconds..."
sleep 3
sudo apt-get update -y
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
sleep 3

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" \
  | sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null

sleep 3
sudo apt-get update -y
sudo apt-get install -y trivy


# --- KUBECTL INSTALLATION STEPS ---
echo "Installing Kubectl in 3 seconds..."
sleep 3
sudo apt-get update
sudo snap install kubectl --classic                      #kubectl version --client


# --- TERRAFORM INSTALLATION STEPS ---
# echo "Waiting for 10 seconds before installing the Terraform..."
#sleep 10
#wget https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_linux_amd64.zip
# sudo apt-get install -y unzip
# unzip 'terraform*.zip'
# sudo mv terraform /usr/local/bin/

# --- CHECKOV INSTALLATION STEPS ---
# echo "Waiting for 10 seconds before installing the Checkov..."
#sleep 10
# sudo apt-get update -y 
# sudo apt-get install -y python3-pip
# sudo pip3 install checkov 
