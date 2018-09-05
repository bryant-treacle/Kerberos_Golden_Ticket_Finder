# bro_json_parse
This script will parse the Archived Bro JSON files for all logs associated by an IP address or a range of Addresses

# golden_ticket_finder
This script is designed to run on Security Onion master running in any deployment configuration.  

Kerberos Golden Ticket attack occurs when an attacker forges a clients TGT by harvesting the KDC services password.  He then generates a forged TGT ticket with elevated privileges or permissions and hashes it with the KDC service password.  The attacker then request access to a service sending the KDC the forged ticket with forged TGT ticket.

To detect this behavior using Bro, you will look for a situation where a client is requesting a TGS ticket and has not requested a TGT within X hours.  The X hours is the valid till date which is a setting in the KDC.

* This script queries elasticsearch for Kerberos AS and TGS ticket request and performs a for loop comparing every entry in the TGS results with the results of the AS query and writing the results to the golden_ticket_results.txt file.

* To reduce the amount of false negatives it is important to keep the queries to the minimal timeframe.  By default the script will pull all TGS request in the last 2 hours and all AS(TGT) requests in the last 3 hours.  

* For continual monitoring, you may want to schedule a cron job to automate this script.  The results will be APPENDED to the golden_ticket_results.txt file.  

* For static searching you may want to break the timefame into segments and manipulate the hours for the @timestamp section in the script. 
