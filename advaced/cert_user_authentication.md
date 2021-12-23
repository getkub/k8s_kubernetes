### To setup a user and automatically use as k8s_config
- After generating private key , csr
- Get the key & crt
- Enroll it with k8s cluster

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${base_64_ca}
    server: https://${node_ip}:${node_port}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: ${user_name}
  name: ${user_name}@kubernetes
current-context: ${user_name}@kubernetes
kind: Config
preferences: {}
users:
- name: ${user_name}
  user:
    client-certificate-data: ${base_64_key}
    client-key-data: ${base_64_crt}
  ```
