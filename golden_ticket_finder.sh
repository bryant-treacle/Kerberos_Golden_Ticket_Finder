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

##############################
# AS ticket request function #
##############################

# Query elasticsearch for the source IP address of all kerberos AS (tgt) ticket requests in the last 2 hours and write to file as_request.txt
as_request_function()
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
}' | jq '.hits.hits[]._source.source_ip' | sort | uniq > as_request.txt
}

###############################
# TGS ticket request function #
###############################

# Query elasticsearch for the source IP address of all kerberos tgs ticket requests in the last 1 hour and write to file tgs_request.txt

tgs_request_function()
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
}' | jq '.hits.hits[]._source.source_ip' | sort | uniq > tgs_request.txt
}

########################
# Golden Ticket Search #
########################

# For loop to verify every IP that requested a Kerberos service (tgs_request.txt) was authenticated to the KDC within x hours before (as_request.txt)

golden_ticket_finder()
{
while read client_tgs_request; do
client_as_request=$(grep $client_tgs_request as_request.txt)
if [ "$client_as_request" == "$client_tgs_request" ]; then
    echo "TGT request found for $client_tgs_request" >> golden_ticket_results.txt
else
    echo "No TGT request found for $client_tgs_request" >> golden_ticket_results.txt
fi

done < tgs_request.txt
}


########################
#  Function Execution  #
########################
as_request_function
tgs_request_function
golden_ticket_finder


