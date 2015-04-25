#!/bin/bash

# the objective of this script is to automate the creation of VMs under virtualbox.  Although this could be done under Vagrant, I want to have a bit more control over what is being done!

# OS selection

PS3='Please enter your OS choice: '
options=("CentOS7" "CentOS6" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "CentOS7")
            OS=centos7
            OSTYPE=RedHat_64
            break
            ;;
        "CentOS6")
        	OS=centos6
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
	DISKS=5
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


export NUMBER=1
	
while [ $NUMBER -le $QUANTITY ]
	do
		# multiple instances!
		
	
		if [ $QUANTITY -eq 1 ]; then
			VMNAME=$NAME
		else
			VMNAME=$NAME$NUMBER
		fi

		# create and register VM
		VBoxManage createvm --name $VMNAME --ostype $OSTYPE --register

		# set VCPUs and RAM

		VBoxManage modifyvm $VMNAME --cpus $VCPUS --memory $RAM

		# connect the network interface

		VBoxManage modifyvm $VMNAME --nic1 hostonly --hostonlyadapter1 vboxnet0 --nictype1 82545EM

		# setting some default VM settings

		# VBoxManage modifyvm $VMNAME --firmware efi

		# storage!

		cp ~/VirtualBox\ VMs/diskimages/$OS.vdi ~/VirtualBox\ VMs/$VMNAME/$VMNAME-disk1.vdi

		VBoxManage storagectl $VMNAME --name IDE --add ide --controller PIIX4 --bootable on
		VBoxManage storagectl $VMNAME --name SAS --add sas --controller LsiLogicSAS --bootable on
		

		VBoxManage storageattach $VMNAME --storagectl SAS --port 0 --type hdd --setuuid "" --medium ~/VirtualBox\ VMs/$VMNAME/$VMNAME-disk1.vdi
		if [ $TYPE == ceph ]; then
			VBoxManage createhd  --filename ~/VirtualBox\ VMs/$VMNAME/$VMNAME-disk2.vdi --size 10240 --format VDI  --variant Standard
			VBoxManage storageattach $VMNAME --storagectl SAS --port 1 --type hdd --setuuid "" --medium ~/VirtualBox\ VMs/$VMNAME/$VMNAME-disk2.vdi
			VBoxManage createhd  --filename ~/VirtualBox\ VMs/$VMNAME/$VMNAME-disk3.vdi --size 10240 --format VDI  --variant Standard
			VBoxManage storageattach $VMNAME --storagectl SAS --port 2 --type hdd --setuuid "" --medium ~/VirtualBox\ VMs/$VMNAME/$VMNAME-disk3.vdi
			VBoxManage createhd  --filename ~/VirtualBox\ VMs/$VMNAME/$VMNAME-disk4.vdi --size 10240 --format VDI  --variant Standard
			VBoxManage storageattach $VMNAME --storagectl SAS --port 3 --type hdd --setuuid "" --medium ~/VirtualBox\ VMs/$VMNAME/$VMNAME-disk4.vdi
			VBoxManage createhd  --filename ~/VirtualBox\ VMs/$VMNAME/$VMNAME-disk5.vdi --size 10240 --format VDI  --variant Standard
			VBoxManage storageattach $VMNAME --storagectl SAS --port 4 --type hdd --setuuid "" --medium ~/VirtualBox\ VMs/$VMNAME/$VMNAME-disk5.vdi
			VBoxManage modifyvm $VMNAME --nic2 hostonly --hostonlyadapter2 vboxnet1 --nictype2 82545EM
		else :
		fi
		# cloud-init configuration

		./cloud-init-config.sh $VMNAME $OS

		# check that the cloud-init config has appeared
		while [ ! -f ~/VirtualBox\ VMs/$VMNAME/$VMNAME-cidata.iso ]
			do
				sleep 2
			done
			sleep 2
		# mount cloud-init 
		
		VBoxManage storageattach $VMNAME --storagectl IDE --port 0 --type dvddrive --setuuid "" --device 0 --medium ~/VirtualBox\ VMs/$VMNAME/$VMNAME-cidata.iso
		
		# start the VM!
		VBoxManage startvm $VMNAME
		NUMBER=$[$NUMBER+1]
	done
