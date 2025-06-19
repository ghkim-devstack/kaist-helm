#!/bin/bash

NAMESPACE=kaist
CHART_PATH=.

# Ensure namespace exists
kubectl get namespace "$NAMESPACE" &>/dev/null || kubectl create namespace "$NAMESPACE"

# Check yq is installed
if ! command -v yq &>/dev/null; then
  echo "[ERROR] 'yq' is not installed. Please install yq to run this script."
  exit 1
fi

# Read flags from values.yaml
USE_GCS=$(yq e '.gcs.enabled' "$CHART_PATH/values.yaml")
GCS_SECRET_NAME=$(yq e '.gcs.secretName' "$CHART_PATH/values.yaml")
GCS_SECRET_FILE="$CHART_PATH/gcs-service-account.json"

# Conditional secret creation
if [[ "$USE_GCS" == "true" ]]; then
  if [[ ! -f "$GCS_SECRET_FILE" ]]; then
    echo "[ERROR] Secret file not found: $GCS_SECRET_FILE"
    exit 1
  fi

  if ! kubectl get secret "$GCS_SECRET_NAME" -n "$NAMESPACE" &>/dev/null; then
    echo "[INFO] Creating secret: $GCS_SECRET_NAME"
    kubectl create secret generic "$GCS_SECRET_NAME" \
      --from-file="$(basename "$GCS_SECRET_FILE")=$GCS_SECRET_FILE" \
      -n "$NAMESPACE"
  else
    echo "[INFO] Secret already exists: $GCS_SECRET_NAME. Skipping."
  fi
else
  echo "[INFO] GCS is disabled (gcs.enabled = false). Skipping GCS secret creation."
fi

# Helm deployment
echo "[INFO] Starting Helm deployment..."
helm upgrade --install kaist-backend "$CHART_PATH" \
  -n "$NAMESPACE" --create-namespace --history-max 2

echo "[✅ SUCCESS] Deployment completed successfully."

