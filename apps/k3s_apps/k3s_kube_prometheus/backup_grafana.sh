#!/bin/bash
# Script should be executed as ./backup_grafana.sh backup|restore
# Depending on the argument, the script will backup or restore the dashboards and datasources

GRAFANA_URL="http://grafana.vernify.com"
API_KEY="glsa_HCYx3xIKM2Ryj8NlyH12ThS3vCcujhkK_e0994d6f"

mkdir -p grafana-backups/dashboards
mkdir -p grafana-backups/datasources

if [ "$1" == "backup" ]; then
  echo "Backing up Grafana..."
  # Backup all dashboards
  dashboards=$(curl -s -H "Authorization Bearer $API_KEY" "$GRAFANA_URL/api/search?query=&" | jq -r '.[] | select(.type=="dash-db") | .uid')

  for uid in $dashboards; do
    curl -s -H "Authorization: Bearer $API_KEY" "$GRAFANA_URL/api/dashboards/uid/$uid" | jq -r . > grafana-backups/dashboards/$uid.json
  done

  # Backup all datasources
  curl -s -H "Authorization: Bearer $API_KEY" "$GRAFANA_URL/api/datasources" | jq -r '.' > grafana-backups/datasources/datasources.json
elif [ "$1" == "restore" ]; then
  echo "Restoring Grafana..."

  # Restore dashboards
  for file in grafana-backups/dashboards/*.json; do
    dashboard=$(jq -r . $file)
    title=$(echo "$dashboard" | jq -r .dashboard.title)
    provisioned=$(echo "$dashboard" | jq -r .meta.provisioned)
    if [ -z "$title" ]; then
      echo "Skipping dashboard with empty title in file $file"
      continue
    fi
    if [ "$provisioned" == "true" ]; then
      echo "Skipping provisioned dashboard in file $file"
      continue
    fi
    # Set provisioned to false
    dashboard=$(echo "$dashboard" | jq '.meta.provisioned = false')
    payload=$(jq -n --argjson dashboard "$dashboard" '{"dashboard": $dashboard.dashboard, "overwrite": true}')
    curl -s -H "Authorization: Bearer $API_KEY" -H "Content-Type: application/json" -X POST -d "$payload" $GRAFANA_URL/api/dashboards/db
  done

  # Restore datasources
  datasources=$(jq -c '.[]' grafana-backups/datasources/datasources.json)

  for datasource in $datasources; do
    name=$(echo "$datasource" | jq -r .name)
    existing=$(curl -s -H "Authorization: Bearer $API_KEY" "$GRAFANA_URL/api/datasources/name/$name")
    if [ -n "$existing" ]; then
      echo "Skipping existing datasource $name"
      continue
    fi
    curl -s -H "Authorization: Bearer $API_KEY" -H "Content-Type: application/json" -X POST -d "$datasource" $GRAFANA_URL/api/datasources
  done

else
  echo "Invalid argument. Please use 'backup' or 'restore'."
  echo "Grafana admin password:"
  kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  exit 1
fi
