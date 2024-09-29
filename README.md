
# Monitoring Kubernetes Cluster Dashboard with Prometheus and Grafana

## Overview

This project sets up a **Kubernetes cluster** using **Kind** (Kubernetes IN Docker) and deploys **Prometheus** and **Grafana** to monitor key metrics in your cluster. The Grafana dashboard is designed to monitor nodes, namespaces, pods, and containers based on the following requirements:

## Monitoring Requirements:

### **Node:**
- **Pods Running**: Monitor the number of pods running on each node.
- **CPU Usage by Cores**: Track the CPU usage of each core on the node.
- **CPU Usage by %**: Monitor the percentage of CPU usage on the node.

### **Namespace:**
- **Pod Restarts**: Monitor the number of pod restarts in each namespace.
- **CPU Usage**: Track the CPU usage in the namespace.
- **Running Pods**: Monitor the number of pods running in each namespace.
- **Deployments Running**: Monitor the number of active deployments in each namespace.
- **Network Traffic (Receive and Transmit)**: Monitor the incoming and outgoing network traffic.
- **Memory Usage**: Track memory usage in the namespace.

### **Pod:**
- **Network Traffic**: Monitor the network traffic of each pod (receive and transmit).
- **Disk I/O**: Track the disk I/O read and write operations for each pod.
- **CPU Usage by %**: Monitor the CPU usage percentage of each pod.
- **Pod Age**: Monitor how long the pod has been running.
- **Memory Usage**: Track the average memory usage of each pod.

### **Container:**
- **CPU Usage**: Monitor the CPU usage of containers.
- **Memory Usage**: Monitor the memory usage of containers.

## Setup Instructions

### 1. **Requirements**

Ensure you have the following tools installed:
- **Docker**: Required to run Kind.
- **Kubectl**: Command-line tool to interact with the Kubernetes cluster.
- **Kind**: Kubernetes IN Docker to create Kubernetes clusters.

### 2. **Download the Repository**

Clone or download the repository containing the necessary configuration files for the setup:

\`\`\`bash
git clone https://github.com/amit-barda/Monitoring-with-Prometheus-and-Grafana.git
cd Monitoring-with-Prometheus-and-Grafana
\`\`\`

### 3. **Install Kind (if necessary)**

If **Kind** is not installed, the provided script will install it for you.

### 4. **Setup the Cluster**

Run the Bash script to create a Kind Kubernetes cluster, deploy Prometheus, Grafana, and configure port-forwarding:

\`\`\`bash
./setup.sh
\`\`\`

## 5. **File Structure**

The repository contains the following files to configure the cluster and monitoring setup:

- **kind-config.yaml**: Configuration file for the Kind cluster, defining control-plane and worker nodes.
- **namespace.yaml**: Defines the `monitoring` namespace for Prometheus and Grafana deployments.
- **prometheus/prometheus-deployment.yaml**: Prometheus deployment definition.
- **prometheus/prometheus-service.yaml**: Service definition to expose Prometheus.
- **prometheus/prometheus-config.yaml**: Prometheus scrape configurations for monitoring Kubernetes nodes, namespaces, pods, and services.
- **grafana/grafana-deployment.yaml**: Grafana deployment definition.
- **grafana/grafana-service.yaml**: Service definition to expose Grafana.
- **grafana/grafana-config.yaml**: Grafana dashboard ConfigMap that contains the predefined dashboard for monitoring the cluster.

## 6. **Custom Grafana Dashboard**

The Grafana dashboard is automatically configured using a **ConfigMap**. The following metrics are monitored:

### Node Monitoring:
- **Pods Running**: Displays the number of pods running on each node.
- **CPU Usage by Cores**: Shows the CPU usage across cores on each node.
- **CPU Usage by %**: Displays the percentage of CPU usage for each node.

### Namespace Monitoring:
- **Pod Restarts**: Shows the total number of restarts for all pods within a namespace.
- **CPU Usage**: Tracks the total CPU usage in the namespace.
- **Running Pods**: Displays the number of pods actively running in each namespace.
- **Deployments Running**: Shows the number of deployments in each namespace.
- **Network Traffic (Receive and Transmit)**: Displays incoming and outgoing network traffic.
- **Memory Usage**: Tracks the total memory usage for each namespace.

### Pod Monitoring:
- **Network Traffic**: Monitors the network traffic (receive and transmit) for each pod.
- **Disk I/O**: Displays the disk I/O read and write activity for each pod.
- **CPU Usage by %**: Tracks the percentage of CPU usage for each pod.
- **Pod Age**: Shows how long each pod has been running.
- **Memory Usage**: Displays the average memory usage for each pod.

### Container Monitoring:
- **CPU Usage**: Displays the CPU usage of each container.
- **Memory Usage**: Tracks the memory usage of each container.

## 7. **Port-Forwarding Setup**

The script automatically sets up port-forwarding for Grafana and Prometheus:

- **Grafana**: Accessible at `http://localhost:3000`.
- **Prometheus**: Accessible at `http://localhost:9090`.

## 8. **Accessing the Grafana Dashboard**

After the script finishes running, you can access **Grafana** on `http://localhost:3000` and log in using the default credentials:

- **Username**: `admin`
- **Password**: `admin` (You can change this in the `grafana-deployment.yaml` file).

Once logged in, you can find the pre-configured **Kubernetes Cluster Monitoring** dashboard.

## 9. **Customizing the Dashboard**

If you want to add or modify any queries or visualizations, you can modify the **Grafana ConfigMap** (`grafana-config.yaml`), and then redeploy it using:

\`\`\`bash
kubectl apply -f ./grafana/grafana-config.yaml
\`\`\`

## 10. **Tearing Down the Cluster**

To remove the Kind cluster, simply run:

\`\`\`bash
kind delete cluster --name monitoring-cluster
\`\`\`

This will remove the entire Kubernetes cluster.

## Summary

This setup provides a ready-made solution for monitoring your Kubernetes cluster using **Prometheus** and **Grafana**. The dashboard monitors key metrics related to nodes, namespaces, pods, and containers, helping you ensure that your cluster is healthy and performing optimally.

Feel free to extend or modify the configuration files to suit your specific monitoring requirements!

Let me know if you need any further details or have additional requirements!
