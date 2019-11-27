#!/bin/bash

HOST=$(hostname)

#add user to sudoers
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
echo Changing SSH port to 2211 and editing the file sshd-config to block RootLoginPermit, PasswordAthentification and uncomment PublicKeyAuthuntification
cp ./sshd_config /etc/ssh/sshd_config
echo applying public key \(id_rsa.pub\)
mkdir ~/.ssh
cp ./id_rsa.pub  ~/.ssh/authorized_keys
#setting up iptables rules
echo setting up iptables firewall Dos protection and for portscan 
## flush everything
iptables -F
iptables -X
iptables -Z
#set limit connections
iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 15 -j REJECT --reject-with tcp-reset  
iptables -A INPUT -p tcp --syn --dport 443 -m connlimit --connlimit-above 15 -j REJECT --reject-with tcp-reset  
# drop all invalid packets
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP
# allow established
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# allow loopback (localhost)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# allow ping
iptables -t filter -A INPUT -p icmp -j ACCEPT
iptables -t filter -A OUTPUT -p icmp -j ACCEPT
# allow DNS
iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
# allow smtp
iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT
# allow ssh
iptables -A INPUT -p tcp --dport 2211 -j ACCEPT
iptables -I INPUT -p tcp --dport 2211  -m state --state new -m recent --update --seconds 20 --hitcount 5 -j DROP
iptables -I INPUT -p tcp --dport 2211 -m state --state new -m recent --set
# allow http/https
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 80 -m state --state new -m recent --set
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -m state --state new -m recent --set
#set drop policy                                                                                                                                                                                        
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
echo saving iptables rulees with iptables-persistent
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt install iptables-persistent -y
netfilter-persistent start
netfilter-persistent save
#installing Apache2 
echo installing Apache2...
apt install apache2 -y
rm -rf index.html
cp -r ./ustora/* /var/www/html/
#ssl
echo generation a selfsigned key and cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=MA/ST=West coast /L=KHOURIBGA/O=1337/CN=10.11.24.225" -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
echo setting up a Strong Encryption Settings
cp ./ssl-params.conf /etc/apache2/conf-available/
echo Editing default ssl servername, cert and key Path 
cp ./default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
echo Enabling HTTP to HTTPS redirection
cp ./000-default.conf /etc/apache2/sites-available/000-default.conf
echo Setting up apache ssle
a2enmod ssl
a2enmod headers
a2ensite default-ssl
a2enconf ssl-params
systemctl restart apache2
#function install_postfix() {
#echo postfix postfix/mailname string $HOST | sudo debconf-set-selections
#echo postfix postfix/mailbox_limit string 0 | sudo debconf-set-selections
#echo postfix postfix/destinations string $HOST, webserver, localhost.localdomain, localhost  | sudo debconf-set-selections
#echo postfix postfix/recipient_delim string + | sudo debconf-set-selections
#echo postfix postfix/mynetworks string 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 | sudo debconf-set-selections
#echo postfix postfix/main_cf_conversion_warning boolean true | sudo debconf-set-selections
#echo postfix postfix/chattr boolean false | sudo debconf-set-selections
#echo postfix postfix/compat_conversion_warning boolean true | sudo debconf-set-selections
#echo postfix postfix/newaliases boolean false | sudo debconf-set-selections
#echo postfix postfix/rfc1035_violation boolean false | sudo debconf-set-selections
#echo postfix postfix/lmtp_retired_warning boolean true | sudo debconf-set-selections
#echo postfix postfix/procmail boolean false | sudo debconf-set-selections
#echo postfix postfix/protocols select all | sudo debconf-set-selections
#echo postfix postfix/main_mailer_type select local only | sudo debconf-set-selections
install mailutils and postfix
debconf-set-selections <<< "postfix postfix/mailname string $HOST"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get install -y mailutils
echo Setting up crontab to update & upgrade packages
mkdir /var/scripts
cp ./update.sh /var/scripts/
cp ./cron_monitor.sh /var/scripts/
echo "$(echo '@reboot  /var/scripts/update.sh' ; crontab -l)" | crontab -
echo "$(echo '0 4 * * 6 /var/scripts/update.sh' ; crontab -l)" | crontab -
echo "$(echo '0 0 * * *  /var/scripts/cron_monitor.sh' ; crontab -l)" | crontab -
