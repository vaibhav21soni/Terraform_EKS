#!/bin/bash

# Build and deploy script for Rust application on EKS
set -e

# Configuration
APP_NAME="eks-rust-app"
REGISTRY="your-registry"  # Replace with your ECR or Docker registry
TAG="${1:-latest}"
REGION="us-west-2"

echo "🦀 Building and deploying Rust application to EKS..."

# Check if required tools are installed
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed."; exit 1; }

# Build the Docker image
echo "🔨 Building Docker image..."
docker build -t ${REGISTRY}/${APP_NAME}:${TAG} .

# Push to registry (uncomment and configure for your registry)
# echo "📤 Pushing to registry..."
# docker push ${REGISTRY}/${APP_NAME}:${TAG}

# For ECR, you might need:
# aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${REGISTRY}

# Update the deployment with the new image
echo "🚀 Updating Kubernetes deployment..."
sed "s|your-registry/eks-rust-app:latest|${REGISTRY}/${APP_NAME}:${TAG}|g" k8s/deployment.yaml | kubectl apply -f -

# Wait for rollout to complete
echo "⏳ Waiting for deployment to complete..."
kubectl rollout status deployment/rust-app

# Get service information
echo "📋 Service information:"
kubectl get svc rust-app-service

# Get pod information
echo "📋 Pod information:"
kubectl get pods -l app=rust-app

echo "✅ Deployment complete!"
echo ""
echo "🔗 To test the application:"
echo "kubectl port-forward svc/rust-app-service 8080:80"
echo "Then visit: http://localhost:8080"
echo ""
echo "📊 To view logs:"
echo "kubectl logs -l app=rust-app -f"
