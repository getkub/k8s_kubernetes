## Older versions of k8s needs certificates renew every x years
```
kubeadm="/usr/loca/bin/kubeadm"
$kubeadm alpha certs renew apiserver-kubelet-client
$kubeadm alpha certs renew apiserver
$kubeadm alpha certs renew front-proxy-client

$kubeadm alpha kubeconfig user --client-name system:kube-controller-manager > /etc/kuberentes/controller-manager.conf
$kubeadm alpha kubeconfig user --client-name system:kube-scheduler > /etc/kuberentes/scheduler.conf
$kubeadm alpha kubeconfig user --client-name system:node:{nodename} --org system:nodes > /etc/kuberentes/kubelet.conf
$kubeadm alpha kubeconfig user --client-name kubernetes-admin --org system:masters > /etc/kuberentes/admin.conf
```
