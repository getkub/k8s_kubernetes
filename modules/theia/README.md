##  Theia IDE
https://www.digitalocean.com/community/tutorials/how-to-set-up-the-eclipse-theia-cloud-ide-platform-on-digitalocean-kubernetes

```
# Ubuntu Linux
dport=3000
sudo su -
ips=($(hostname -I))
echo $ips
mylan=`echo ${ips[0]}`
mylan_range=`echo $mylan| awk -F'.' '{print $1"."$2"."$3".0"}'`
iptables -I INPUT -s ${mylan_range}/24 -p tcp --dport ${dport} -j ACCEPT
iptables-save >/etc/iptables/rules.v4
```


```
#macos
mylan_range=`ipconfig getifaddr en0| awk -F'.' '{print $1"."$2"."$3".0/24"}'`
```