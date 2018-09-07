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

#####################################
# Client AS ticket request function #
#####################################

# Query elasticsearch for the source IP address of all kerberos AS (tgt) ticket requests in the last 2 hours and write to file as_request.txt
client_as_request_function()
{
curl -XGET "http://localhost:9200/*:logstash-*/_search" -H 'Content-Type: application/json' -d'
{
  "size": "10000",
  "query": {
    "bool": {
      "must": [
        {"term" : {"request_type.keyword": "AS"}}
        ],
        "filter": [
          { "range": {"@timestamp": {"gte": "now-3h/h"}}}
        ]
     }
   }
}' | jq '.hits.hits[]._source.client' | sort | uniq > client_as_request.txt
# remove the realm from the client name.  Causes false positives if the requesting service if the realms are not exact.
sed -i 's|/.*||g'  client_as_request.txt
sed -i 's|"||g'  client_as_request.txt
}

##########################################
# Workstation AS ticket request function #
########################################

# Query elasticsearch for the source IP address of all kerberos AS (tgt) ticket requests in the last 2 hours and write to file as_request.txt
workstation_as_request_function()
{
curl -XGET "http://localhost:9200/*:logstash-*/_search" -H 'Content-Type: application/json' -d'
{
  "size": "10000",
  "query": {
    "bool": {
      "must": [
        {"term" : {"request_type.keyword": "AS"}}
        ],
        "filter": [
          { "range": {"@timestamp": {"gte": "now-3h/h"}}}
        ]
     }
   }
}' | jq '.hits.hits[]._source.source_ip' | sort | uniq > workstation_as_request.txt
}


######################################
# Client TGS ticket request function #
######################################

# Query elasticsearch for the source IP address of all kerberos tgs ticket requests in the last 1 hour and write to file tgs_request.txt

client_tgs_request_function()
{
curl -XGET "http://localhost:9200/*:logstash-*/_search" -H 'Content-Type: application/json' -d'
{
  "size": "10000",
  "query": {
    "bool": {
      "must": [
        {"term" : {"request_type.keyword": "TGS"}}
        ],
        "filter": [
          { "range": {"@timestamp": {"gte": "now-2h/h"}}}
        ]
     }
   }
}' | jq '.hits.hits[]._source.client' | sort | uniq > client_tgs_request.txt

# remove the realm from the client name.  Causes false positives if the requesting service if the realms are not exact.
sed -i 's|/.*||g'  client_tgs_request.txt
sed -i 's|"||g'  client_tgs_request.txt
}


###########################################
# Workstation TGS ticket request function #
###########################################

# Query elasticsearch for the source IP address of all kerberos tgs ticket requests in the last 1 hour and write to file tgs_request.txt

workstation_tgs_request_function()
{
curl -XGET "http://localhost:9200/*:logstash-*/_search" -H 'Content-Type: application/json' -d'
{
  "size": "10000",
  "query": {
    "bool": {
      "must": [
        {"term" : {"request_type.keyword": "TGS"}}
        ],
        "filter": [
          { "range": {"@timestamp": {"gte": "now-2h/h"}}}
        ]
     }
   }
}' | jq '.hits.hits[]._source.source_ip' | sort | uniq > workstation_tgs_request.txt
}

##############################
#Client Golden Ticket Search #
##############################

# For loop to verify every IP that requested a Kerberos service (tgs_request.txt) was authenticated to the KDC within x hours before (as_request.txt)

client_golden_ticket_finder()
{
while read client_tgs_request; do
client_as_request=$(cat client_as_request.txt | grep -F $client_tgs_request)
if [ "$client_as_request" != "$client_tgs_request" ]; then
    echo "No TGT request found for the following user: $client_tgs_request" >> golden_ticket_results.txt
fi

done < client_tgs_request.txt
}


###################################
#Workstation Golden Ticket Search #
###################################

# For loop to verify every IP that requested a Kerberos service (tgs_request.txt) was authenticated to the KDC within x hours before (as_request.txt)

workstation_golden_ticket_finder()
{
while read workstation_tgs_request; do
workstation_as_request=$(cat workstation_as_request.txt | grep -F $workstation_tgs_request)
if [ "$workstation_as_request" != "$workstation_tgs_request" ]; then
    echo "No TGT request found for the following workstation: $workstation_tgs_request" >> golden_ticket_results.txt
fi

done < workstation_tgs_request.txt
}

########################
#  Function Execution  #
########################
client_as_request_function
client_tgs_request_function
client_golden_ticket_finder
workstation_as_request_function
workstation_tgs_request_function
workstation_golden_ticket_finder


rm c*.txt
rm w*.txt

