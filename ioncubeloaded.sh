#!/bin/bash
currentuser=$(whoami)
phpversion=$1
current_epoch_time=$(date +%s)
ioncubelink="http://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
ioncubefilename="ioncube_loaders_lin_x86-64.tar.gz"

function divider()
{
	echo "================="
}

sleep 2

if [[ "$currentuser" == "root" ]]; then
        echo "Run this as the FTP user and not root"
        exit
fi

echo "Setting up ioncube loader for user $currentuser on $phpversion"

cd ~

if [[ ! "$phpversion" =~  ^[5,7]+(\.[0-9]+)?$ ]]; then
        echo "Please enter a version of PHP you wish to install this for. For example ./ioncubeloaded.sh 5.6. Only supports PHP 5.x and 7.X"
        exit
fi

sleep 2

if [ -d /home/$currentuser/ioncube ]; then
	divider

	echo "Renaming current ioncube directory to download latest versions"
	mv /home/$currentuser/ioncube "/home/$currentuser/ioncube.$current_epoch_time"
fi

divider

echo "Downloading & unpacking ioncube"

sleep 2

mkdir ioncube
cd ioncube
wget -nv $ioncubelink && tar xfz $ioncubefilename -C $HOME
rm -rf $ioncubefilename

sleep 2

divider

echo "Checking to see if phprc files and directories exist"

if [ ! -f /home/$currentuser/.php/$phpversion/phprc ]; then
	sleep 1
	echo "Creating phprc directories and file for PHP $phpversion"
	mkdir -p /home/$currentuser/.php/$phpversion && touch  /home/$currentuser/.php/$phpversion/phprc
else
	sleep 1
	echo "The phprc directory and file already exists, skipping this step"
fi

sleep 2


if  grep --quiet "/home/$currentuser/ioncube/ioncube_loader_lin_$phpversion.so" /home/$currentuser/.php/$phpversion/phprc; then
	divider
	echo "One or more ioncubeloader lines already exists in phprc file, commenting out matching lines just in case to prevent internal server errors"
	sed -i.backup.$current_epoch_time "/ioncube_loader_lin_$phpversion.so/s/^/;/" /home/$currentuser/.php/$phpversion/phprc;
	sleep 2
	echo "Prepending ioncubeloader line to the top of the phprc file"
	sleep 2
	sed -i "1 i zend_extension=/home/$currentuser/ioncube/ioncube_loader_lin_$phpversion.so" /home/$currentuser/.php/$phpversion/phprc
else
	sleep 2
	echo "Prepending ioncubeloader line to the top of the phprc file."
	if [ -s /home/$currentuser/.php/$phpversion/phprc ]; then
		sed -i "1 i zend_extension=/home/$currentuser/ioncube/ioncube_loader_lin_$phpversion.so"  /home/$currentuser/.php/$phpversion/phprc
	else
		echo "zend_extension=/home/$currentuser/ioncube/ioncube_loader_lin_$phpversion.so" >> /home/$currentuser/.php/$phpversion/phprc
	fi
fi

sleep 2

divider

echo "Killing all running PHP $phpversion processes"

sleep 2

killall php"${phpversion//.}".cgi

sleep 1

echo "Done if no errors"
