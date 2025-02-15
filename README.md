# Multi-Cloud Kubernetes Deployment with Terraform, Cloudflare, and ArgoCD

## Overview
This project demonstrates how to build multi-cloud Kubernetes clusters across AWS (EKS) and Azure (AKS) using Terraform. It incorporates failover mechanisms, GitOps automation, and real-time monitoring to ensure high availability and operational efficiency.

## Features
- **Multi-Cloud Kubernetes Clusters**: Deploy Kubernetes clusters in AWS (EKS) and Azure (AKS) using Terraform.
- **Networking Setup**: Configure VPCs, subnets, node groups, and security policies.
- **Failover with Cloudflare**: Implement load balancing and failover policies to reroute traffic seamlessly during downtime.
- **GitOps with ArgoCD**: Automate deployments by syncing changes from GitHub to Kubernetes clusters.
- **Monitoring & Alerting**: Use Prometheus and AlertManager to track metrics and trigger alerts in real-time.
- **Failover Testing**: Simulate failures to validate the reliability of failover mechanisms.
- **Business Impact**: Enhance resilience, reduce downtime, and improve operational confidence.

## Prerequisites
- Terraform (>= 1.0.0)
- AWS CLI & Azure CLI configured with appropriate credentials
- Kubernetes CLI (`kubectl`)
- Helm
- ArgoCD CLI
- Cloudflare account for DNS and failover setup

## Setup Instructions
### 1. Clone the Repository
```sh
git clone https://github.com/your-repo/multi-cloud-k8s.git
cd multi-cloud-k8s
```

### 2. Initialize Terraform
```sh
cd terraform
terraform init
```

### 3. Deploy Kubernetes Clusters
```sh
terraform apply -auto-approve
```

### 4. Configure Cloudflare for Failover
- Add your clusters' external IPs to Cloudflare DNS.
- Set up load balancing and failover policies in Cloudflare.

### 5. Deploy ArgoCD for GitOps
```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 6. Access ArgoCD Dashboard
```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Open `https://localhost:8080` and log in.

### 7. Deploy Monitoring Stack
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```

### 8. Test Failover Scenarios
- Manually take down a cluster and verify traffic rerouting via Cloudflare.
- Simulate node failures and observe alerting mechanisms.

## Architecture Diagram
![Architecture](docs/architecture-diagram.png)

## Business Case
This setup minimizes downtime and enhances system resilience, making it ideal for production environments requiring high availability.

## Contributing
Feel free to fork this repository, open issues, and submit pull requests.

## License
MIT License
