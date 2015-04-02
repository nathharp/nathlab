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
options=("micro" "small" "medium" "large" "storage" "Quit")
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
        "storage")
            TYPE=storage
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
elif [ $TYPE == "storage" ]; then
	VCPUS=2
	RAM=2048
	DISKS=3
	DISK1=10
else
	echo "instance type broken"
	exit
fi

echo $VCPUS
echo $RAM
echo $DISKS
echo $DISK1

# query quantities


#default=1
#read -p "how many instances do you require [$default]: " REPLY
#QUANTITY=${REPLY:-$default}

# instance name

read -p "what do you want to call the instance?: " REPLY
NAME=${REPLY}

# summary before creation

echo "CONFIRMATION:"
echo "OS selection is $OS"
echo "instance type is $TYPE"
#echo "quantity: $QUANTITY"
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

# for i in ${seq 1 $QUANTITY}
#do
#
#	# lets work out the naming if there is more than one instance
#	if [ $QUANTITY == 1 ]
#	
#
#done

# create and register VM
VBoxManage createvm --name $NAME --ostype $OSTYPE --register

# set VCPUs and RAM

VBoxManage modifyvm $NAME --cpus $VCPUS --memory $RAM

# connect the network interface

VBoxManage modifyvm $NAME --nic1 hostonly --hostonlyadapter1 vboxnet0 --nictype1 virtio

# setting some default VM settings

VBoxManage modifyvm $NAME --firmware efi

# storage!

cp ~/VirtualBox\ VMs/diskimages/$OS.vdi ~/VirtualBox\ VMs/$NAME

VBoxManage storageattach $NAME --storagectl 