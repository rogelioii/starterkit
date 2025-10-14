#!/bin/bash

# Docker build and push script for Python API
# Image: rogelioii/starterkit:latest

set -e  # Exit on any error

# Configuration
IMAGE_NAME="rogelioii/starterkit"
TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to check if logged into Docker Hub
check_docker_login() {
    if ! docker info | grep -q "Username:"; then
        print_warning "Not logged into Docker Hub. Attempting to login..."
        docker login
        if [ $? -ne 0 ]; then
            print_error "Failed to login to Docker Hub. Please login manually with 'docker login'"
            exit 1
        fi
    fi
    print_success "Logged into Docker Hub"
}

# Function to build the Docker image
build_image() {
    print_status "Building Docker image: ${FULL_IMAGE_NAME}"
    
    # Build the image
    docker build -t "${FULL_IMAGE_NAME}" .
    
    if [ $? -eq 0 ]; then
        print_success "Docker image built successfully"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
}

# Function to test the Docker image
test_image() {
    print_status "Testing Docker image..."
    
    # Run the container in background
    CONTAINER_ID=$(docker run -d -p 5555:5555 "${FULL_IMAGE_NAME}")
    
    if [ $? -ne 0 ]; then
        print_error "Failed to start container"
        exit 1
    fi
    
    # Wait for container to start
    sleep 5
    
    # Test health endpoint
    if curl -f http://localhost:5555/health > /dev/null 2>&1; then
        print_success "Health check passed"
    else
        print_error "Health check failed"
        docker logs "${CONTAINER_ID}"
        docker stop "${CONTAINER_ID}" > /dev/null
        exit 1
    fi
    
    # Test API endpoint
    if curl -f "http://localhost:5555/api/string?text=test" > /dev/null 2>&1; then
        print_success "API endpoint test passed"
    else
        print_error "API endpoint test failed"
        docker logs "${CONTAINER_ID}"
        docker stop "${CONTAINER_ID}" > /dev/null
        exit 1
    fi
    
    # Stop and remove test container
    docker stop "${CONTAINER_ID}" > /dev/null
    docker rm "${CONTAINER_ID}" > /dev/null
    print_success "Container test completed successfully"
}

# Function to push the Docker image
push_image() {
    print_status "Pushing Docker image to Docker Hub: ${FULL_IMAGE_NAME}"
    
    docker push "${FULL_IMAGE_NAME}"
    
    if [ $? -eq 0 ]; then
        print_success "Docker image pushed successfully to Docker Hub"
        print_success "Image available at: https://hub.docker.com/r/${IMAGE_NAME}"
    else
        print_error "Failed to push Docker image"
        exit 1
    fi
}

# Function to show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --build-only    Only build the image, don't push"
    echo "  --push-only     Only push existing image, don't build"
    echo "  --no-test       Skip testing the image"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build, test, and push"
    echo "  $0 --build-only       # Only build the image"
    echo "  $0 --no-test          # Build and push without testing"
}

# Main execution
main() {
    local BUILD_ONLY=false
    local PUSH_ONLY=false
    local NO_TEST=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --build-only)
                BUILD_ONLY=true
                shift
                ;;
            --push-only)
                PUSH_ONLY=true
                shift
                ;;
            --no-test)
                NO_TEST=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_status "Starting Docker build and push process for ${FULL_IMAGE_NAME}"
    
    # Check prerequisites
    check_docker
    
    if [ "$PUSH_ONLY" = false ]; then
        check_docker_login
    fi
    
    # Build image
    if [ "$PUSH_ONLY" = false ]; then
        build_image
        
        # Test image
        if [ "$NO_TEST" = false ]; then
            test_image
        else
            print_warning "Skipping image testing"
        fi
    else
        print_warning "Skipping build process"
    fi
    
    # Push image
    if [ "$BUILD_ONLY" = false ]; then
        push_image
    else
        print_warning "Skipping push process"
    fi
    
    print_success "Process completed successfully!"
    print_status "You can now run your container with:"
    print_status "docker run -p 5555:5555 ${FULL_IMAGE_NAME}"
}

# Run main function with all arguments
main "$@"
