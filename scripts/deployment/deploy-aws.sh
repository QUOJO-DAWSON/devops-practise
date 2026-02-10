#!/bin/bash
################################################################################
# Script: deploy-aws.sh
# Description: Deploy application to AWS EKS with health checks and rollback
# Author: QUOJO DAWSON
# Usage: ./deploy-aws.sh --environment <env> --image <image> [options]
################################################################################

set -euo pipefail

# Script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Default values
ENVIRONMENT=""
IMAGE=""
NAMESPACE=""
REPLICAS=3
HEALTH_CHECK_URL=""
TIMEOUT=300
DRY_RUN=false
ROLLBACK_ON_FAILURE=true

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

################################################################################
# Functions
################################################################################

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

Deploy application to AWS EKS cluster.

Required Options:
    --environment ENV        Target environment (dev, staging, production)
    --image IMAGE           Docker image to deploy (with tag)

Optional Options:
    --namespace NS          Kubernetes namespace (default: environment name)
    --replicas N            Number of replicas (default: 3)
    --health-check URL      Health check URL for validation
    --timeout SECONDS       Deployment timeout (default: 300)
    --dry-run               Perform dry run without applying changes
    --no-rollback           Disable automatic rollback on failure
    -h, --help              Display this help message

Examples:
    # Deploy to development
    $0 --environment dev --image myapp:v1.2.3

    # Deploy to production with custom settings
    $0 --environment production \\
       --image myapp:v1.2.3 \\
       --replicas 5 \\
       --health-check https://api.example.com/health

EOF
    exit 1
}

function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            --image)
                IMAGE="$2"
                shift 2
                ;;
            --namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            --replicas)
                REPLICAS="$2"
                shift 2
                ;;
            --health-check)
                HEALTH_CHECK_URL="$2"
                shift 2
                ;;
            --timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --no-rollback)
                ROLLBACK_ON_FAILURE=false
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "${ENVIRONMENT}" ]]; then
        log_error "Environment is required"
        usage
    fi

    if [[ -z "${IMAGE}" ]]; then
        log_error "Image is required"
        usage
    fi

    # Set namespace to environment if not specified
    if [[ -z "${NAMESPACE}" ]]; then
        NAMESPACE="${ENVIRONMENT}"
    fi
}

function check_prerequisites() {
    log_info "Checking prerequisites..."

    local required_tools=("kubectl" "aws" "jq")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool is not installed"
            exit 1
        fi
    done

    log_info "All prerequisites met"
}

function configure_aws_credentials() {
    log_info "Configuring AWS credentials for environment: ${ENVIRONMENT}"

    # Determine AWS region based on environment
    case "${ENVIRONMENT}" in
        dev|development)
            readonly AWS_REGION="${AWS_REGION_DEV:-us-east-1}"
            readonly EKS_CLUSTER="${EKS_CLUSTER_DEV:-dev-cluster}"
            ;;
        staging)
            readonly AWS_REGION="${AWS_REGION_STAGING:-us-east-1}"
            readonly EKS_CLUSTER="${EKS_CLUSTER_STAGING:-staging-cluster}"
            ;;
        production|prod)
            readonly AWS_REGION="${AWS_REGION_PROD:-us-east-1}"
            readonly EKS_CLUSTER="${EKS_CLUSTER_PROD:-prod-cluster}"
            ;;
        *)
            log_error "Unknown environment: ${ENVIRONMENT}"
            exit 1
            ;;
    esac

    # Update kubeconfig
    log_info "Updating kubeconfig for cluster: ${EKS_CLUSTER}"
    aws eks update-kubeconfig --name "${EKS_CLUSTER}" --region "${AWS_REGION}"

    # Verify connection
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Failed to connect to Kubernetes cluster"
        exit 1
    fi

    log_info "Successfully connected to cluster: ${EKS_CLUSTER}"
}

function backup_current_deployment() {
    log_info "Backing up current deployment..."

    local backup_file="${PROJECT_ROOT}/backups/deployment-${NAMESPACE}-$(date +%Y%m%d-%H%M%S).yaml"
    mkdir -p "$(dirname "${backup_file}")"

    if kubectl get deployment -n "${NAMESPACE}" &> /dev/null; then
        kubectl get deployment -n "${NAMESPACE}" -o yaml > "${backup_file}"
        log_info "Backup saved to: ${backup_file}"
        echo "${backup_file}"
    else
        log_warn "No existing deployment to backup"
        echo ""
    fi
}

