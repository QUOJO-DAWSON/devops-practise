#!/bin/bash
################################################################################
# Script: setup-monitoring.sh
# Description: Set up Prometheus and Grafana on Kubernetes
# Author: QUOJO DAWSON
# Usage: ./setup-monitoring.sh [--namespace monitoring]
################################################################################

set -euo pipefail

# Default values
NAMESPACE="monitoring"
PROMETHEUS_VERSION="v2.45.0"
GRAFANA_VERSION="9.5.3"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

function log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

function log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

function log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

function usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Set up monitoring stack (Prometheus & Grafana) on Kubernetes.

Options:
    --namespace NS      Kubernetes namespace (default: monitoring)
    --help              Display this help message

Example:
    $0 --namespace monitoring

EOF
    exit 1
}

function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            --help|-h)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done
}

function check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        exit 1
    fi
    
    if ! command -v helm &> /dev/null; then
        log_error "helm is not installed"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Not connected to a Kubernetes cluster"
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

function create_namespace() {
    log_info "Creating namespace: ${NAMESPACE}"
    
    kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
    
    log_info "Namespace created/verified"
}

function install_prometheus() {
    log_info "Installing Prometheus..."
    
    # Add Prometheus Helm repo
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Create Prometheus values file
    cat > /tmp/prometheus-values.yaml << 'EOF'
server:
  persistentVolume:
    enabled: true
    size: 20Gi
  
  retention: "30d"
  
  resources:
    requests:
      cpu: 500m
      memory: 2Gi
    limits:
      cpu: 1000m
      memory: 4Gi

alertmanager:
  enabled: true
  persistentVolume:
    enabled: true
    size: 10Gi

nodeExporter:
  enabled: true

kubeStateMetrics:
  enabled: true

pushgateway:
  enabled: false

serverFiles:
  alerting_rules.yml:
    groups:
    - name: node_alerts
      rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% on {{ $labels.instance }}"
      
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85% on {{ $labels.instance }}"
    
    - name: kubernetes_alerts
      rules:
      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod is crash looping"
          description: "Pod {{ $labels.namespace }}/{{ $labels.pod }} is restarting frequently"
      
      - alert: PodNotReady
        expr: kube_pod_status_phase{phase!="Running"} > 0
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Pod not ready"
          description: "Pod {{ $labels.namespace }}/{{ $labels.pod }} has been in {{ $labels.phase }} state for more than 10 minutes"
EOF
    
    # Install Prometheus using Helm
    helm upgrade --install prometheus prometheus-community/prometheus \
        --namespace "${NAMESPACE}" \
        --values /tmp/prometheus-values.yaml \
        --wait
    
    log_info "Prometheus installed successfully"
}

function install_grafana() {
    log_info "Installing Grafana..."
    
    # Add Grafana Helm repo
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Create Grafana values file
    cat > /tmp/grafana-values.yaml << 'EOF'
adminPassword: admin

persistence:
  enabled: true
  size: 10Gi

resources:
  requests:
    cpu: 250m
    memory: 750Mi
  limits:
    cpu: 500m
    memory: 1Gi

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.monitoring.svc.cluster.local
      access: proxy
      isDefault: true

dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'default'
      orgId: 1
      folder: ''
      type: file
      disableDeletion: false
      editable: true
      options:
        path: /var/lib/grafana/dashboards/default

dashboards:
  default:
    kubernetes-cluster:
      gnetId: 7249
      revision: 1
      datasource: Prometheus
    kubernetes-pods:
      gnetId: 6417
      revision: 1
      datasource: Prometheus
    node-exporter:
      gnetId: 1860
      revision: 27
      datasource: Prometheus

service:
  type: LoadBalancer
  port: 80

ingress:
  enabled: false
EOF
    
    # Install Grafana using Helm
    helm upgrade --install grafana grafana/grafana \
        --namespace "${NAMESPACE}" \
        --values /tmp/grafana-values.yaml \
        --wait
    
    log_info "Grafana installed successfully"
}

function display_access_info() {
    log_info "Getting access information..."
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  Monitoring Stack Installation Complete!                      ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Prometheus
    echo "🔍 Prometheus:"
    echo "   Service: prometheus-server.${NAMESPACE}.svc.cluster.local"
    echo "   Port: 80"
    echo ""
    echo "   Access via port-forward:"
    echo "   kubectl port-forward -n ${NAMESPACE} svc/prometheus-server 9090:80"
    echo "   Then visit: http://localhost:9090"
    echo ""
    
    # Grafana
    echo "📊 Grafana:"
    GRAFANA_IP=$(kubectl get svc -n "${NAMESPACE}" grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    if [[ "${GRAFANA_IP}" != "pending" && -n "${GRAFANA_IP}" ]]; then
        echo "   URL: http://${GRAFANA_IP}"
    else
        echo "   Service: grafana.${NAMESPACE}.svc.cluster.local"
        echo "   Port: 80"
        echo ""
        echo "   Access via port-forward:"
        echo "   kubectl port-forward -n ${NAMESPACE} svc/grafana 3000:80"
        echo "   Then visit: http://localhost:3000"
    fi
    echo ""
    echo "   Default credentials:"
    echo "   Username: admin"
    GRAFANA_PASSWORD=$(kubectl get secret -n "${NAMESPACE}" grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
    echo "   Password: ${GRAFANA_PASSWORD}"
    echo ""
    
    # AlertManager
    echo "🚨 AlertManager:"
    echo "   Service: prometheus-alertmanager.${NAMESPACE}.svc.cluster.local"
    echo "   Port: 80"
    echo ""
    echo "   Access via port-forward:"
    echo "   kubectl port-forward -n ${NAMESPACE} svc/prometheus-alertmanager 9093:80"
    echo "   Then visit: http://localhost:9093"
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_info "To view all monitoring resources:"
    echo "   kubectl get all -n ${NAMESPACE}"
    echo ""
}

function main() {
    log_info "Starting monitoring stack installation..."
    
    # Parse arguments
    parse_arguments "$@"
    
    # Check prerequisites
    check_prerequisites
    
    # Create namespace
    create_namespace
    
    # Install Prometheus
    install_prometheus
    
    # Install Grafana
    install_grafana
    
    # Display access information
    display_access_info
    
    log_info "Installation complete!"
}

# Run main function
main "$@"
