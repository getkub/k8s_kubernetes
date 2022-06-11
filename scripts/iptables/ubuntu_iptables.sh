#!/bin/bash
# Simple script to list and apply iptables in Ubuntu

if [ $# -lt "2" ]
then
        echo "Error: Input Port NOT present"
        echo "eg <scriptname> <port> <list|apply> <perm>"
        exit 1
fi

if [ "$(whoami)" != "root" ]
then
    echo "Error: Use sudo or login as root"
    exit 1
fi

dport="$1"
action="$2"
persistent="$3"
if [ "$2" == "list" ]
then
    echo "Listing Any rules with port $dport .."
    iptables -L -v -n --line-numbers| grep $dport
    exit 0
fi

if [ "$2" == "apply" ]
then
    ips=($(hostname -I))
    echo "IP of the host => " $ips
    mylan=`echo ${ips[0]}`
    mylan_range=`echo $mylan| awk -F'.' '{print $1"."$2"."$3".0"}'`
    iptables -I INPUT -s ${mylan_range}/24 -p tcp --dport ${dport} -j ACCEPT

    if [ "$3" == "perm" ]
    then
        echo "Making port Permanently enabled"
        iptables-save >/etc/iptables/rules.v4
    fi
fi
