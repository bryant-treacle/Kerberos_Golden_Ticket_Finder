#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author: Bryant Treacle
# Purpose: This script will look for Kerberos Golden Tickets in Security Onion by querying Elasticsearch for AS and TGS requests.

##################
# Initial Prompt #
##################

initial_prompt()
{
echo ""
echo "What is the maximum renewal period for Kerberos tickets in days?"
read renew_time

# Convert the days to hours and add a padding to compensate for UTC/working timezone differences
start_time=$(($renew_time * 24))
# The script will query elasticsearch at one hour increments to help handle large data sets
end_time=$(($start_time - 1))
echo ""
echo "Depending on the renewal period this may take a while."
}

#####################################
# Client AS ticket request function #
#####################################
# Query elasticsearch for the source IP address of all kerberos AS (tgt) ticket requests in the last 2 hours and write to file as_request.txt
client_as_request_function()
{
# Loop to run through the script until all hours between the current time and the start time has been queried
while [ $end_time -ge 0 ] ; do

# Get the Scroll ID for the initial Kerberos AS request query
SCROLL_ID=$(curl -XGET "http://localhost:9200/*:logstash-*/_search?scroll=5m" -H 'Content-Type: application/json' -d'
{
  "size": "10000",
  "query": {
    "bool": {
      "must": [
        {"term" : {"request_type.keyword": "AS"}}
        ],
        "filter": [
          { "range": {"@timestamp": {"gte": "now-'$start_time'h", "lte": "now-'$end_time'h"}}}
        ]
     }
   }
}' | jq '._scroll_id')

# Get the first batch of results.  Using scroll to ensure all records are returned
curl -XGET "http://localhost:9200/*:logstash-*/_search?scroll=5m" -H 'Content-Type: application/json' -d'
{
  "size": "10000",
  "query": {
    "bool": {
      "must": [
        {"term" : {"request_type.keyword": "AS"}}
        ],
        "filter": [
          { "range": {"@timestamp": {"gte": "now-'$start_time'h", "lte": "now-'$end_time'h"}}}
        ]
     }
  } 
}' | jq '.hits.hits[]._source.client' >> client_as_request_temp.txt

# Get remaining results from previous query
counter=0
while [ $counter -le 50 ] ; do
counter=$(( $counter + 1 ))

curl -XGET "http://localhost:9200/_search/scroll" -H 'Content-Type: application/json' -d'
{
  "scroll": "5m",
  "scroll_id": $SCROLL_ID
}' | jq '.hits.hits[]._source.client' >> client_as_request_temp.txt
done

# Changing the Start and End time variables to account for the previous hours logs.
start_time=$(($end_time))
end_time=$(( $start_time -1 ))
done

# remove the realm from the client name.  Causes false positives if the requesting service if the realms are not exact.
echo ""
echo "Depending on the renewal period this may take a while."
sed -i 's|/.*||g'  client_as_request_temp.txt
sed -i 's|"||g'  client_as_request_temp.txt
cat client_as_request_temp.txt | sort -u > client_as_request.txt
rm client_as_request_temp.txt

}

######################################
# Client TGS ticket request function #
######################################
# Query elasticsearch for the source IP address of all kerberos tgs ticket requests in the last 1 hour and write to file client_tgs_request.txt

client_tgs_request_function()
{
# Get the Scroll ID for the initial Kerberos TGS request query for tgs requests within the last 24 hours
SCROLL_ID=$(curl -XGET "http://localhost:9200/*:logstash-*/_search?scroll=5m" -H 'Content-Type: application/json' -d'
{
  "size": "10000",
  "query": {
    "bool": {
      "must": [
        {"term" : {"request_type.keyword": "TGS"}}
        ],
        "filter": [
	    { "range": {"@timestamp": {"gte": "now-24h"}}}	          
        ]
     }
   }
}' | jq '._scroll_id')

# Get the first batch of results.  Using scroll to ensure all records are returned
curl -XGET "http://localhost:9200/*:logstash-*/_search?scroll=5m" -H 'Content-Type: application/json' -d'
{
  "size": "10000",
  "query": {
    "bool": {
      "must": [
        {"term" : {"request_type.keyword": "TGS"}}
        ],
        "filter": [
	    { "range": {"@timestamp": {"gte": "now-24h"}}}
         
        ]
     }
   }
}' | jq '.hits.hits[]._source.client' >> client_tgs_request_temp.txt

# Get remaining results from previous query
counter=0
while [ $counter -le 50 ] ; do
counter=$(( $counter + 1 ))

curl -XGET "http://localhost:9200/_search/scroll" -H 'Content-Type: application/json' -d'
{
  "scroll": "5m",
  "scroll_id": $SCROLL_ID
}' | jq '.hits.hits[]._source.client' >> client_tgs_request_temp.txt
done 

# remove the realm from the client name.  Causes false positives if the requesting service if the realms are not exact.
sed -i 's|/.*||g'  client_tgs_request_temp.txt
sed -i 's|"||g'  client_tgs_request_temp.txt
cat client_tgs_request_temp.txt | sort -u > client_tgs_request.txt
rm client_tgs_request_temp.txt

}

#############################
#   Golden Ticket Search    #
#############################
# For loop to verify every kerberos tgs request (tgs_request.txt) was authenticated to the KDC within x hours before (as_request.txt)
golden_ticket_search()
{
while read client_tgs_request; do
if ! grep -Fxq $client_tgs_request client_as_request.txt; then
    echo "No TGT request found for the following user: $client_tgs_request" >> golden_ticket_results.txt
fi
done < client_tgs_request.txt
}

########################
#  Function Execution  #
########################
#&> /dev/null

initial_prompt 
client_as_request_function &> /dev/null
client_tgs_request_function &> /dev/null 
golden_ticket_search
echo ""
echo "Complete!!! Wrote the results in the current working directory!"
