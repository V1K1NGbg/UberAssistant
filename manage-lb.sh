#!/bin/bash

# UberAssistant Load Balancer Management Script
# This script helps manage the load-balanced Docker containers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [COMMAND]

Commands:
    start           Start all services (NGINX + backends)
    stop            Stop all services
    restart         Restart all services
    status          Show status of all containers
    logs            Show logs from all containers
    logs-nginx      Show only NGINX logs
    logs-backend    Show only backend logs
    scale N         Scale backend to N instances
    health          Check health of all backends
    stats           Show NGINX statistics
    clean           Remove all containers and volumes
    rebuild         Rebuild and restart all services

Examples:
    $0 start
    $0 scale 5
    $0 health
    $0 logs-nginx

EOF
    exit 1
}

# Start services
start_services() {
    print_info "Starting UberAssistant with load balancer..."
    docker-compose up -d
    print_success "Services started successfully"
    sleep 3
    check_health
}

# Stop services
stop_services() {
    print_info "Stopping all services..."
    docker-compose down
    print_success "Services stopped"
}

# Restart services
restart_services() {
    print_info "Restarting all services..."
    docker-compose restart
    print_success "Services restarted"
    sleep 3
    check_health
}

# Show status
show_status() {
    print_info "Container status:"
    docker-compose ps
}

# Show logs
show_logs() {
    docker-compose logs -f --tail=100
}

# Show NGINX logs only
show_nginx_logs() {
    docker-compose logs -f --tail=100 nginx
}

# Show backend logs only
show_backend_logs() {
    docker-compose logs -f --tail=100 backend-1 backend-2 backend-3
}

# Check health
check_health() {
    print_info "Checking health of all services..."
    
    # Check NGINX
    if curl -sf http://localhost/health > /dev/null 2>&1; then
        print_success "NGINX is healthy"
    else
        print_error "NGINX is not responding"
    fi
    
    # Check each backend
    for i in 1 2 3; do
        container="uber-backend-$i"
        if docker exec $container wget --quiet --tries=1 --spider http://localhost:3000/ 2>/dev/null; then
            print_success "Backend $i is healthy"
        else
            print_error "Backend $i is not healthy"
        fi
    done
}

# Show statistics
show_stats() {
    print_info "NGINX Statistics:"
    docker exec uber-assistant-lb curl -s http://localhost/nginx_status
    
    echo ""
    print_info "Container Resource Usage:"
    docker stats --no-stream uber-assistant-lb uber-backend-1 uber-backend-2 uber-backend-3
}

# Scale backends
scale_backends() {
    local count=$1
    
    if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -lt 1 ]; then
        print_error "Invalid scale count. Please provide a positive number."
        exit 1
    fi
    
    print_info "Scaling to $count backend instances..."
    docker-compose up -d --scale backend=$count
    print_success "Scaled to $count instances"
}

# Clean everything
clean_all() {
    print_info "Removing all containers, networks, and volumes..."
    read -p "Are you sure? This will delete all data. (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose down -v
        print_success "Cleanup complete"
    else
        print_info "Cleanup cancelled"
    fi
}

# Rebuild and restart
rebuild_all() {
    print_info "Rebuilding all services..."
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
    print_success "Rebuild complete"
    sleep 3
    check_health
}

# Main script logic
case "${1:-}" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    logs-nginx)
        show_nginx_logs
        ;;
    logs-backend)
        show_backend_logs
        ;;
    scale)
        if [ -z "${2:-}" ]; then
            print_error "Please specify the number of backend instances"
            echo "Usage: $0 scale N"
            exit 1
        fi
        scale_backends "$2"
        ;;
    health)
        check_health
        ;;
    stats)
        show_stats
        ;;
    clean)
        clean_all
        ;;
    rebuild)
        rebuild_all
        ;;
    *)
        usage
        ;;
esac
