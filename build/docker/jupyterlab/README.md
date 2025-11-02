# Spark JupyterLab

JupyterLab with PySpark integration for interactive development and data analysis with Apache Spark.

## Quick Start

```bash
docker pull blnkoff/spark-jupyter:latest
```

## Description

This Docker image provides a fully configured JupyterLab environment with PySpark support, designed to work seamlessly with the Docker Spark Cluster. It allows you to run interactive Spark jobs, perform data analysis, and develop distributed applications using Jupyter notebooks.

## Features

- **JupyterLab 4.3.3** - Modern web-based interactive development environment
- **PySpark 3.5.7** - Python API for Apache Spark
- **Python 3.13** - Latest Python runtime
- **Pre-configured** - Ready to connect to Spark cluster out of the box
- **Shared Workspace** - Persistent volume for notebooks and data

## Usage

### Standalone

```bash
docker run -p 8888:8888 -v $(pwd)/workspace:/opt/workspace blnkoff/spark-jupyter:latest
```

Access JupyterLab at: http://localhost:8888

### With Spark Cluster

This image is designed to be used with the complete Docker Spark Cluster. See the [docker-spark-cluster](https://github.com/blnkoff/docker-spark-cluster) repository for the full setup.

Example `docker-compose.yml`:

```yaml
version: "3.8"

services:
  jupyterlab:
    image: blnkoff/spark-jupyter:latest
    container_name: jupyterlab
    ports:
      - "8888:8888"
      - "4040:4040"
    volumes:
      - ./workspace:/opt/workspace
    networks:
      - spark-network

  spark-master:
    image: blnkoff/spark-master:latest
    container_name: spark-master
    ports:
      - "8080:8080"
      - "7077:7077"
    networks:
      - spark-network

  spark-worker-1:
    image: blnkoff/spark-worker:latest
    container_name: spark-worker-1
    environment:
      - SPARK_WORKER_CORES=1
      - SPARK_WORKER_MEMORY=1g
    ports:
      - "8081:8081"
    networks:
      - spark-network

networks:
  spark-network:
    driver: bridge
```

### Connecting to Spark Cluster

In your Jupyter notebook:

```python
from pyspark.sql import SparkSession

spark = (
    SparkSession
    .builder
    .appName("MyApp")
    .master("spark://spark-master:7077")
    .config("spark.submit.deployMode", "client")
    .config("spark.driver.host", "jupyterlab")
    .getOrCreate()
)

# Your Spark code here
df = spark.read.csv("/opt/workspace/data/mydata.csv", header=True)
df.show()

spark.stop()
```

## Exposed Ports

- **8888** - JupyterLab web interface
- **4040** - Spark application UI (active when running Spark jobs)

## Environment Variables

- `SHARED_WORKSPACE` - Path to shared workspace directory (default: `/opt/workspace`)

## Volumes

- `/opt/workspace` - Mount your notebooks and data files here

## Build Arguments

- `spark_version` - Apache Spark version (default: `3.5.7`)
- `jupyterlab_version` - JupyterLab version (default: `4.3.3`)

## Base Image

Built on top of the `base` image which includes:
- OpenJDK 17
- Python 3.13
- R base

## GitHub Repository

Full source code and documentation: [docker-spark-cluster](https://github.com/blnkoff/docker-spark-cluster)

## License

See the [repository](https://github.com/blnkoff/docker-spark-cluster) for license information.

## Related Images

- [spark-master](https://hub.docker.com/r/blnkoff/spark-master) - Spark cluster master node
- [spark-worker](https://hub.docker.com/r/blnkoff/spark-worker) - Spark cluster worker node

