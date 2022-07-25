#!/bin/bash
# This file is part of the ipfs-daemon-initd project, 
# and is licensed under the MIT license
# Copyright 2015 Jeff Cochran

USER_NAME="ipfsd"
USER_HOME="/ipfsd"
IPFS_MOUNTPATH="/"

if [ "$EUID" -ne 0 ]; then
	echo 'This script must be run as root!'
	exit 1
fi

install_service() {
	# $1 - name of executable daemon
	# $2 - name of init script
	# $3 - name of dot directory (.ipfs or .ipfs-cluster)
	echo 'Finding $1 ...'
	
	command -v /usr/local/bin/$1  > /dev/null 2>&1
	if [ 0 -eq $? ]; then
		SERVICE_BIN_PATH=/usr/local/bin/$1 
	fi
	
	if [ -z $SERVICE_BIN_PATH ]; then
		command -v /usr/bin/$1  > /dev/null 2>&1
		if [ 0 -eq $? ]; then
			SERVICE_BIN_PATH=/usr/bin/$1 
		fi
	fi
	
	if [ -z $SERVICE_BIN_PATH ]; then
		which $1  > /dev/null 2>&1
		if [ 0 -eq $? ]; then
			SERVICE_BIN_PATH=`which $1 `
		fi
	fi
	
	if [ -z $SERVICE_BIN_PATH ]; then
		echo 'Unable to find IPFS binary!'
		echo 'Make sure it, or a link to it is on the path'
		echo ' or in a normal install location'
		exit 1
	fi
	
	echo "Found $1  at $SERVICE_BIN_PATH"
	
	echo 'Creating daemon user ...'
	
	[[ -n $(id -u $USER_NAME >/dev/null 2>&1) ]] && useradd -r -m -d $USER_HOME $USER_NAME
	
	# CLUSTER_SECRET, if unset then set with test value
	# TODO handle secrets properly
	[[ -z ${CLUSTER_SECRET+x} ]] && export CLUSTER_SECRET="cb323ed5a5ce2a032cb6352bbcbcc2f0eeb79e5cba7b898ac5e2b80c528522db"
	
	echo "Initializing $1 ..."
	chmod o+rx $SERVICE_BIN_PATH
	[[ ! -d "${USER_HOME}/$3" ]] && sudo -u $USER_NAME CLUSTER_SECRET="$CLUSTER_SECRET" $SERVICE_BIN_PATH init

	echo 'Adding init script...'
	
	cp ./$2 /etc/init.d
	chmod 755 /etc/init.d/$2

        which update-rc.d > /dev/null 2>&1 
        if [ 0 -eq $? ]; then 
                update-rc.d $2 defaults
                echo 'Success'
                exit 0
        fi
        
        command -v /usr/sbin/chkconfig > /dev/null 2>&1 
        if [ 0 -eq $? ]; then 
                /usr/sbin/chkconfig --add $2
                echo 'Success'
                exit 0
        fi

	echo 'Unable to automatically generate rc.d files. Refer to your OS manual to enable the ipfsd service at boot time. (sorry)'

}

install_service ipfs-cluster-service ipfs-clusterd .ipfs-cluster


