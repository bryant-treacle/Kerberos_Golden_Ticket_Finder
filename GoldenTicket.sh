#!/bin/bash
# Author: Bryant Treacle
# Purpose: This script will look for Kerberos Golden Tickets in Security Onion by querying Elasticsearch for AS and TGS requests.

# Query elasticsearch for the source IP address of all kerberos AS (tgt) ticket requests in the last 2 hours
curl -XGET "http://localhost:9200/*:logstash-*/_search" -H 'Content-Type: application/json' -d'
{
  "size": "10000",
  "query": {
    "bool": {
      "should": [
        {"term" : {"request_type.keyword": "AS"}},
        {"term" : {"client.keyword": "*"}}
        ],
        "filter": [
          { "range": {"@timestamp": {"gte": "now-2h/h"}}}
        }
      }
    }
  }
}'| jq '.hits.hits[]._source.source_ip' | uniq > as_request.txt

# Query elasticsearch for the source IP address of all kerberos TGS ticket requests in the last 1 hour
curl -XGET "http://localhost:9200/*:logstash-*/_search" -H 'Content-Type: application/json' -d'
{
  "size": "10000",
  "query": {
    "bool": {
      "should": [
        {"term" : {"request_type.keyword": "TGS"}},
        {"term" : {"client.keyword": "*"}}
        ],
        "filter": [
          { "range": {"@timestamp": {"gte": "now-1h/h"}}}
        }
      }
    }
  }
}'| jq '.hits.hits[]._source.source_ip' | uniq > tsg_request.txt

#Read each line in the tgs_request file and grep for that IP address in the as_request file.  If the IP address does not exist, write
# the IP address to the golden_ticket_results.txt file.  
