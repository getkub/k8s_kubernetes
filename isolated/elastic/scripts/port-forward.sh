#!/bin/bash
# Automatically keeps port forwards alive even if K8s drops them.
# Press Ctrl+C to safely terminate the forwards when done.

echo "[INFO] Starting automated port-forwards for Elasticsearch (9200) and Kibana (5601)..."

# Fetch password automatically for the dev environment
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -n elastic-system -o go-template='{{.data.elastic | base64decode}}' 2>/dev/null)
if [ -n "$PASSWORD" ]; then
  echo "[INFO] External access available securely via:"
  echo "- User: elastic"
  echo "- Pass: $PASSWORD"
fi

echo "Press Ctrl+C to stop."

# Trap Ctrl+C (SIGINT) and kill the child background processes cleanly
trap 'echo -e "\n[STOP] Stopping port-forwards..."; kill $(jobs -p) 2>/dev/null; exit' SIGINT SIGTERM

while true; do
  # Forward Kibana to local port 5601
  kubectl port-forward service/kibana-kb-http 5601 -n elastic-system > /dev/null 2>&1 &
  KIBANA_PID=$!
  
  # Forward Elasticsearch to local port 9200
  kubectl port-forward service/quickstart-es-http 9200:9200 -n elastic-system > /dev/null 2>&1 &
  ES_PID=$!
  
  # macOS default bash (v3) doesn't support 'wait -n'. 
  # We gracefully poll every second to check if either process died.
  while kill -0 $KIBANA_PID 2>/dev/null && kill -0 $ES_PID 2>/dev/null; do
    sleep 1
  done
  
  # If we reach here, one of the port-forwards disconnected unexpectedly
  echo "[WARN] Connection dropped. Restarting port-forwards in 2 seconds..."
  
  # Kill any remaining background processes before restarting the loop
  kill $KIBANA_PID $ES_PID 2>/dev/null
  sleep 2
done
