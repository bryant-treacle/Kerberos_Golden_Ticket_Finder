#!/bin/bash
echo "This script will parse bro json logs and parse out particular IP's"
echo "For a single IP Press 1"
echo "For a range of IP Press 2"
	read userchoice
if [ $userchoice = "1" ] ; then
    echo "What is the IP Address you want to carve out?"
    read singleip
    echo "Is $singleip the correct IP? (Y/N)"
    read singleipcheck
	
	if [ ${singleipcheck,,} = "y" ] ; then
	    echo "Please choose from the following folders:"
		for brologdate in $(ls /nsm/bro/logs); do
		    echo "$brologdate"
		    done
		read logdate
		echo "Is $logdate the correct folder? (Y\N)"
		read logdatecheck
		
		if [ ${logdatecheck,,} = "y" ] ; then 
		    filelocation=$(pwd)
		    echo "The logs will be saved in the following location: $filelocation"
			zgrep $singleip /nsm/bro/logs/$logdate/*.gz > $singleip-$logdate.txt
		    echo "Done"
		elif [ ${logdatecheck,,} = "n" ] ; then
		    echo "Please choose from the following folders:"
			for brologdate in $(ls /nsm/bro/logs); do
			echo "$brologdate"
			done
		    read logdate
		    echo "Is $logdate the correct folder? (Y\N)"
		    read logdatecheck
			if [ ${logdatecheck,,} = "y" ] ; then 
			filelocation=$(pwd)
		            echo "The logs will be saved in the following location: $filelocation"
				zgrep $singleip /nsm/bro/logs/$logdate/*.gz > $singleip-$logdate.txt
			    echo "Done"
			fi
			echo "Done"
		fi
	elif [ ${singleipcheck,,} = "n" ] ; then	
		echo "What is the IP Address you want to carve out?"
		read singleip
		echo "Is $singleip the correct IP? (Y\N)"
		read singleipcheck
		if [ ${singleipcheck,,} = "y" ] ; then
		    echo "Please choose from the following folders:"
			for brologdate in $(ls /nsm/bro/logs); do
			echo "$brologdate"
			done
		    read logdate
		    echo "Is $logdate the correct folder? (Y\N)"
		    read logdatecheck
		
			if [ ${logdatecheck,,} = "y" ] ; then 
		            filelocation=$(pwd)
				echo "The logs will be saved in the following location: $filelocation"
				zgrep $singleip /nsm/bro/logs/$logdate/*.gz > $singleip-$logdate.txt
				echo "Done"
			elif [ ${logdatecheck,,} = "n" ] ; then
			    echo "Please choose from the following folders:"
				for brologdate in $(ls /nsm/bro/logs); do
				echo "$brologdate"
				done
			        read logdate
				echo "Is $logdate the correct folder? (Y\N)"
				read logdatecheck
				    if [ ${logdatecheck,,} = "y" ] ; then 
					filelocation=$(pwd)
					echo "The logs will be saved in the following location: $filelocation"
						zgrep $singleip /nsm/bro/logs/$logdate/*.gz > $singleip-$logdate.txt
					echo "Done"
				    fi
			fi
		fi
	fi
elif [ $userchoice = "2" ] ; then	
	echo "You must use a regualr expression to search a range of IPs.  Below are some examples:"
	echo "To search the 192.168.2.0/24 use 192.168.2.[0-255]"
	echo "To search the 192.168.0.0/22 use 192.168.[0-3].[0-255]"
	echo "What IP Address range do you want to carve out?"
	read ipaddressrange
	echo "Is $ipaddressrange correct? (Y\N)"
	read ipaddressrangecheck
            if [ ${ipaddressrangecheck,,} = "y" ] ; then
	    echo "Please choose from the following folders:"
	    	for brologdate in $(ls /nsm/bro/logs); do
		echo "$brologdate"
		done
	            read logdate
		    echo "Is $logdate the correct folder? (Y\N)"
		    read logdatecheck
			if [ ${logdatecheck,,} = "y" ] ; then 
		            filelocation=$(pwd)
			    echo "The logs will be saved in the following location: $filelocation"
				zgrep $ipaddressrange /nsm/bro/logs/$logdate/*.gz > $ipaddressrange-$logdate.txt
			    echo "Done!"
			elif [ ${logdatecheck,,} = "n" ] ; then
			    echo "Please choose from the following folders:"
			        for brologdate in $(ls /nsm/bro/logs); do
			    echo "$brologdate"
			    done
			    read logdate
			    echo "Is $logdate the correct folder? (Y\N)"
			    read logdatecheck
				if [ ${logdatecheck,,} = "y" ] ; then 
			            filelocation=$(pwd)
				    echo "The logs will be saved in the following location: $filelocation"
					zgrep $ipaddressrange /nsm/bro/logs/$logdate/*.gz > $ipaddressrange-$logdate.txt
				    echo "Done!"
				fi
			fi
		elif [ ${ipaddressrangecheck,,} = "n" ] ; then
		    echo "You must use a regualr expression to search a range of IPs.  Below are some examples:"
		    echo "To search the 192.168.2.0/24 use 192.168.2.[0-255]"
		    echo "To search the 192.168.0.0/22 use 192.168.[0-3].[0-255]"
		    echo "What IP Address range do you want to carve out?"
			read ipaddressrange
		    echo "Is $ipaddressrange correct? (Y\N)"
		    read ipaddressrangecheck
			if [ ${ipaddressrangecheck,,} = "y" ] ; then
		        echo "Please choose from the following folders:"
			    for brologdate in $(ls /nsm/bro/logs); do
			    echo "$brologdate"
			    done
			read logdate
			echo "Is $logdate the correct folder? (Y\N)"
			read logdatecheck
			    if [ ${logdatecheck,,} = "y" ] ; then 
			    filelocation=$(pwd)
			    echo "The logs will be saved in the following location: $filelocation"
				zgrep $ipaddressrange /nsm/bro/logs/$logdate/*.gz > $ipaddressrange-$logdate.txt
			    echo "Done!"
			    elif [ ${logdatecheck,,} = "n" ] ; then
			    echo "Please choose from the following folders:"
				for brologdate in $(ls /nsm/bro/logs); do
				echo "$brologdate"
				done
				read logdate
				echo "Is $logdate the correct folder? (Y\N)"
			        read logdatecheck
				    if [ ${logdatecheck,,} = "y" ] ; then 
					filelocation=$(pwd)
					echo "The logs will be saved in the following location: $filelocation"
				            zgrep $ipaddressrange /nsm/bro/logs/$logdate/*.gz > $ipaddressrange-$logdate.txt
					echo "Done!"
					fi
			    fi
				
			fi
		fi
fi
