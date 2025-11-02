#!/bin/bash

# Script to push Docker Spark Cluster images to Docker Hub
# Usage: ./push-to-dockerhub.sh blnkoff

set -e

# Check if username is provided
if [ -z "$1" ]; then
    echo "Error: Docker Hub username is required"
    echo "Usage: ./push-to-dockerhub.sh blnkoff"
    exit 1
fi

DOCKERHUB_USERNAME=$1
VERSION=${2:-latest}

echo "================================"
echo "Docker Hub Push Script"
echo "Username: $DOCKERHUB_USERNAME"
echo "Version: $VERSION"
echo "================================"
echo ""

# Check if user is logged in
echo "Checking Docker Hub authentication..."
if ! docker info | grep -q "Username"; then
    echo "You are not logged in to Docker Hub."
    echo "Please login:"
    docker login
else
    echo "Already logged in to Docker Hub"
fi

echo ""
echo "Step 1: Building all images..."
echo "================================"

# Build base images first
echo "Building base image..."
docker build \
  --progress=plain \
  -t base:latest \
  -f build/docker/base/Dockerfile \
  build/

echo "Building spark-base image..."
docker build \
  --progress=plain \
  --build-arg spark_version=3.5.7 \
  --build-arg hadoop_version=3 \
  -t spark-base:latest \
  -f build/docker/spark-base/Dockerfile \
  build/

# Build application images
echo "Building jupyterlab image..."
docker build \
  --build-arg spark_version=3.5.7 \
  --build-arg jupyterlab_version=4.3.3 \
  -t jupyterlab:latest \
  -f build/docker/jupyterlab/Dockerfile \
  build/

echo "Building spark-master image..."
docker build \
  --build-arg spark_version=3.5.7 \
  -t spark-master:latest \
  -f build/docker/spark-master/Dockerfile \
  build/

echo "Building spark-worker image..."
docker build \
  --build-arg spark_version=3.5.7 \
  -t spark-worker:latest \
  -f build/docker/spark-worker/Dockerfile \
  build/

echo ""
echo "Step 2: Tagging images with Docker Hub username..."
echo "================================"

# Tag application images only (base images are kept locally as dependencies)
docker tag jupyterlab:latest $DOCKERHUB_USERNAME/spark-jupyter:$VERSION
docker tag spark-master:latest $DOCKERHUB_USERNAME/spark-master:$VERSION
docker tag spark-worker:latest $DOCKERHUB_USERNAME/spark-worker:$VERSION

# Also tag as latest
if [ "$VERSION" != "latest" ]; then
    docker tag jupyterlab:latest $DOCKERHUB_USERNAME/spark-jupyter:latest
    docker tag spark-master:latest $DOCKERHUB_USERNAME/spark-master:latest
    docker tag spark-worker:latest $DOCKERHUB_USERNAME/spark-worker:latest
fi

echo "Images tagged successfully!"
echo ""
echo "Step 3: Pushing images to Docker Hub..."
echo "================================"

# Push application images only
echo "Pushing spark-jupyter:$VERSION..."
docker push $DOCKERHUB_USERNAME/spark-jupyter:$VERSION

echo "Pushing spark-master:$VERSION..."
docker push $DOCKERHUB_USERNAME/spark-master:$VERSION

echo "Pushing spark-worker:$VERSION..."
docker push $DOCKERHUB_USERNAME/spark-worker:$VERSION

# Push latest tags if version is not latest
if [ "$VERSION" != "latest" ]; then
    echo "Pushing latest tags..."
    docker push $DOCKERHUB_USERNAME/spark-jupyter:latest
    docker push $DOCKERHUB_USERNAME/spark-master:latest
    docker push $DOCKERHUB_USERNAME/spark-worker:latest
fi

echo ""
echo "================================"
echo "✅ All images pushed successfully!"
echo "================================"
echo ""
echo "Your images on Docker Hub:"
echo "  - $DOCKERHUB_USERNAME/spark-jupyter:$VERSION"
echo "  - $DOCKERHUB_USERNAME/spark-master:$VERSION"
echo "  - $DOCKERHUB_USERNAME/spark-worker:$VERSION"
echo ""
echo "Note: Base images (base, spark-base) are kept locally as build dependencies."
echo ""
echo "View your images at: https://hub.docker.com/u/$DOCKERHUB_USERNAME"

