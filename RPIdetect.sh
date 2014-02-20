#! /bin/bash
#################
### @name, RPIdetect
### @author, rizacantufan
### @version, v1.0
### @mail, rizacantufan@gmail.com
################# 

#nmap installed control
if ! dpkg -S `which nmap` > /dev/null; then
   echo -e "Nmap not found! Install? (y/n) \c"
   read
   if "$REPLY" = "y"; then
      sudo apt-get install nmap
   fi
fi

case "$1" in
        -h|--help)
                echo "RPIdetect - attempt to capture frames"
                echo " "
                echo "RPIdetect [options] [ip address]"
                echo " "
                echo "options:"
                echo "-h   show brief help"
                echo "-i   specify an action to use. Not required!"
                exit 0
                ;;
        -i)
                shift
                if [ "$1" ]; then
                        export IP=$1
                else
                        echo "IP address must be specified"
                        exit 1
                fi
                ;;
        *)
                shift
                #get Default gateway ip address on system.
                export IP=$(/sbin/ip route | awk '/default/ { print $3 }')
                echo "Default Gateway:$IP"
                if [ -z "$IP" ] ; then
                            echo 'Local Network not connection!'
                            exit 1
                        fi
                shift
                ;;
esac

if [[ ! "$IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
 then
    echo "IP Address format is incorrect!"
    exit 1
fi

#Use The Constat Info.
mac_address=(
		'98:4F:EE:' # Galileo Default MAC Prefix
		'B8:27:EB:' # Raspberry PI Default MAC Prefix
		'D4:94:A1:' # # Beagle Default MAC Prefix
	)

system_info=(
		'Raspberry'
		'Pi'
		'Galileo'
		'Beagle'
		'BeagleBoard'
		'BeagleBone'
		'Arduino'
		'pcDuino'
		'Kali'
		'Linux'
		'GNU'
		'OpenBSD'
		'FreeBSD'
		'Centos'
		'Redhat'
		'NetBSD'
		'Intel'
	)


b=$(printf "\|%s" "${system_info[@]}\|${mac_address[@]}")
f=${b:2} # xxx\|xxx\| format

#Nmap scanned MAC addess and System info in Local Network
cikti=$(nmap -sP "$IP/24" | awk '/^Nmap/ { printf $5" " } /MAC/ { print }' - | grep -e  "$f")

if [ -z "$cikti" ]; then
    echo "The Embedded System could not be determined in Local network"
    exit 1
fi

echo $cikti # Show the results
