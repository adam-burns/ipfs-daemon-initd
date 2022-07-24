#!/bin/sh
# This file is part of the ipfs-daemon-initd project, 
# and is licensed under the MIT license
# Copyright 2015 Jeff Cochran

USER_NAME="ipfsd"
USER_HOME="/ipfsd"

if [ "$EUID" -ne 0 ]; then
	echo 'This script must be run as root!'
	exit 1
fi

echo 'Finding ipfs...'

command -v /usr/local/bin/ipfs > /dev/null 2>&1
if [ 0 -eq $? ]; then
	IPFS_BIN_PATH=/usr/local/bin/ipfs
fi

if [ -z $IPFS_BIN_PATH ]; then
	command -v /usr/bin/ipfs > /dev/null 2>&1
	if [ 0 -eq $? ]; then
		IPFS_BIN_PATH=/usr/bin/ipfs
	fi
fi

if [ -z $IPFS_BIN_PATH ]; then
	which ipfs > /dev/null 2>&1
	if [ 0 -eq $? ]; then
		IPFS_BIN_PATH=`which ipfs`
	fi
fi

if [ -z $IPFS_BIN_PATH ]; then
	echo 'Unable to find IPFS binary!'
	echo 'Make sure it, or a link to it is on the path'
	echo ' or in a normal install location'
	exit 1
fi

echo "Found ipfs at $IPFS_BIN_PATH"

echo 'Creating daemon user ...'

useradd -r -m -d $USER_HOME $USER_NAME

echo 'Initializing ipfs...'
chmod o+rx $IPFS_BIN_PATH
sudo -u ipfsd $IPFS_BIN_PATH init

echo 'Adding init script...'

cp ./ipfsd /etc/init.d
chmod 755 /etc/init.d/ipfsd

echo 'Adding cronjob...'
cp ./ipfsd-cron /etc/cron.d

which update-rc.d > /dev/null 2>&1
if [ 0 -eq $? ]; then
	update-rc.d ipfsd defaults
	echo 'Success'
	exit 0
fi

command -v /usr/sbin/chkconfig > /dev/null 2>&1
if [ 0 -eq $? ]; then
	/usr/sbin/chkconfig --add ipfsd
	echo 'Success'
	exit 0
fi

echo 'Unable to automatically generate rc.d files. Refer to your OS manual to enable the ipfsd service at boot time. (sorry)'
echo 'Success'
exit 0
