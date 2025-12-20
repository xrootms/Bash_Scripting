# Nexus SetUp 

```bash
#!/bin/bash

# Update package manager repositories
sudo apt-get update -y

# Install necessary dependencies
sudo apt-get install -y ca-certificates curl
echo "Waiting for 5 seconds before installing the package..."
sleep 5

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
sudo apt-get update -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
echo "Waiting for 10 seconds before installing the package..."
sleep 10

sudo systemctl enable docker
sudo systemctl start docker

#Add your user to the docker group, When Docker is installed, it creates a Linux group named docker.
sudo usermod -aG docker $USER


sleep 30

#sudo docker run -d --name nexus -p 8081:8081 sonatype/nexus3:latest      
sudo docker run -d --name nexus -p 8081:8081 -v nexus-data:/nexus-data sonatype/nexus3:latest




```

*Save this script in a file, for example, `install_docker_nexus.sh`, and make it executable using:*

```bash
chmod +x install_docker_nexus.sh
```

Then, you can run the script using:

```bash
./install_docker_nexus.sh
```


## Varification:

#### Get Nexus initial password

Access nexus server  http://<IP>:8081

```bash
sudo cat /var/lib/docker/volumes/nexus-data/_data/admin.password

#sudo docker exec -it nexus cat /nexus-data/admin.password
```
---

### if any issue
```bash
sudo docker logs nexus
```

```bash
docker ps -a
```
