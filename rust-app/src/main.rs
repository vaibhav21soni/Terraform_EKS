use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::env;
use tracing::{info, warn};
use uuid::Uuid;
use warp::Filter;

#[derive(Debug, Serialize, Deserialize)]
struct HealthResponse {
    status: String,
    version: String,
    timestamp: String,
    environment: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct ApiResponse {
    id: String,
    message: String,
    data: HashMap<String, String>,
}

#[tokio::main]
async fn main() {
    // Initialize tracing
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    let port = env::var("PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse::<u16>()
        .expect("PORT must be a valid number");

    let environment = env::var("ENVIRONMENT").unwrap_or_else(|_| "development".to_string());

    info!("Starting EKS Rust App on port {}", port);
    info!("Environment: {}", environment);

    // Health check endpoint
    let health = warp::path("health")
        .and(warp::get())
        .map(move || {
            let response = HealthResponse {
                status: "healthy".to_string(),
                version: env!("CARGO_PKG_VERSION").to_string(),
                timestamp: chrono::Utc::now().to_rfc3339(),
                environment: environment.clone(),
            };
            warp::reply::json(&response)
        });

    // API endpoint
    let api = warp::path("api")
        .and(warp::path("hello"))
        .and(warp::get())
        .map(|| {
            let mut data = HashMap::new();
            data.insert("hostname".to_string(), 
                       env::var("HOSTNAME").unwrap_or_else(|_| "unknown".to_string()));
            data.insert("pod_ip".to_string(), 
                       env::var("POD_IP").unwrap_or_else(|_| "unknown".to_string()));
            data.insert("node_name".to_string(), 
                       env::var("NODE_NAME").unwrap_or_else(|_| "unknown".to_string()));

            let response = ApiResponse {
                id: Uuid::new_v4().to_string(),
                message: "Hello from Rust on EKS!".to_string(),
                data,
            };
            warp::reply::json(&response)
        });

    // Metrics endpoint (simple)
    let metrics = warp::path("metrics")
        .and(warp::get())
        .map(|| {
            // In a real app, you'd use prometheus metrics
            let metrics_data = format!(
                "# HELP http_requests_total Total HTTP requests\n# TYPE http_requests_total counter\nhttp_requests_total 42\n"
            );
            warp::reply::with_header(metrics_data, "content-type", "text/plain")
        });

    // Root endpoint
    let root = warp::path::end()
        .and(warp::get())
        .map(|| {
            warp::reply::html(r#"
                <html>
                    <head><title>EKS Rust App</title></head>
                    <body>
                        <h1>🦀 Rust Application on EKS</h1>
                        <p>Endpoints:</p>
                        <ul>
                            <li><a href="/health">/health</a> - Health check</li>
                            <li><a href="/api/hello">/api/hello</a> - API endpoint</li>
                            <li><a href="/metrics">/metrics</a> - Metrics</li>
                        </ul>
                    </body>
                </html>
            "#)
        });

    let routes = health
        .or(api)
        .or(metrics)
        .or(root)
        .with(warp::log("eks_rust_app"));

    info!("Server starting on 0.0.0.0:{}", port);
    
    warp::serve(routes)
        .run(([0, 0, 0, 0], port))
        .await;
}
