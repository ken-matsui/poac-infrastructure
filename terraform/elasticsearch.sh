#!/bin/bash

ENDPOINT=''
curl -X PUT ${ENDPOINT}/_template/template_1 -H 'Content-Type: application/json' -d '
{
  "index_patterns": ["package*"],
  "settings": {
    "number_of_shards": 1
  },
  "mappings": {
    "information": {
      "properties": {
        "name": {
          "type": "completion",
          "analyzer": "simple",
          "search_analyzer": "simple"
        },
        "date": {
          "type": "text"
        }
      }
    }
  }
}'
