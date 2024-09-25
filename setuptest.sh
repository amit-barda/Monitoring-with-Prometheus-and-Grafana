#!/bin/bash

# Variables
KIND_CONFIG="./kind-config.yaml"                       # Path to your kind-config.yaml
PROMETHEUS_NAMESPACE="monitoring"
GRAFANA_NAMESPACE="monitoring"
GRAFANA_DASHBOARD_PATH="./monitring.json"
NAMESPACE_CONFIG="./namespace.yaml"
GRAFANA_DEPLOY="./grafana/grafana-deployment.yaml"     # Path to grafana-deploy.yaml
GRAFANA_SERVICE="./grafana/grafana-service.yaml"       # Path to grafana-service.yaml
PROMETHEUS_DEPLOY="./prometheus/prometheus-deployment.yaml" # Path to prometheus-deploy.yaml
PROMETHEUS_SERVICE="./prometheus/prometheus-service.yaml" # Path to prometheus-service.yaml

# 1. Check if kind is installed, if not, install it
if ! command -v kind &> /dev/null
then
    echo "kind is not installed. Installing kind..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind

    # Check if the installation was successful
    if [ $? -ne 0 ]; then
        echo "Failed to install kind. Exiting..."
        exit 1
    fi
else
    echo "kind is already installed."
fi

# If Step 1 succeeded, continue with the rest of the script

# 2. Create a Kind cluster
echo "Creating Kind cluster..."
kind create cluster --config $KIND_CONFIG

# 3. Create namespaces for Prometheus and Grafana
echo "Applying namespace configurations..."
kubectl apply -f $NAMESPACE_CONFIG || { echo "Failed to apply namespace config. Exiting..."; exit 1; }

# 4 & 5. Deploy Prometheus and its service
echo "Deploying Prometheus..."
kubectl apply -f $PROMETHEUS_DEPLOY -n $PROMETHEUS_NAMESPACE || { echo "Failed to deploy Prometheus. Exiting..."; exit 1; }
kubectl apply -f $PROMETHEUS_SERVICE -n $PROMETHEUS_NAMESPACE || { echo "Failed to apply Prometheus service. Exiting..."; exit 1; }

# 6 & 7. Deploy Grafana and its service
echo "Deploying Grafana..."
kubectl apply -f $GRAFANA_DEPLOY -n $GRAFANA_NAMESPACE || { echo "Failed to deploy Grafana. Exiting..."; exit 1; }
kubectl apply -f $GRAFANA_SERVICE -n $GRAFANA_NAMESPACE || { echo "Failed to apply Grafana service. Exiting..."; exit 1; }

# 8. Add Grafana dashboard for Kubernetes monitoring
echo "Configuring Grafana dashboard..."
kubectl create configmap grafana-dashboard --from-file=$GRAFANA_DASHBOARD_PATH -n $GRAFANA_NAMESPACE || { echo "Failed to create dashboard config map. Exiting..."; exit 1; }

# 9. Apply Grafana dashboard config
kubectl apply -f $GRAFANA_DASHBOARD_PATH || { echo "Failed to apply Grafana dashboard config. Exiting..."; exit 1; }

# 10. Sleep for 3 minutes before port-forwarding
echo "Waiting for 3 minutes before starting port-forwarding..."
sleep 180

# 11. Port-forward for Prometheus and Grafana with 0.0.0.0 address
echo "Setting up port-forwarding for Prometheus and Grafana..."
kubectl port-forward svc/prometheus -n $PROMETHEUS_NAMESPACE --address=0.0.0.0 9090:9090 &
kubectl port-forward svc/grafana -n $GRAFANA_NAMESPACE --address=0.0.0.0 3000:3000 &

# 12. Get Grafana access information
NODE_PORT=$(kubectl get services/grafana -n $GRAFANA_NAMESPACE -o go-template='{{(index .spec.ports 0).nodePort}}')
echo "Grafana is available at http://localhost:$NODE_PORT"
echo "Prometheus is accessible at http://localhost:9090"

echo "Setup complete!"
