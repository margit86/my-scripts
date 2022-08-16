#!/bin/bash

#Script designed to facilitate troubleshooting for problems related to voip trunks
#and more generally to problems with in / out calls
#the script will extract all the information relating to the trunks configured on the switchboard
#sending them to both a trunkfile and standard output


#Asterisk Version
echo -e "\e[1mASTERISK VERSION:\e[0m" | tee trunkfile 
/sbin/rasterisk -V | tee -a trunkfile
echo -e | tee -a trunkfile

echo -e "\e[1mASTERISK UPTIME\e[0m" | tee -a trunkfile
/sbin/asterisk -rx "core show uptime" | tee -a trunkfile
echo -e | tee -a trunkfile

echo -e "\e[1mCodec G729\e[0m" | tee -a trunkfile
/sbin/asterisk -rx 'core show translation' | grep -q g729

codec=$(echo -e $?)

if [[ $codec==0 ]]
then
	echo -e "INSTALLED" | tee -a file
    echo -e | tee -a trunkfile
else
	echo -e "NOT INSTALLED" | tee -a file
    echo -e | tee -a trunkfile
fi

echo -e "\e[1mCONFIGURED TRUNKS:\e[0m" | tee -a trunkfile
echo -e  | tee -a trunkfile

mysql -D asterisk -t -e "select * from trunks;"| tee -a trunkfile

echo -e "\e[1mREGISTERED TRUNKS:\e[0m" | tee -a trunkfile
echo -e  | tee -a trunkfile

/sbin/asterisk -rx "pjsip show registration"| tee -a trunkfile
echo -e  | tee -a trunkfile
echo -e  | tee -a trunkfile
/sbin/asterisk -rx "sip show registry"| tee -a trunkfile
echo -e  | tee -a trunkfile
echo -e  | tee -a trunkfile
echo -e "\e[1mACTIVE CALLS AND CHANNELS\e[0m" | tee -a trunkfile
echo -e  | tee -a trunkfile
/sbin/asterisk -rx "core show channels verbose"| tee -a trunkfile
echo -e  | tee -a trunkfile
echo -e  | tee -a trunkfile
echo -e "\e[1mPJSIP CHANNELS:\e[0m" | tee -a trunkfile
/sbin/asterisk -rx "pjsip show channels"| tee -a trunkfile
echo -e  | tee -a trunkfile
echo -e  | tee -a trunkfile
/sbin/asterisk -rx "sip show channels"| tee -a trunkfile
echo -e  | tee -a trunkfile
echo -e  | tee -a trunkfile

echo -e "\e[1mOUTBOUND ROUTE CONFIGURATION:\e[0m" | tee -a trunkfile
echo -e  | tee -a trunkfile

mysql -D asterisk -t -e "select * from outbound_routes;"| tee -a trunkfile
echo -e  | tee -a trunkfile
echo -e "\e[1mPATTERN:\e[0m" | tee -a trunkfile
echo -e  | tee -a trunkfile
mysql -D asterisk -t -e "select * from outbound_route_patterns;"| tee -a trunkfile