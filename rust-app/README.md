# 🦀 EKS Rust Application

A sample Rust web application optimized for deployment on Amazon EKS.

## Features

- **High Performance**: Built with Rust for maximum performance and safety
- **Health Checks**: Built-in health endpoint for Kubernetes probes
- **Observability**: Structured logging with tracing
- **Metrics**: Prometheus-compatible metrics endpoint
- **Security**: Runs as non-root user with minimal privileges
- **Production Ready**: Optimized Docker image with multi-stage build

## Endpoints

- `/` - Welcome page
- `/health` - Health check endpoint
- `/api/hello` - Sample API endpoint with pod information
- `/metrics` - Metrics endpoint (Prometheus format)

## Local Development

### Prerequisites

- Rust 1.75+
- Docker
- kubectl (for deployment)

### Running Locally

```bash
# Set environment variable for detailed backtraces
export RUST_BACKTRACE=1

# Run the application
cargo run

# Or with custom port
PORT=3000 cargo run
```

The application will be available at `http://localhost:8080`

### Building

```bash
# Development build
cargo build

# Optimized release build
cargo build --release
```

## Docker

### Building the Image

```bash
docker build -t eks-rust-app .
```

### Running with Docker

```bash
docker run -p 8080:8080 -e RUST_BACKTRACE=1 eks-rust-app
```

## Kubernetes Deployment

### Prerequisites

1. EKS cluster is running
2. kubectl is configured to access your cluster
3. Docker image is pushed to a registry accessible by your cluster

### Deploy to EKS

```bash
# Build and deploy
./build-and-deploy.sh

# Or deploy manually
kubectl apply -f k8s/deployment.yaml
```

### Accessing the Application

```bash
# Port forward to access locally
kubectl port-forward svc/rust-app-service 8080:80

# Or get the load balancer URL (if using ALB)
kubectl get ingress rust-app-ingress
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `8080` |
| `RUST_LOG` | Log level | `info` |
| `RUST_BACKTRACE` | Enable backtraces | `1` |
| `ENVIRONMENT` | Environment name | `development` |

## Monitoring

### Health Checks

The application provides health checks at `/health`:

```json
{
  "status": "healthy",
  "version": "0.1.0",
  "timestamp": "2024-01-01T12:00:00Z",
  "environment": "production"
}
```

### Metrics

Basic metrics are available at `/metrics` in Prometheus format.

### Logging

The application uses structured logging with the `tracing` crate. Logs are output in JSON format for easy parsing by log aggregation systems.

## Performance Optimizations

- **Release Profile**: Optimized for size and speed
- **LTO**: Link-time optimization enabled
- **Strip**: Debug symbols removed
- **Multi-stage Build**: Minimal runtime image
- **Non-root User**: Security best practices

## Security Features

- Runs as non-root user (UID 1000)
- Read-only root filesystem
- Dropped capabilities
- Security context configured
- Minimal base image (Debian slim)

## Troubleshooting

### Enable Detailed Backtraces

```bash
export RUST_BACKTRACE=1
# or
export RUST_BACKTRACE=full
```

### Check Application Logs

```bash
# In Kubernetes
kubectl logs -l app=rust-app -f

# Local development
RUST_LOG=debug cargo run
```

### Common Issues

1. **Port already in use**: Change the `PORT` environment variable
2. **Permission denied**: Ensure the application runs as non-root
3. **Health check failures**: Check if the `/health` endpoint is accessible

## Development

### Code Structure

```
src/
├── main.rs          # Main application entry point
```

### Adding New Endpoints

Add new routes in `main.rs`:

```rust
let new_route = warp::path("api")
    .and(warp::path("new"))
    .and(warp::get())
    .map(|| {
        warp::reply::json(&"New endpoint")
    });

let routes = health
    .or(api)
    .or(new_route)  // Add here
    .or(metrics)
    .or(root);
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.
