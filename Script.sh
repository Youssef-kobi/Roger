
#add user to sudoers
echo Add a user name\(this will be added to sudoers group\):
read varname
adduser $varname
usermod -aG sudo $varname
echo $varname is a sudoer !
echo Getting Your Static ip ready ...
cp ./50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml
netplan apply
echo netplan applied
