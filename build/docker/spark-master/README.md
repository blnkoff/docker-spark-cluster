# Spark Master

Apache Spark master node for coordinating distributed computation across worker nodes.

## Quick Start

```bash
docker pull blnkoff/spark-master:latest
```

## Description

This Docker image provides an Apache Spark master node that coordinates the cluster and manages distributed computations. The master node is responsible for resource allocation, scheduling jobs, and monitoring worker nodes.

## Features

- **Apache Spark 3.5.7** - Latest stable version
- **Hadoop 3** - Distributed storage support
- **Python 3.13** - For PySpark applications
- **Java 17** - Required JDK for Spark
- **Web UI** - Built-in monitoring dashboard

## Usage

### Standalone

```bash
docker run -p 8080:8080 -p 7077:7077 blnkoff/spark-master:latest
```

Access Web UI at: http://localhost:8080

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
    environment:
      - SPARK_MASTER_HOST=spark-master
      - SPARK_MASTER_PORT=7077
    networks:
      - spark-network

  spark-worker:
    image: blnkoff/spark-worker:latest
    container_name: spark-worker
    environment:
      - SPARK_MASTER_HOST=spark-master
      - SPARK_WORKER_CORES=2
      - SPARK_WORKER_MEMORY=2g
    ports:
      - "8081:8081"
    networks:
      - spark-network
    depends_on:
      - spark-master

networks:
  spark-network:
    driver: bridge
```

## Exposed Ports

- **8080** - Spark Master Web UI
- **7077** - Spark Master port for cluster communication

## Environment Variables

- `SPARK_MASTER_HOST` - Hostname of the master node (default: `spark-master`)
- `SPARK_MASTER_PORT` - Port for cluster communication (default: `7077`)
- `SPARK_HOME` - Spark installation directory (default: `/usr/bin/spark-3.5.7-bin-hadoop3`)
- `PYSPARK_PYTHON` - Python executable for PySpark (default: `python3`)

## Monitoring

The Spark Master Web UI provides:
- Cluster resource overview
- Active and completed applications
- Worker node status
- Cluster metrics and statistics

Access the UI at `http://localhost:8080` after starting the container.

## Connecting Workers

Worker nodes automatically connect to the master using the URL:
```
spark://spark-master:7077
```

Make sure worker containers are on the same Docker network as the master.

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

- [spark-worker](https://hub.docker.com/r/blnkoff/spark-worker) - Spark cluster worker node
- [spark-jupyter](https://hub.docker.com/r/blnkoff/spark-jupyter) - JupyterLab with PySpark