function deploy_application() {
    log_info "Deploying application..."
    log_info "  Environment: ${ENVIRONMENT}"
    log_info "  Namespace: ${NAMESPACE}"
    log_info "  Image: ${IMAGE}"
    log_info "  Replicas: ${REPLICAS}"

    local deployment_file="${PROJECT_ROOT}/infrastructure/kubernetes/overlays/${ENVIRONMENT}/deployment.yaml"

    if [[ ! -f "${deployment_file}" ]]; then
        log_error "Deployment file not found: ${deployment_file}"
        exit 1
    fi

    # Apply kustomize and update image
    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "Dry run mode - skipping actual deployment"
        kubectl apply -k "${PROJECT_ROOT}/infrastructure/kubernetes/overlays/${ENVIRONMENT}" --dry-run=client
        return 0
    fi

    # Create namespace if it doesn't exist
    kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

    # Apply deployment with image update
    kubectl set image deployment/app-deployment "app=${IMAGE}" -n "${NAMESPACE}" --record

    log_info "Deployment initiated successfully"
}

function wait_for_deployment() {
    log_info "Waiting for deployment to complete (timeout: ${TIMEOUT}s)..."

    if kubectl rollout status deployment/app-deployment -n "${NAMESPACE}" --timeout="${TIMEOUT}s"; then
        log_info "Deployment completed successfully"
        return 0
    else
        log_error "Deployment failed or timed out"
        return 1
    fi
}

function verify_health() {
    if [[ -z "${HEALTH_CHECK_URL}" ]]; then
        log_warn "No health check URL provided, skipping health verification"
        return 0
    fi

    log_info "Verifying application health..."
    log_info "  Health check URL: ${HEALTH_CHECK_URL}"

    local max_attempts=10
    local attempt=1

    while [[ ${attempt} -le ${max_attempts} ]]; do
        log_info "Health check attempt ${attempt}/${max_attempts}..."

        if curl -sf "${HEALTH_CHECK_URL}" > /dev/null; then
            log_info "Health check passed"
            return 0
        fi

        log_warn "Health check failed, retrying in 10 seconds..."
        sleep 10
        ((attempt++))
    done

    log_error "Health check failed after ${max_attempts} attempts"
    return 1
}

function rollback_deployment() {
    if [[ "${ROLLBACK_ON_FAILURE}" != "true" ]]; then
        log_warn "Automatic rollback is disabled"
        return 0
    fi

    log_warn "Rolling back deployment..."

    if kubectl rollout undo deployment/app-deployment -n "${NAMESPACE}"; then
        log_info "Rollback initiated"
        kubectl rollout status deployment/app-deployment -n "${NAMESPACE}" --timeout=120s
        log_info "Rollback completed"
    else
        log_error "Rollback failed"
        return 1
    fi
}

function get_deployment_info() {
    log_info "Deployment information:"
    echo "----------------------------------------"
    kubectl get pods -n "${NAMESPACE}" -l app=app-deployment
    echo "----------------------------------------"
    kubectl get deployment app-deployment -n "${NAMESPACE}"
    echo "----------------------------------------"
}

function send_notification() {
    local status="$1"
    local message="$2"

    if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
        local color
        case "${status}" in
            success) color="good" ;;
            failure) color="danger" ;;
            *) color="warning" ;;
        esac

        curl -X POST "${SLACK_WEBHOOK_URL}" \
            -H 'Content-Type: application/json' \
            -d "{
                \"attachments\": [{
                    \"color\": \"${color}\",
                    \"title\": \"Deployment ${status}\",
                    \"text\": \"${message}\",
                    \"fields\": [
                        {\"title\": \"Environment\", \"value\": \"${ENVIRONMENT}\", \"short\": true},
                        {\"title\": \"Image\", \"value\": \"${IMAGE}\", \"short\": true}
                    ],
                    \"ts\": $(date +%s)
                }]
            }" || log_warn "Failed to send Slack notification"
    fi
}

################################################################################
# Main
################################################################################

function main() {
    log_info "Starting deployment process..."
    log_info "Timestamp: $(date)"

    # Parse command line arguments
    parse_arguments "$@"

    # Check prerequisites
    check_prerequisites

    # Configure AWS and Kubernetes
    configure_aws_credentials

    # Backup current deployment
    local backup_file
    backup_file=$(backup_current_deployment)

    # Deploy application
    if ! deploy_application; then
        log_error "Deployment failed"
        send_notification "failure" "Deployment to ${ENVIRONMENT} failed"
        exit 1
    fi

    # Wait for deployment to complete
    if ! wait_for_deployment; then
        log_error "Deployment did not complete successfully"
        rollback_deployment
        send_notification "failure" "Deployment to ${ENVIRONMENT} failed - rolled back"
        exit 1
    fi

    # Verify application health
    if ! verify_health; then
        log_error "Health check failed"
        rollback_deployment
        send_notification "failure" "Health check failed for ${ENVIRONMENT} - rolled back"
        exit 1
    fi

    # Get deployment information
    get_deployment_info

    log_info "Deployment completed successfully!"
    send_notification "success" "Successfully deployed to ${ENVIRONMENT}"

    exit 0
}

# Run main function
main "$@"
