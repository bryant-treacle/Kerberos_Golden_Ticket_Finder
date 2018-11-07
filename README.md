# golden_ticket_finder.sh
This script is designed to run on Security Onion master running in any deployment configuration.  

Kerberos Golden Ticket attack occurs when an attacker forges a clients TGT by harvesting the KDC services password.  He/she then generates a forged TGT ticket signed by the forged . The Kerberos Golden Ticket is a valid TGT Kerberos ticket since it is encrypted/signed by the domain Kerberos account (KRBTGT).  The attacker generates a ticket with a user/group with elevated credential and signs (hashes) the ticket with the KDC service password.  The attacker then requests a Service (TGS) with the forged ticket and is granted access based on that users privilage level.

To detect this behavior using Bro, you will look for a situation where a client is requesting a TGS ticket and has not requested a TGT within X hours. X can very based on several different factors:
  1. till date of the ticket defined in the AS-REP.
  2. If the ticket is renewable.
  3. The maximum renewal time 
note: These parameters are set in the GPO on the Domain Controller.

This script queries elasticsearch for Kerberos AS and TGS ticket request and performs a for loop comparing every entry in the TGS results with the results of the AS query and writing the results to the golden_ticket_results.txt file.

## Handeling large volumes of logs

Elasticsearch will only return a maximum of 10,000 results from a query using the search api.  To overcome this limitation the script splits the maximum renewal timeframe into 1 hour increments along with the elasticsearch scroll function.   
