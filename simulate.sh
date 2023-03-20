source .env

BASE64=`cat $1 | base64`
JSON=`echo "{ \"docs\": [ { \"_source\": { \"content\": \"$BASE64\"}}]}"`
echo $JSON | jq
curl -XPOST -s -u elastic:$ELASTIC_PASSWORD "$ELASTICSEARCH_URL/_ingest/pipeline/devoxxpipeline/_simulate" -H 'Content-Type: application/json' --data-binary "$JSON" | jq
