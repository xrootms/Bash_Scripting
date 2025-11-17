# Kubeadm Master node Setup 

```bash
#!/bin/bash

set -e

# --- Basic setup ---
sudo apt update -y

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# --- Kernel modules and sysctl ---
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl params required by setup
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply changes
sudo sysctl --system
sleep 20

# --- Install containerd ---
sudo apt install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
sleep 30

# --- Install Kubernetes ---

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-apt-keyring.gpg
echo "deb https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sleep 30


#only on master
# --- Initialize master node ---

sudo kubeadm init --pod-network-cidr=10.244.0.0/16

#When it finishes, you’ll see command, Copy that command — you’ll use it on the worker.

sleep 20
# --- Configure kubectl for ubuntu user ---
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



# --- Install Flannel network plugin ---

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

sleep 30

# --- Generate join command for workers ---
#Save join command & Run the join command (join-command.sh) on the worker node

sudo kubeadm token create --print-join-command > /tmp/join-command.sh
```

## Varification
**SSH into your master node:**

```bash
kubeadm version
kubelet --version
kubectl version --client

sudo systemctl status kubelet
sudo systemctl status containerd  # Or docker, depending on your setup

kubectl get pods -n kube-system
kubectl get pods -A
kubectl get pods -n kube-flannel
kubectl get nodes
cat /tmp/join-command.sh
```

```bash
cat /tmp/join-command.sh
```
*Use that command on your worker node (with sudo).*


---
### Deploy Ingress Controller (NGINX) [On MasterNode]

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.49.0/deploy/static/provider/baremetal/deploy.yaml
```

----
# Kubeadm Worker node Setup 

```bash
#!/bin/bash

set -xe

# --- Basic setup ---
sudo apt update -y

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# --- Kernel modules and sysctl ---
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl params required by setup
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply changes
sudo sysctl --system
sleep 20

# --- Install containerd ---
sudo apt install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
sleep 30

# --- Install Kubernetes ---

sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-apt-keyring.gpg
echo "deb https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sleep 20
sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
## Varification

**SSH into your worker node:**

```bash
kubeadm version
kubelet --version
kubectl version --client
```

*Then just run the copied join command **/tmp/join-command.sh** from the master, (with sudo).*
Then run it with sudo, for example:

```bash
sudo kubeadm join 172.31.4.5:6443 --token abcd12.xxxxxx --discovery-token-ca-cert-hash sha256:xxxxxxxx
```

