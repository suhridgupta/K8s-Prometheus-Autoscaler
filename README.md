# K8s-Prometheus-Autoscaler
This tutorial demonstrates how to install Prometheus and Prometheus-Adapter on a bare-metal Kubernetes cluster, and deploy a simple application which autoscales using a custom metric.
This tutorial refers to and is a modification of the official [Prometheus Adapter walkthrough](https://github.com/kubernetes-sigs/prometheus-adapter/blob/master/docs/walkthrough.md).
## Pre-requisites
- Kubernetes cluster with 1+ worker nodes
- Metrics server deployed on the cluster
- Helm available on the cluster with administrator privileges

# Instructions
## Install Prometheus
Install prometheus from Helm using the following commands:
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --values prometheus-values.yaml --namespace monitoring --create-namespace
```
The Prometheus UI can now be accessed from the browser using http://<Node-IP>:30090. Replace Node-IP with the IP address of any of the K8s cluster nodes.

## Deploy Sample Application
Deploy the application and its corresponding autoscaler using the following command:
```
kubectl apply -f 1-Sample-App
```
The application should now be deployed in the default namespace. Run the following command to confirm the correct deployment:
```
curl http://$(kubectl get service sample-app -o jsonpath='{ .spec.clusterIP }')/metrics
```

## Configure Prometheus Adapter
First, we configure a custom ServiceMonitor to monitor our sample application.
```
kubectl apply -f 2-Prometheus-Adapter/sample-app.monitor.yaml
```
The http_requests_total metric should now be available on the Prometheus UI. However the Autoscaler cannot access the metric yet, which is where the Adapter is used.
To deploy the adapter, we run the following command:
```
helm install custom-metrics prometheus-community/prometheus-adapater --namespace monitoring --values prometheus-adapter-values.yaml
```
Now the custom metric should be available in discovery
```
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq | grep "pods/http_request"
```

## Verify Autoscaling
Run the following command to generate requests to the sample application:
```
bash load_generator.sh
```
Now if we open the horizontal pod autoscaler, we should see the number of replicas change:
```
kubectl get hpa sample-app --watch
```
