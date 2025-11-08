#!/bin/bash

# Script to push Docker Spark Cluster images to Docker Hub
# Usage: 
#   ./push-to-dockerhub.sh <username> [version] [variant]
#   ./push-to-dockerhub.sh blnkoff latest         - standard version
#   ./push-to-dockerhub.sh blnkoff latest aws     - AWS-enabled version

set -e

# Check if username is provided
if [ -z "$1" ]; then
    echo "Error: Docker Hub username is required"
    echo "Usage: ./push-to-dockerhub.sh <username> [version] [variant]"
    echo "Examples:"
    echo "  ./push-to-dockerhub.sh blnkoff latest"
    echo "  ./push-to-dockerhub.sh blnkoff latest aws"
    exit 1
fi

DOCKERHUB_USERNAME=$1
VERSION=${2:-latest}
BUILD_VARIANT=${3:-""}

if [ "$BUILD_VARIANT" = "aws" ]; then
    TAG_SUFFIX="-aws"
    VARIANT_DESC="AWS-enabled"
else
    TAG_SUFFIX=""
    VARIANT_DESC="Standard"
fi

echo "================================"
echo "Docker Hub Push Script"
echo "Username: $DOCKERHUB_USERNAME"
echo "Version: $VERSION"
echo "Variant: $VARIANT_DESC"
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

echo "Building spark-base image${TAG_SUFFIX}..."
docker build \
  --progress=plain \
  --build-arg spark_version=3.5.7 \
  --build-arg hadoop_version=3 \
  --build-arg build_variant=${BUILD_VARIANT} \
  -t spark-base:latest${TAG_SUFFIX} \
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
  --build-arg spark_base_image=spark-base:latest${TAG_SUFFIX} \
  -t spark-master:latest \
  -f build/docker/spark-master/Dockerfile \
  build/

echo "Building spark-worker image..."
docker build \
  --build-arg spark_version=3.5.7 \
  --build-arg spark_base_image=spark-base:latest${TAG_SUFFIX} \
  -t spark-worker:latest \
  -f build/docker/spark-worker/Dockerfile \
  build/

echo ""
echo "Step 2: Tagging images with Docker Hub username..."
echo "================================"

# Tag application images only (base images are kept locally as dependencies)
docker tag jupyterlab:latest $DOCKERHUB_USERNAME/spark-jupyter:$VERSION$TAG_SUFFIX
docker tag spark-master:latest $DOCKERHUB_USERNAME/spark-master:$VERSION$TAG_SUFFIX
docker tag spark-worker:latest $DOCKERHUB_USERNAME/spark-worker:$VERSION$TAG_SUFFIX

# Also tag as latest
if [ "$VERSION" != "latest" ]; then
    docker tag jupyterlab:latest $DOCKERHUB_USERNAME/spark-jupyter:latest$TAG_SUFFIX
    docker tag spark-master:latest $DOCKERHUB_USERNAME/spark-master:latest$TAG_SUFFIX
    docker tag spark-worker:latest $DOCKERHUB_USERNAME/spark-worker:latest$TAG_SUFFIX
fi

echo "Images tagged successfully!"
echo ""
echo "Step 3: Pushing images to Docker Hub..."
echo "================================"

# Push application images only
echo "Pushing spark-jupyter:$VERSION$TAG_SUFFIX..."
docker push $DOCKERHUB_USERNAME/spark-jupyter:$VERSION$TAG_SUFFIX

echo "Pushing spark-master:$VERSION$TAG_SUFFIX..."
docker push $DOCKERHUB_USERNAME/spark-master:$VERSION$TAG_SUFFIX

echo "Pushing spark-worker:$VERSION$TAG_SUFFIX..."
docker push $DOCKERHUB_USERNAME/spark-worker:$VERSION$TAG_SUFFIX

# Push latest tags if version is not latest
if [ "$VERSION" != "latest" ]; then
    echo "Pushing latest$TAG_SUFFIX tags..."
    docker push $DOCKERHUB_USERNAME/spark-jupyter:latest$TAG_SUFFIX
    docker push $DOCKERHUB_USERNAME/spark-master:latest$TAG_SUFFIX
    docker push $DOCKERHUB_USERNAME/spark-worker:latest$TAG_SUFFIX
fi

echo ""
echo "================================"
echo "✅ All images pushed successfully!"
echo "================================"
echo ""
echo "Your images on Docker Hub:"
echo "  - $DOCKERHUB_USERNAME/spark-jupyter:$VERSION$TAG_SUFFIX"
echo "  - $DOCKERHUB_USERNAME/spark-master:$VERSION$TAG_SUFFIX"
echo "  - $DOCKERHUB_USERNAME/spark-worker:$VERSION$TAG_SUFFIX"
if [ "$BUILD_VARIANT" = "aws" ]; then
    echo ""
    echo "✅ AWS-enabled variant includes S3 support (hadoop-aws & aws-java-sdk-bundle)"
fi
echo ""
echo "Note: Base images (base, spark-base$TAG_SUFFIX) are kept locally as build dependencies."
echo ""
echo "View your images at: https://hub.docker.com/u/$DOCKERHUB_USERNAME"

