# Spark Worker

Apache Spark worker node for executing distributed computations in a Spark cluster.

## Quick Start

```bash
docker pull blnkoff/spark-worker:latest
```

## Description

This Docker image provides an Apache Spark worker node that executes tasks assigned by the Spark master. Worker nodes provide computing resources (CPU and memory) for distributed data processing. Multiple workers can be deployed to scale the cluster horizontally.

## Features

- **Apache Spark 3.5.7** - Latest stable version
- **Hadoop 3** - Distributed storage support
- **Python 3.13** - For PySpark applications
- **Java 17** - Required JDK for Spark
- **Web UI** - Built-in monitoring dashboard
- **Configurable Resources** - Adjust CPU cores and memory allocation

## Usage

### Standalone

```bash
docker run -p 8081:8081 \
  -e SPARK_MASTER_HOST=spark-master \
  -e SPARK_WORKER_CORES=2 \
  -e SPARK_WORKER_MEMORY=2g \
  blnkoff/spark-worker:latest
```

Access Web UI at: http://localhost:8081

### With Docker Compose

This image is designed to be used with the complete Docker Spark Cluster. See the [docker-spark-cluster](https://github.com/blnkoff/docker-spark-cluster) repository for the full setup.

Example `docker-compose.yml`:

```yaml
version: "3.8"

services:
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
      - SPARK_MASTER_HOST=spark-master
      - SPARK_WORKER_CORES=1
      - SPARK_WORKER_MEMORY=1g
    ports:
      - "8081:8081"
    networks:
      - spark-network
    depends_on:
      - spark-master

  spark-worker-2:
    image: blnkoff/spark-worker:latest
    container_name: spark-worker-2
    environment:
      - SPARK_MASTER_HOST=spark-master
      - SPARK_WORKER_CORES=1
      - SPARK_WORKER_MEMORY=1g
    ports:
      - "8082:8081"
    networks:
      - spark-network
    depends_on:
      - spark-master

networks:
  spark-network:
    driver: bridge
```

## Exposed Ports

- **8081** - Spark Worker Web UI

## Environment Variables

- `SPARK_MASTER_HOST` - Hostname of the master node (default: `spark-master`)
- `SPARK_MASTER_PORT` - Master port for cluster communication (default: `7077`)
- `SPARK_WORKER_CORES` - Number of CPU cores to use (recommended: 1-4)
- `SPARK_WORKER_MEMORY` - Memory allocation (recommended: 1g-4g)
- `SPARK_HOME` - Spark installation directory (default: `/usr/bin/spark-3.5.7-bin-hadoop3`)
- `PYSPARK_PYTHON` - Python executable for PySpark (default: `python3`)

## Resource Configuration

Configure worker resources using environment variables:

```yaml
environment:
  - SPARK_WORKER_CORES=2      # Number of CPU cores
  - SPARK_WORKER_MEMORY=2g    # RAM allocation
```

**Resource Planning:**
- Each worker should have at least 1 core and 1GB RAM
- Leave some resources for the host system
- Scale horizontally by adding more workers
- Monitor resource usage via the Web UI

## Monitoring

The Spark Worker Web UI provides:
- Worker status and resource usage
- Running and completed tasks
- Executor information
- Logs and metrics

Access the UI at `http://localhost:8081` after starting the container.

## Scaling the Cluster

To add more workers, simply replicate the worker service in your `docker-compose.yml`:

```yaml
spark-worker-3:
  image: blnkoff/spark-worker:latest
  container_name: spark-worker-3
  environment:
    - SPARK_MASTER_HOST=spark-master
    - SPARK_WORKER_CORES=1
    - SPARK_WORKER_MEMORY=1g
  ports:
    - "8083:8081"
  networks:
    - spark-network
  depends_on:
    - spark-master
```

## Build Arguments

- `spark_version` - Apache Spark version (default: `3.5.7`)

## Base Image

Built on top of the `spark-base` image which includes:
- Apache Spark 3.5.7 with Hadoop 3
- OpenJDK 17
- Python 3.13

## GitHub Repository

Full source code and documentation: [docker-spark-cluster](https://github.com/blnkoff/docker-spark-cluster)

## License

See the [repository](https://github.com/blnkoff/docker-spark-cluster) for license information.

## Related Images

- [spark-master](https://hub.docker.com/r/blnkoff/spark-master) - Spark cluster master node
- [spark-jupyter](https://hub.docker.com/r/blnkoff/spark-jupyter) - JupyterLab with PySpark

