# Spark Base Image

This is the base image for Apache Spark with optional AWS S3 support.

## Image Variants

### Standard Version
The standard version includes Apache Spark with Hadoop support but without AWS libraries.

**Build command:**
```bash
./build-base-images.sh
```

**Image tag:** `spark-base:latest`

### AWS-Enabled Version
The AWS-enabled version includes additional libraries for S3 support:
- `hadoop-aws-3.3.4.jar` - Hadoop AWS connector
- `aws-java-sdk-bundle-1.12.262.jar` - AWS SDK for Java

**Build command:**
```bash
./build-base-images.sh aws
```

**Image tag:** `spark-base:latest-aws`

## Usage

### Building Locally

For standard version:
```bash
cd /path/to/project
./build-base-images.sh
```

For AWS-enabled version:
```bash
cd /path/to/project
./build-base-images.sh aws
```

### Pushing to Docker Hub

For standard version:
```bash
./push-to-dockerhub.sh <your-dockerhub-username> latest
```

For AWS-enabled version:
```bash
./push-to-dockerhub.sh <your-dockerhub-username> latest aws
```

## Using S3 with Spark (AWS Variant Only)

When using the AWS-enabled variant, you can configure Spark to work with S3:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("S3 Example") \
    .config("spark.hadoop.fs.s3a.access.key", "YOUR_ACCESS_KEY") \
    .config("spark.hadoop.fs.s3a.secret.key", "YOUR_SECRET_KEY") \
    .config("spark.hadoop.fs.s3a.endpoint", "s3.amazonaws.com") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .getOrCreate()

# Read from S3
df = spark.read.csv("s3a://your-bucket/path/to/file.csv")
```

## Version Information

- **Spark Version:** 3.5.7
- **Hadoop Version:** 3
- **Hadoop AWS Library:** 3.3.4
- **AWS SDK Bundle:** 1.12.262

## Build Arguments

The Dockerfile accepts the following build arguments:

| Argument | Description | Default | Required |
|----------|-------------|---------|----------|
| `spark_version` | Apache Spark version to install | - | Yes |
| `hadoop_version` | Hadoop version (major) | - | Yes |
| `build_variant` | Build variant (`aws` for AWS support, empty for standard) | `""` | No |

## Manual Build

If you want to build the image manually:

```bash
# Standard version
docker build \
  --build-arg spark_version=3.5.7 \
  --build-arg hadoop_version=3 \
  -t spark-base:latest \
  -f build/docker/spark-base/Dockerfile \
  build/

# AWS-enabled version
docker build \
  --build-arg spark_version=3.5.7 \
  --build-arg hadoop_version=3 \
  --build-arg build_variant=aws \
  -t spark-base:latest-aws \
  -f build/docker/spark-base/Dockerfile \
  build/
```

## Environment Variables

The image sets the following environment variables:

- `SPARK_HOME`: Path to Spark installation
- `SPARK_MASTER_HOST`: Hostname of the Spark master (default: `spark-master`)
- `SPARK_MASTER_PORT`: Port of the Spark master (default: `7077`)
- `PYSPARK_PYTHON`: Python interpreter for PySpark (default: `python3`)

## Notes

- The AWS libraries are only included when building with `build_variant=aws`
- Both variants can coexist on the same system with different tags
- Base images are not pushed to Docker Hub by default; only application images (jupyterlab, spark-master, spark-worker) are pushed

