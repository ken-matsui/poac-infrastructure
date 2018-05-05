import os
import json
import requests
from requests_aws4auth import AWS4Auth
from elasticsearch import Elasticsearch, RequestsHttpConnection

index = "package"
doc_type = "information"

awsauth = AWS4Auth(
	os.environ['AWS_ACCESS_KEY_ID'],
	os.environ['AWS_SECRET_ACCESS_KEY'],
	os.environ['AWS_REGION'],
	'es',
	session_token=os.environ['AWS_SESSION_TOKEN']
)
es = Elasticsearch(
	hosts=[{'host': os.environ['ES_HOST'], 'port': 443}],
	http_auth=awsauth,
	use_ssl=True,
	verify_certs=True,
	connection_class=RequestsHttpConnection
)

def es_delete(record):
	dynamo = record['dynamodb']['Keys']
	data = {
		'query': {
			'match': {
				'name': dynamo['name']['S']
			}
		}
	}
	# curl -X POST "${ES_HOST}/${index}/_delete_by_query" -H 'Content-Type: application/json' -d ${data}
	es.delete_by_query(index=index, doc_type=doc_type, body=data)

def es_put(record):
	dynamo = record['dynamodb']['Keys']
	data = {'name': dynamo['name']['S'],
			'date': dynamo['date']['S']}
	# curl -X POST "${ES_HOST}/${index}/${doc_type}" -H 'Content-Type: application/json' -d ${data}
	es.index(index=index, doc_type=doc_type, body=data, refresh=True)

def es_edit(records):
	es_delete(records[1])
	es_put(records[0])


def lambda_handler(event, context):
	eventName = event['Records'][0]['eventName']
	if len(event['Records']) == 2:
		es_edit(event['Records'])
		print('es_edit')
	elif eventName == 'INSERT':
		es_put(event['Records'][0])
		print('es_put')
	elif eventName == 'REMOVE':
		es_delete(event['Records'][0])
		print('es_delete')

# curl -X POST ${ENDPOINT}/package/_search -H $HEADER -d '
# {
#   "suggest": {
#     "my-suggestion": {
#       "prefix": "t",
#       "completion": {
#         "field": "name"
#       }
#     }
#   }
# }'
