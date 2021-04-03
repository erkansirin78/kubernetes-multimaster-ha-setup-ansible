
- This repo installs kubernetes multimaster and ha cluster on 6 linux machines.

- 6 machines are assumed to be ready and connected to each other as well as internet.

## IP and HOSTNAMES
```
192.168.206.31 kube1.vbo.local kube1
192.168.206.32 kube2.vbo.local kube2
192.168.206.33 kube3.vbo.local kube3
192.168.206.34 kube4.vbo.local kube4
192.168.206.35 kube5.vbo.local kube5
192.168.206.36 kube6.vbo.local kube6
```


## ANSIBLE
- On ansible control machine add following records to inventory (hosts) file
```
[kubernetes]
192.168.206.[31:35]

[kube_masters]
192.168.206.[31:32]

[kube_workers]
192.168.206.[33:35]

[haproxy]
192.168.206.36
```

### Create ansadmin user for ansible on all servers
```
useradd ansadmin
passwd ansadmin
echo "ansadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```

### Have ssh PasswordAuthentication turned on on all servers

` sudo grep PasswordAuthentication /etc/ssh/sshd_config `

-Expected output:
```
#PasswordAuthentication yes
PasswordAuthentication yes
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication, then enable this but set PasswordAuthentication
```

### Copy public keys from ansible control server to all servers.
ssh-copy-id kube1
ssh-copy-id kube2
ssh-copy-id kube3
ssh-copy-id kube4
ssh-copy-id kube5
ssh-copy-id kube6

### Ansible Ping
```
[ansadmin@utility kubernetes_cluster]$ ansible kubernetes -i /etc/ansible/hosts -m ping

[ansadmin@utility kubernetes_cluster]$ ansible kube_masters -i /etc/ansible/hosts -m ping

[ansadmin@utility kubernetes_cluster]$ ansible kube_workers -i /etc/ansible/hosts -m ping

```
## Architecture of Kubernetes Cluster
```
192.168.206.31 kube1.vbo.local master-1
192.168.206.32 kube2.vbo.local master-2
192.168.206.33 kube3.vbo.local worker-1
192.168.206.34 kube4.vbo.local worker-2
192.168.206.35 kube5.vbo.local worker-3
192.168.206.36 kube6.vbo.local loadbalancer
```

## RUN INSTALLATION
` [ansadmin@utility kubernetes_cluster]$ ansible-playbook -i /etc/ansible/hosts kubernetes.yml --become `



-join master-2 (kube2) to cluster

- learn the command from ` cat /tmp/kubeadm_init_output.txt  `
```
 [root@kube2 ~]# kubeadm join 192.168.206.36:6443 --token ln7bt4.6umb1u8tnn8lt745     --discovery-token-ca-cert-hash sha256:6498b6973fd9f35f9c06422241747c9b461a34b2169822e39c4f3e35719d3e85     --control-plane --certificate-key f9c27eb80a98dda701353d9339ba09b5473455240df67cc74c15377ca2cc3ec7 --ignore-preflight-errors='DirAvailable--etc-kubernetes-manifests,FileAvailable--etc-kubernetes-kubelet.conf,Port-10250,FileAvailable--etc-kubernetes-pki-ca.crt'



mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes
```
` --ignore-preflight-errors='DirAvailable--etc-kubernetes-manifests,FileAvailable--etc-kubernetes-kubelet.conf,Port-10250,FileAvailable--etc-kubernetes-pki-ca.crt'` 
this is added upon as workkaroun to an error.

- join worker (kube3,4,5) to cluster
- learn the command from ` cat /tmp/kubeadm_init_output.txt  `
```
[root@kube3 ~]# kubeadm join 192.168.206.36:6443 --token ln7bt4.6umb1u8tnn8lt745     --discovery-token-ca-cert-hash sha256:6498b6973fd9f35f9c06422241747c9b461a34b2169822e39c4f3e35719d3e85 --ignore-preflight-errors='DirAvailable--etc-kubernetes-manifests,FileAvailable--etc-kubernetes-kubelet.conf,Port-10250,FileAvailable--etc-kubernetes-pki-ca.crt'
```
