# Minikube for Linux
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube

sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/
```

```
# Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version
```
### Ensure minikube starts with enough memory/cpu

```
# Check status of already existing minikube
vboxmanage showvminfo minikube | grep "Memory size\|Number of CPUs"
minikube stop
minikube config set memory 8192
minikube config set cpus 4
minikube start

# or alternatively
vboxmanage modifyvm "minikube" --cpus 4 --memory 8192
```

```
# First time setup
grep -E --color 'vmx|svm' /proc/cpuinfo
cpus=4
mem=6144
minikube start --vm-driver=virtualbox --cpus $cpus --memory $memory
minikube status
kubectl get node minikube -o jsonpath='{.status.capacity}' && echo

```

## Below settings are env variables
```
# GUI
mylan="192.168.1.1"
k8s_host="192.168.1.10"
mylaptop="192.168.1.10"
api_port=8001
sshUser=root
```

## Ensure IP tables are enabled eg for local LAN
```
sudo iptables -I INPUT -s ${mylan}/24 -p tcp --dport ${api_port} -j ACCEPT
sudo iptables -I INPUT -s ${mylan}/24 -p tcp --dport 8443 -j ACCEPT
sudo iptables-save >/etc/iptables/rules.v4
```

### Check settings of context
```
kubectl config view
```


### Debug network issues
```
https://stackoverflow.com/questions/55462654/access-minikube-loadbalancer-service-from-host-machine
ns=gitlab
kubectl -n $ns get service

```

### Make a tunnel to work with ClusterIP (and or LoadBalancer)
```
# Another shell run below
minikube tunnel
# then you should be access the svc using ClusterIP & port
```

### Tunnel from remote laptop
```
localport=3001
remoteport=3001
remoteIP="10.110.216.39"
remoteHost="myServer"
remoteHostUser="root"
ssh -L ${localport}:${remoteIP}:${remotePort} ${remoteHostUser}@${remoteHost}
```

```
# Port Forward
ns=myns
object="service/ingress-nginx-controller"
outsidePort=8000
internalPort=443
kubectl -n $ns port-forward ${object} ${outsidePort}:${internalPort} --address='0.0.0.0'
```


### Create kubeconfig for Dashboard
- See k8s_dashboard_kubeconfig.md


### MetaLB for remote access
https://metallb.universe.tf/installation/

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
```
