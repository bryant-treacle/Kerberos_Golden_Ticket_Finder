# Golden Ticket Finder

## Requirements
This script is designed to run ON a Security Onion (An Open-Source NSM Solution) master in any deployment configuration, running elasticsearch, and indexing bro_kerberos logs.  If running this script from an analyst box, you will need to configure ssh port forwarding from local port 9200 to port 9200 on the master node.    

## Golden Tickets attacks
Kerberos Golden Ticket attacks occur when an attacker forges a client’s TGT by harvesting the domain Kerberos account (KRBTGT).  The attacker generates a ticket with a user/group with elevated credential and signs (hashes) the ticket with the KDC service password.  The attacker then requests a Service (TGS) with the forged ticket and is granted access based on that users privilege level.

To detect this behavior using Bro, you will look for a situation where a client is requesting a TGS ticket and has not requested a TGT within "X" hours. "X" hours can vary based on several different factors:
  1. till date of the ticket defined in the AS-REP.
  2. If the ticket is renewable or not.
  3. The maximum renewal time of a ticket. 

  *Note: These parameters are set in the GPO on the Domain Controller.

## Detection Logic
This script queries elasticsearch for Kerberos TGS ticket within the last 24 hours and AS(TGT) tickets within the last "X" days.  It then performs a for loop searching (grep) every entry in the TGS results within the AS(TGT) results and alerts if there is not an AS(TGT) request preceding the TGS request.  It writes the results to the golden_ticket_results.txt file.

## Handling large volumes of logs
Elasticsearch will only return a maximum of 10,000 results from a query using the search api.  To overcome this limitation the script splits the maximum renewal timeframe into 1 hour increments along with the elasticsearch scroll function.   
