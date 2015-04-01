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
            break
            ;;
        *) echo invalid option;;
    esac
done


# example prompt with default
default=192.168.0.4
read -p "Enter IP address [$default]: " REPLY
REPLY=${REPLY:-$default}
echo "IP is $REPLY"

# Bash Menu Script Example

PS3='Please enter your choice: '
options=("Option 1" "Option 2" "Option 3" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Option 1")
            echo "you chose choice 1"
            ;;
        "Option 2")
            echo "you chose choice 2"
            ;;
        "Option 3")
            echo "you chose choice 3"
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done