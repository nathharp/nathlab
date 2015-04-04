#!/bin/bash

# the objective of this script is to automate the creation of VMs under virtualbox.  Although this could be done under Vagrant, I want to have a bit more control over what is being done!

# OS selection

PS3='Please enter your OS choice: '
options=("CentOS7" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "CentOS7")
            OS=centos7
            OSTYPE=RedHat_64
            break
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done

# select from intance type options - micro, small, medium, large and storage

PS3='Please enter your instance type: '
options=("micro" "small" "medium" "large" "ceph" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "micro")
            TYPE=micro
            break
            ;;
        "small")
            TYPE=small
            break
            ;;  
        "medium")
            TYPE=medium
            break
            ;; 
        "large")
            TYPE=large
            break
            ;; 
        "ceph")
            TYPE=ceph
            break
            ;; 
        "Quit")
            exit
            ;;
        *) echo invalid option;;
    esac
done
echo "the type is $TYPE"

# define instance types
if [ $TYPE == "micro" ]; then
	VCPUS=1
	RAM=512
	DISKS=1
	DISK1=10
elif [ $TYPE == "small" ]; then
	VCPUS=2
	RAM=1024
	DISKS=1
	DISK1=12
elif [ $TYPE == "medium" ]; then
	VCPUS=2
	RAM=2048
	DISKS=1
	DISK1=20
elif [ $TYPE == "large" ]; then
	VCPUS=4
	RAM=4096
	DISKS=1
	DISK1=30
elif [ $TYPE == "ceph" ]; then
	VCPUS=2
	RAM=2048
	DISKS=3
	DISK1=10
else
	echo "instance type broken"
	exit
fi


# query quantities


default=1
read -p "how many instances do you require [$default]: " REPLY
QUANTITY=${REPLY:-$default}

# instance name

read -p "what do you want to call the instance?: " REPLY
NAME=${REPLY}

# summary before creation

echo "CONFIRMATION:"
echo "OS selection is $OS"
echo "instance type is $TYPE"
echo "quantity: $QUANTITY"
echo "name: $NAME"

PS3='do you want to continue?: '
options=("Yes" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")
            echo "continuing"
            break
            ;;
        "Quit")
        	echo "quitting"
            exit
            ;;
        *) echo invalid option;;
    esac
done

# multiple instances!

NUMBER=1
while [ $NUMBER -le $QUANTITY ]
	do
		

		# create and register VM
		VBoxManage createvm --name $NAME$NUMBER --ostype $OSTYPE --register

		# set VCPUs and RAM

		VBoxManage modifyvm $NAME$NUMBER --cpus $VCPUS --memory $RAM

		# connect the network interface

		VBoxManage modifyvm $NAME$NUMBER --nic1 hostonly --hostonlyadapter1 vboxnet0 --nictype1 virtio

		# setting some default VM settings

		# VBoxManage modifyvm $NAME$NUMBER --firmware efi

		# storage!

		cp ~/VirtualBox\ VMs/diskimages/$OS.vdi ~/VirtualBox\ VMs/$NAME$NUMBER/$NAME$NUMBER-disk1.vdi

		VBoxManage storagectl $NAME$NUMBER --name SAS --add sas --controller LsiLogicSAS --bootable on

		VBoxManage storageattach $NAME$NUMBER --storagectl SAS --port 0 --type hdd --setuuid "" --medium ~/VirtualBox\ VMs/$NAME$NUMBER/$NAME$NUMBER-disk1.vdi
		if [ $TYPE == ceph ]; then
			VBoxManage createhd  --filename ~/VirtualBox\ VMs/$NAME$NUMBER/$NAME$NUMBER-disk2.vdi --size 10240 --format VDI  --variant Standard
			VBoxManage storageattach $NAME$NUMBER --storagectl SAS --port 1 --type hdd --setuuid "" --medium ~/VirtualBox\ VMs/$NAME$NUMBER/$NAME$NUMBER-disk2.vdi
			VBoxManage createhd  --filename ~/VirtualBox\ VMs/$NAME$NUMBER/$NAME$NUMBER-disk3.vdi --size 10240 --format VDI  --variant Standard
			VBoxManage storageattach $NAME$NUMBER --storagectl SAS --port 2 --type hdd --setuuid "" --medium ~/VirtualBox\ VMs/$NAME$NUMBER/$NAME$NUMBER-disk3.vdi
			VBoxManage modifyvm $NAME$NUMBER --nic2 hostonly --hostonlyadapter2 vboxnet1 --nictype2 virtio
		else :
		fi
		# cloud-init configuration

		./cloud-init-config.sh $NAME$NUMBER

		# mount cloud-init 

		VBoxManage storageattach $NAME$NUMBER --storagectl SAS --port 3 --type dvddrive --setuuid "" --medium ~/VirtualBox\ VMs/$NAME$NUMBER/$NAME$NUMBER-cidata.iso
		#VBoxManage storageattach $NAME$NUMBER --storagectl SAS --port 1 --type dvddrive --setuuid "" --medium ~/VirtualBox\ VMs/9/9-cidata.iso
		
		NUMBER=$[$NUMBER+1]
	done