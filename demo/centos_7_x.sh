#!/usr/bin/env bash

if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi
(set -x

echo "changeme" | passwd root --stdin
systemctl start firewalld
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload

# example.org domains don't resolve with the original order
cat << EOF > /etc/resolv.conf
search example.org
nameserver 192.168.33.1
nameserver 192.168.121.1
EOF

# Write protect (to prevent dhclient from breaking it)
chattr +i /etc/resolv.conf

# Enable root ssh key access
cp -R /home/vagrant/.ssh /root/.ssh

# Enable ovirt.org repository
yum install -y http://resources.ovirt.org/pub/yum-repo/ovirt-release40.rpm

)

# Enable password based SSH auth
if ! grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config ; then
  sed -i -e '/^PasswordAuthentication/s/^.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config
fi
# Enable root logon
if  ! grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config ; then
  sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin yes/' /etc/ssh/sshd_config
fi
/sbin/service sshd restart


