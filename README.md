
## IP ve ISIMLER
```
192.168.206.31 kube1.vbo.local kube1
192.168.206.32 kube2.vbo.local kube2
192.168.206.33 kube3.vbo.local kube3
192.168.206.34 kube4.vbo.local kube4
192.168.206.35 kube5.vbo.local kube5
192.168.206.36 kube6.vbo.local kube6
```

## BAZ VM'DEN KOPYA ÇIKAR
- CENOSMIN2020

- Update base machine

## IP sabitleme
- Mevcut ID'yi gör
grep UUID /etc/sysconfig/network-scripts/ifcfg-ens33
UUID=c4bfbaa1-fb1d-40a1-bb8d-7621d2715181

- Yeni uuid üret
uuidgen ens33
4bc0a84d-2129-4a21-9eb4-455e8f13a4ae

- Üretileni eskinin yerine koy
sed -i 's+UUID=<eskisi>+UUID=<yenisi>+g' /etc/sysconfig/network-scripts/ifcfg-ens33

- Değişimi kontrol et
grep UUID /etc/sysconfig/network-scripts/ifcfg-ens33

UUID=<yenisi> olmalı

## IP ADRESINI DEĞİŞTİR
` vi /etc/sysconfig/network-scripts/ifcfg-ens33 `  

```
[root@base ~]# cat /etc/sysconfig/network-scripts/ifcfg-ens33
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens33
UUID=299e7248-edb9-4cea-8b1f-199ca57ab092
DEVICE=ens33
ONBOOT=yes
IPADDR=192.168.206.31
PREFIX=24
GATEWAY=192.168.206.2
DNS1=8.8.8.8
```
## Sunucu İSMİNİ DEĞİŞTİR
` hostnamectl set-hostname kube1.vbo.local  `  

## REBOOT ve DİĞERİNE GEÇ

## ANSİBLE HAZIRLIK
- Utility sunucusu /etc/hosts dosyasına sunucu ve ip numaralarını ekle

- Ansible hosts dosyasına aşağıdaki kayıtları ekle
```
[kubernetes]
192.168.206.[31:36]

[kube_masters]
192.168.206.[31:33]

[kube_workers]
192.168.206.[34:36]
```



### Tüm sunucularda ansible için ansadmin kullanıcısı oluştur
```
useradd ansadmin
passwd ansadmin
echo "ansadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```

### Tüm sunucularda ssh PasswordAuthentication açık olsun

` sudo grep PasswordAuthentication /etc/ssh/sshd_config `

- Beklenen çıktı:
```
#PasswordAuthentication yes
PasswordAuthentication yes
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication, then enable this but set PasswordAuthentication
```


### Public keyleri ansible kontrol (utiliy) sunucudan tüm sunuculara kopyalayın.
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

- roller
```
192.168.206.31 kube1.vbo.local master-1
192.168.206.32 kube2.vbo.local master-2
192.168.206.33 kube3.vbo.local worker-1
192.168.206.34 kube4.vbo.local worker-2
192.168.206.35 kube5.vbo.local worker-3
192.168.206.36 kube6.vbo.local loadbalancer
```

## ANSİBLE PLAYBOOK
- inventory
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

` [ansadmin@utility kubernetes_cluster]$ ansible-playbook -i /etc/ansible/hosts kubernetes.yml --become `


- haproxy
Bu 36 numaralı sunucu
roles/haproxy/templates/haproxy.cfg.j2


frontend haproxy yani 36 sunucu ip adresi

backend de de iki tana master 31-32 olacak
