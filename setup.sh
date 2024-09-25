#!/bin/bash

# Variables
KIND_CONFIG="./kind-config.yaml"  # Path to the Kind cluster configuration file
PROMETHEUS_NAMESPACE="monitoring"  # Namespace where Prometheus will be deployed
GRAFANA_NAMESPACE="monitoring"  # Namespace where Grafana will be deployed
GRAFANA_DASHBOARD_PATH="./monitoring.json"  # Path to the Grafana dashboard JSON
NAMESPACE_CONFIG="./namespace.yaml"  # Path to the Namespace configuration file
GRAFANA_DEPLOY="./grafana/grafana-deployment.yaml"  # Path to Grafana Deployment YAML
GRAFANA_SERVICE="./grafana/grafana-service.yaml"  # Path to Grafana Service YAML
PROMETHEUS_DEPLOY="./prometheus/prometheus-deployment.yaml"  # Path to Prometheus Deployment YAML
PROMETHEUS_SERVICE="./prometheus/prometheus-service.yaml"  # Path to Prometheus Service YAML
PROMETHEUS_CONFIG="./prometheus/prometheus-config.yaml"  # Path to Prometheus ConfigMap YAML
GRAFANA_CONFIGMAP="./grafana/grafana-config.yaml"  # Path to Grafana ConfigMap YAML for the dashboard

# Function to check if kind is installed and install it if missing
install_kind() {
    if ! command -v kind &> /dev/null; then  # Check if 'kind' command exists
        echo "kind is not installed. Installing..."
        # Download Kind binary
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64
        chmod +x ./kind  # Make it executable
        sudo mv ./kind /usr/local/bin/kind  # Move it to /usr/local/bin
        [ $? -ne 0 ] && { echo "Failed to install kind. Exiting..."; exit 1; }  # Exit if installation fails
    else
        echo "kind is already installed."  # If 'kind' exists, skip installation
    fi
}

# Function to apply multiple Kubernetes resources
apply_k8s_resources() {
    for resource in "$@"; do  # Iterate over all provided resources
        kubectl apply -f "$resource" || { echo "Failed to apply $resource. Exiting..."; exit 1; }  # Apply each resource, exit if failed
    done
}

# Main script execution starts here
install_kind  # Install Kind if not already installed

echo "Creating Kind cluster..."
kind create cluster --config "$KIND_CONFIG"  # Create Kind cluster using the specified configuration file

echo "Applying namespace configurations..."
kubectl apply -f "$NAMESPACE_CONFIG"  # Apply the namespace YAML file

echo "Applying Prometheus configurations..."
apply_k8s_resources "$PROMETHEUS_CONFIG" "$PROMETHEUS_DEPLOY" "$PROMETHEUS_SERVICE"  # Apply Prometheus ConfigMap, Deployment, and Service

echo "Deploying Grafana..."
apply_k8s_resources "$GRAFANA_DEPLOY" "$GRAFANA_SERVICE"  # Apply Grafana Deployment and Service

echo "Configuring Grafana dashboard..."
kubectl apply -f "$GRAFANA_CONFIGMAP" || { echo "Failed to apply Grafana ConfigMap. Exiting..."; exit 1; }  # Apply Grafana ConfigMap for dashboards

echo "Waiting for 3 minutes before starting port-forwarding..."
sleep 180  # Sleep for 3 minutes to allow everything to start up properly

echo "Setting up port-forwarding for Prometheus and Grafana..."
# Port-forward Prometheus on port 9090
kubectl port-forward svc/prometheus -n "$PROMETHEUS_NAMESPACE" --address=0.0.0.0 9090:9090 &
# Port-forward Grafana on port 3000
kubectl port-forward svc/grafana -n "$GRAFANA_NAMESPACE" --address=0.0.0.0 3000:3000 &

# Retrieve the NodePort of the Grafana service (if it's a NodePort service)
NODE_PORT=$(kubectl get services/grafana -n "$GRAFANA_NAMESPACE" -o go-template='{{(index .spec.ports 0).nodePort}}')
echo "Grafana is available at http://localhost:$NODE_PORT"  # Print the Grafana access URL

# Print the Prometheus access URL
echo "Prometheus is accessible at http://localhost:9090"

echo "Setup complete!"  # Indicate the setup is finished
