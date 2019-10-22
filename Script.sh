##add user to sudoers
#echo Add a user name\(this will be added to sudoers group\):
#read varname
#useradd $varname
#usermod -aG sudo $varname
#echo $varname is a sudoer !
#Static ip
echo Getting Your Static ip ready ...
cp ./50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml
netplan apply
echo netplan applied
#SSH
echo Changing SSH port to 2211 and editing the file sshd-config to block RootLoginPermit, PasswordAuthentification and uncomment PublicKeyAuthuntification
cp ./sshd_config /etc/ssh/sshd_config
echo applying public key \(id_rsa.pub\)
cp ./id_rsa.pub  ~/.ssh/authorized_keys
#setting up iptables rules
echo setting up iptables firewall Dos protection and for portscan 
iptables -F
iptables -A INPUT -p udp -m udp --dport 53 -m state --state NEW -m recent --set 
iptables -A INPUT -p udp -m udp --dport 53 -m state --state NEW -m recent --update --seconds2 60 --hitcount 10 -j DROP
iptables -A INPUT -p tcp -m tcp --dport 53 -m state --state NEW -m recent --set 
iptables -A INPUT -p tcp -m tcp --dport 53 -m state --state NEW -m recent --update --seconds 60 --hitcount 10  -j DROP
iptables -A INPUT -p tcp -m tcp --dport 443 -m state --state NEW -m recent --set 
iptables -A INPUT -p tcp -m tcp --dport 443 -m state --state NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
iptables -A INPUT -p tcp -m tcp --dport 80 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp -m tcp --dport 80 -m state --state NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
iptables -A INPUT -p tcp -m tcp --dport 2211 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp -m tcp --dport 2211 -m state --state NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
iptables -A INPUT -m state --state NEW -m recent --set
iptables -A INPUT -p tcp -m state --state NEW -m recent --update --seconds 1 --hitcount 10 -j DROP
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 2211 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
echo saving iptables rulees with iptables-persistent
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt install iptables-persistent -y
#netfilter-persistent start
netfilter-persistent save
