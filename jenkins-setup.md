## Installing Jenkins on Ubuntu

```bash
#!/bin/bash
sudo apt-get update -y
yes | sudo apt install openjdk-17-jre-headless -y

# --- JENKINS INSTALLATION STEPS ---
echo "Installing Jenkins in 30 seconds..."
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
echo "Installing Docker in 10 seconds..."
sleep 10
sudo apt  install docker.io -y
echo "Waiting for 10 seconds before adding User: ubuntu and jenkkins inside docker group..."
sleep 10
for u in ubuntu jenkins; do
  sudo usermod -aG docker $u
done

# --- TRIVY INSTALLATION STEPS ---
echo "Installing Trivy in 10 seconds..."
sleep 10
sudo apt-get update -y
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
sleep 20

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" \
  | sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y trivy

echo "✔ Trivy installed successfully!"

# --- KUBECTL INSTALLATION STEPS ---
echo "Installing Kubectl in 10 seconds..."
sleep 10
sudo apt-get update
sudo snap install kubectl --classic


# echo "Waiting for 30 seconds before installing the Terraform..."
# wget https://releases.hashicorp.com/terraform/1.13.3/terraform_1.13.3_linux_amd64.zip
# sudo apt-get install -y unzip
# unzip 'terraform*.zip'
# sudo mv terraform /usr/local/bin/
```

*Save this script in a file, for example, `install_jenkins.sh`, and make it executable using:*

```bash
chmod +x install_jenkins.sh
```

Then, you can run the script using:

```bash
./install_jenkins.sh
```

*This script will automate the installation process of OpenJDK 17 JRE Headless and Jenkins, Trivy, Docker and Kubectl, .*

## Varification

```bash
java --version
```

```bash
./install_jenkins.sh
```

```bash
systemctl status jenkins
```

```bash
which docker
```

```bash
kubectl version --client
```

