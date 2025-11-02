#!/bin/bash

# Build base images for Spark cluster
# This script must be run before docker-compose up

set -e

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

echo "Base images built successfully!"
echo "You can now run: docker-compose up"