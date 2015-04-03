#!/bin/bash

# do the metadata



mkdir -p ~/tmp/$1-tmpconfig
cd  ~/tmp/$1-tmpconfig
echo "local-hostname: $1.nathlab" > meta-data

# do some user data

cat << EOF > user-data
#cloud-config
password: passw0rd
chpasswd: { expire: False }
ssh_pwauth: True
ssh_authorized_keys:
 - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxuUBmKq0gQWnDtIg7f3S4cYvqJn3GD4Pf9Lx4I5m6L4wOCgYndS5dyFRaMl0HO2dtd3seN9U43kgO8+Ajev7PGKwMWVqgOk2i2hAlbBQRPgV8lx5wLHXf1ML7XvNf7eEYD9kBgkkaq/FzyfmrUiN454bbLUlfn8SHTT+H6d2Ux3M5AJtcndBe23gjHK8So17JWT4KPBbG3VTJIZ917zx6QxY0Wbkwdcut6zzN69ihYxm0dso6JZQa+ZeaFm6YgJOkS5INanIjdTpzKPe7Z339vGFGswCJDSL4x/MGG3+Z3JwbbUToWGWd8n+EK11gEkjC7QgB17GC0lEGHCokn7Hr nathharp@Nathans-MacBook-Pro.local
bootcmd:
 - echo 10.20.0.4 labmgt >> /etc/hosts
 - rm -f /etc/yum.repos.d/CentOS*.repo
 

yum_repos:
    local-lab-centos-base:
        baseurl: http://labmgt/repo/centos7/base/
        enabled: true
        gpgcheck: false
        name: lab centos7 base
    local-lab-centos-updates:
        baseurl: http://labmgt/repo/centos7/updates/
        enabled: true
        gpgcheck: false
        name: lab centos7 updates
    local-lab-centos-otherpkgs:
        baseurl: http://labmgt/repo/centos7/otherpkgs/
        enabled: true
        gpgcheck: false
        name: lab centos7 otherpkgs

packages:
 - salt-minion

salt_minion:
  conf:
    master: labmgt
EOF

# make the iso image

mkisofs -output $1-cidata.iso -volid cidata -joliet -rock user-data meta-data

mv $1-cidata.iso ~/Virtualbox\ VMs/$1/

cd ~/tmp

#rm -rf $1-tmpconfig