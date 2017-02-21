!#/bin/sh

#Create directory to mount temporary shares to
mkdir /mnt/temp

#disable firewalld service and stop it from starting at boot
service firwalld stop
chkconfig firewalld off

#create directory to mount CDROM drive to
#mkdir /mnt/cdrom
#mount /dev/cdrom /mnt/cdrom

#mount groups share
mount -t cifs //g-star.raw/data/install -o username=_svc_compadd,domain=G-STAR.RAW,password=R@wadd00 /mnt/tmp
#copy VMWare Tools Installation
cd /mnt/tmp/Server/Linux
mkdir /tmp
cp VMwareTools-9.0.15-2323214.tar.gz /tmp

#Un-tar and run
cd /tmp
tar -zxvf VMwareTools-9.0.15-2323214.tar.gz
cd vmware-tools-distrib
yum -y -q install perl gcc make kernel-headers kernel-devel -y
rpm -ql kernel-headers
yum -y -q install "kernel-devel-uname-r == $(uname -r)"
./vmware-install.pl -d default

#Install packages needed for domain join
yum -y -q install realmd sssd oddjob oddjob-mkhomedir adcli samba-common
#Join Domain
realm join --user=_svc_compadd --one-time-password=R@wadd00 G-STAR.RAW
#Deny access to everyone
realm deny --all
#Allow the RDP group
realm permit -g G-STAR.RAW\\ADM-OMS-$HOSTNAME
#Give them sudo permission
echo "%ADM-OMS-$HOSTNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
