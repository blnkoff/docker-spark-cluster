#!/bin/bash

# Build base images for Spark cluster
# This script must be run before docker-compose up
# Usage: 
#   ./build-base-images.sh         - build standard version
#   ./build-base-images.sh aws     - build AWS-enabled version

set -e

BUILD_VARIANT=${1:-""}
SPARK_VERSION=3.5.7
HADOOP_VERSION=3

if [ "$BUILD_VARIANT" = "aws" ]; then
    TAG_SUFFIX="-aws"
    echo "Building AWS-enabled variant with S3 support..."
else
    TAG_SUFFIX=""
    echo "Building standard variant..."
fi

echo "Building base image..."
docker build \
  --progress=plain \
  -t base:latest \
  -f build/docker/base/Dockerfile \
  build/

echo "Building spark-base image${TAG_SUFFIX}..."
docker build \
  --progress=plain \
  --build-arg spark_version=${SPARK_VERSION} \
  --build-arg hadoop_version=${HADOOP_VERSION} \
  --build-arg build_variant=${BUILD_VARIANT} \
  -t spark-base:latest${TAG_SUFFIX} \
  -f build/docker/spark-base/Dockerfile \
  build/

echo ""
echo "================================"
echo "✅ Base images built successfully!"
echo "================================"
if [ "$BUILD_VARIANT" = "aws" ]; then
    echo "Image tag: spark-base:latest-aws"
    echo "AWS libraries included for S3 support"
else
    echo "Image tag: spark-base:latest"
fi
echo ""
echo "You can now run: docker-compose up"