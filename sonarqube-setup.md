# SonarQube setup

```bash
#!/bin/bash

# Update package manager repositories
sudo apt-get update

# Install necessary dependencies
sudo apt-get install -y ca-certificates curl
echo "Waiting for 30 seconds before installing the jenkins package..."
sleep 30

# Create directory for Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Ensure proper permissions for the key
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package manager repositories
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
echo "Waiting for 30 seconds before installing the jenkins package..."
sleep 30

sudo systemctl enable docker
sudo systemctl start docker

#Add your user to the docker group
sudo usermod -aG docker $USER


sleep 30

    
sudo docker run -d --name sonar \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_logs:/opt/sonarqube/logs \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  sonarqube:lts-community

  #sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```

*Save this script in a file, for example, `install_docker_sonar.sh`, and make it executable using:*

```bash
chmod +x install_docker_sonar.sh
```

Then, you can run the script using:

```bash
./install_docker_sonar.sh
```

## Varification

Access sonar server http:/<ip>:9000


```bash
docker ps -a
```


```bash

```
