#add user to sudoers
echo Add a user name(this will be added to sudoers group):
read varname
adduser $varname
usermod -aG sudo $varname
