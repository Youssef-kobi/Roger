#!/bin/bash

##add user to sudoers
#echo Add a user name\(this will be added to sudoers group\):
#read varname
#useradd $varname
#usermod -aG sudo $varname
#echo $varname is a sudoer !
#Static ip
#echo Getting Your Static ip ready ...
#cp ./50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml
#netplan apply
#echo netplan applied
##SSH
#echo Changing SSH port to 2211 and editing the file sshd-config to block RootLoginPermit, PasswordAuthentification and uncomment PublicKeyAuthuntification
#cp ./sshd_config /etc/ssh/sshd_config
#echo applying public key \(id_rsa.pub\)
#mkdir ~/.ssh
#cp ./id_rsa.pub  ~/.ssh/authorized_keys
##setting up iptables rules
#echo setting up iptables firewall Dos protection and for portscan 
#iptables -F
#iptables -A INPUT -p udp -m udp --dport 53 -m state --state NEW -m recent --set 
#iptables -A INPUT -p udp -m udp --dport 53 -m state --state NEW -m recent --update --seconds2 60 --hitcount 10 -j DROP
#iptables -A INPUT -p tcp -m tcp --dport 53 -m state --state NEW -m recent --set 
#iptables -A INPUT -p tcp -m tcp --dport 53 -m state --state NEW -m recent --update --seconds 60 --hitcount 10  -j DROP
#iptables -A INPUT -p tcp -m tcp --dport 443 -m state --state NEW -m recent --set 
#iptables -A INPUT -p tcp -m tcp --dport 443 -m state --state NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
#iptables -A INPUT -p tcp -m tcp --dport 80 -m state --state NEW -m recent --set
#iptables -A INPUT -p tcp -m tcp --dport 80 -m state --state NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
#iptables -A INPUT -p tcp -m tcp --dport 2211 -m state --state NEW -m recent --set
#iptables -A INPUT -p tcp -m tcp --dport 2211 -m state --state NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
#iptables -A INPUT -m state --state NEW -m recent --set
#iptables -A INPUT -p tcp -m state --state NEW -m recent --update --seconds 1 --hitcount 10 -j DROP
#iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 2211 -j ACCEPT
#iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
#iptables -P INPUT DROP
#iptables -P FORWARD DROP
#echo saving iptables rulees with iptables-persistent
#echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
#echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
#apt install iptables-persistent -y
##netfilter-persistent start
#netfilter-persistent save
#installing Apache2 
#echo installing Apache2...
#apt install apache2 -y
#rm -rf index.html
#cp -r ./ustora/* /var/www/html/
##ssl
#echo generation a selfsigned key and cert
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=MA/ST=West coast /L=KHOURIBGA/O=1337/CN=10.11.24.225" -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
#echo setting up a Strong Encryption Settings
#cp ./ssl-params.conf /etc/apache2/conf-available/
#echo Editing default ssl servername, cert and key Path 
#cp ./default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
#echo Enabling HTTP to HTTPS redirection
#cp ./000-default.conf /etc/apache2/sites-available/000-default.conf
#echo Setting up apache ssle
#a2enmod ssl
#a2enmod headers
#a2ensite default-ssl
#a2enconf ssl-params
#systemctl restart apache2
#echo Setting up crontab to update & upgrade packages
#crontab -l > /Cron_updates
#mkdir /var/scripts
#cp ./update.sh /var/scripts/
#echo "@reboot /var/scripts/update.sh" >> Cron_updates
#echo "0 4 * * 6 /var/scirpts/update.sh" >> Cron_updates
#cron Cron_updates
#Monitoring crontab
#apt install mailutils -y
./cron_monitor.sh