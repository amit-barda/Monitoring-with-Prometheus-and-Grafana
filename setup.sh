#!/bin/bash

# Variables
KIND_CONFIG="./kind-config.yaml"
PROMETHEUS_NAMESPACE="monitoring"
GRAFANA_NAMESPACE="monitoring"
GRAFANA_DASHBOARD_PATH="./monitoring.json"  # Ensure the path is correct
NAMESPACE_CONFIG="./namespace.yaml"
GRAFANA_DEPLOY="./grafana/grafana-deployment.yaml"
GRAFANA_SERVICE="./grafana/grafana-service.yaml"
PROMETHEUS_DEPLOY="./prometheus/prometheus-deployment.yaml"
PROMETHEUS_SERVICE="./prometheus/prometheus-service.yaml"
PROMETHEUS_CONFIG="./prometheus/prometheus-config.yaml"
GRAFANA_CONFIGMAP="./grafana/grafana-config.yaml"  # New Grafana ConfigMap file

# Function to check command and install if not present
install_kind() {
    if ! command -v kind &> /dev/null; then
        echo "kind is not installed. Installing..."
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
        [ $? -ne 0 ] && { echo "Failed to install kind. Exiting..."; exit 1; }
    else
        echo "kind is already installed."
    fi
}

# Function to apply Kubernetes resources
apply_k8s_resources() {
    for resource in "$@"; do
        kubectl apply -f "$resource" || { echo "Failed to apply $resource. Exiting..."; exit 1; }
    done
}

# Main script execution
install_kind

echo "Creating Kind cluster..."
kind create cluster --config "$KIND_CONFIG"

echo "Applying namespace configurations..."
kubectl apply -f "$NAMESPACE_CONFIG"

echo "Applying Prometheus configurations..."
apply_k8s_resources "$PROMETHEUS_CONFIG" "$PROMETHEUS_DEPLOY" "$PROMETHEUS_SERVICE"

echo "Deploying Grafana..."
apply_k8s_resources "$GRAFANA_DEPLOY" "$GRAFANA_SERVICE"

echo "Configuring Grafana dashboard..."
kubectl apply -f "$GRAFANA_CONFIGMAP" || { echo "Failed to apply Grafana ConfigMap. Exiting..."; exit 1; }

echo "Waiting for 3 minutes before starting port-forwarding..."
sleep 180

echo "Setting up port-forwarding for Prometheus and Grafana..."
kubectl port-forward svc/prometheus -n "$PROMETHEUS_NAMESPACE" --address=0.0.0.0 9090:9090 &
kubectl port-forward svc/grafana -n "$GRAFANA_NAMESPACE" --address=0.0.0.0 3000:3000 &

NODE_PORT=$(kubectl get services/grafana -n "$GRAFANA_NAMESPACE" -o go-template='{{(index .spec.ports 0).nodePort}}')
echo "Grafana is available at http://localhost:$NODE_PORT"
echo "Prometheus is accessible at http://localhost:9090"

echo "Setup complete!"
