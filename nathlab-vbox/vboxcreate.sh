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

# query quantities


default=1
read -p "how many instances do you require [$default]: " REPLY
QUANTITY=${REPLY:-$default}

# summary before creation

echo "CONFIRMATION:"
echo "OS selection is $OS"
echo "instance type is $TYPE"
echo "quantity: $QUANTITY"

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