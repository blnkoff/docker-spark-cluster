# Docker Spark Cluster

A fully containerized Apache Spark cluster with JupyterLab for distributed data processing and interactive development.

<p align="center">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Apache_Spark_logo.svg/1200px-Apache_Spark_logo.svg.png" width="800"/>
</p>

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Access URLs](#access-urls)
- [Project Structure](#project-structure)
- [Technologies](#technologies)

## 🔍 Overview

This project provides a ready-to-use Apache Spark cluster running in Docker containers, featuring:
- **Spark Master** node for cluster coordination
- **2 Spark Workers** for distributed computation
- **JupyterLab** for interactive data analysis and development
- Pre-configured networking and volume mounts

Perfect for local development, testing, and learning distributed data processing with Apache Spark.

## 🏗️ Architecture

The cluster consists of 4 Docker containers:

| Service | Container Name | Ports | Resources |
|---------|---------------|-------|-----------|
| JupyterLab | `jupyterlab` | 8888 (UI), 4040 (Spark UI) | - |
| Spark Master | `spark-master` | 8080 (UI), 7077 (Master) | - |
| Spark Worker 1 | `spark-worker-1` | 8081 (UI) | 1 core, 1GB RAM |
| Spark Worker 2 | `spark-worker-2` | 8082 (UI) | 1 core, 1GB RAM |

**Total Cluster Capacity:** 2 cores, 2GB memory

## ✨ Features

- **Dockerized Setup** - Easy deployment with Docker Compose
- **Apache Spark 3.5.7** - Latest stable version with Hadoop 3
- **JupyterLab 4.3.3** - Modern notebook interface for development
- **Scalable Architecture** - Easy to add more worker nodes
- **Shared Workspace** - Persistent volume for notebooks and data
- **Pre-configured** - Ready to run Spark jobs out of the box

## 📦 Prerequisites

- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- At least 4GB of available RAM
- 10GB of free disk space

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/blnkoff/docker-spark-cluster
cd docker-spark-cluster
```

### 2. Download Sample Dataset (Optional)

```bash
cd build/workspace && \
mkdir -p data && \
curl -L -o data/customs_data.csv "https://huggingface.co/datasets/halltape/customs_data/resolve/main/customs_data.csv?download=true"
cd ../..
```

### 3. Start the Cluster

```bash
docker-compose up -d
```

### 4. Verify the Cluster is Running

```bash
docker-compose ps
```

All containers should be in "Up" state.

***

## 💻 Usage

### Accessing JupyterLab

1. Open your browser and navigate to: http://localhost:8888
2. Enter the token: `hello_world`
3. Open the sample notebook: `spark.ipynb`

### Running Spark Jobs in Notebooks

In JupyterLab, create a new notebook and connect to the cluster:

```python
from pyspark.sql import SparkSession

# Create Spark session connected to the cluster
spark = (
    SparkSession
    .builder
    .appName("docker-spark-cluster")
    .master("spark://spark-master:7077")
    .config("spark.submit.deployMode", "client")
    .config("spark.driver.host", "jupyterlab")
    .getOrCreate()
)

# Read the sample dataset
df = spark.read.csv("/opt/workspace/data/customs_data.csv", header=True, inferSchema=True)
df.show()

# Stop the session when done
spark.stop()
```

### Stopping the Cluster

```bash
docker-compose down
```

To remove volumes as well:

```bash
docker-compose down -v
```

## 🌐 Access URLs

Once the cluster is running, access the following web interfaces:

| Service | URL | Credentials |
|---------|-----|-------------|
| JupyterLab | http://localhost:8888 | Token: `hello_world` |
| Spark Master UI | http://localhost:8080 | - |
| Spark Worker 1 UI | http://localhost:8081 | - |
| Spark Worker 2 UI | http://localhost:8082 | - |
| Spark Application UI | http://localhost:4040 | - |

## 📁 Project Structure

```
docker-spark-cluster/
├── build/
│   ├── docker/
│   │   ├── base/              # Base Python image
│   │   ├── spark-base/        # Spark installation
│   │   ├── jupyterlab/        # JupyterLab image
│   │   ├── spark-master/      # Spark master node
│   │   └── spark-worker/      # Spark worker nodes
│   └── workspace/
│       ├── data/              # Datasets directory
│       └── spark.ipynb        # Sample notebook
├── docker-compose.yml         # Cluster configuration 
├── docker-compose.local.yml     # Cluster configuration (build locally)
├── build-base-images.sh       # Base images build script
├── push-to-dockerhub.sh       # Docker Hub push script
├── .gitignore
└── README.md
```

***

## 🛠️ Technologies

- **Apache Spark 3.5.7** - Distributed computing framework
- **Hadoop 3** - Distributed storage system
- **JupyterLab 4.3.3** - Interactive development environment
- **Python 3** - Programming language for PySpark
- **Docker** - Containerization platform
- **Docker Compose** - Multi-container orchestration

***

## 🙏 Acknowledgments

This project is based on [HalltapeSparkCluster](https://github.com/halltape/HalltapeSparkCluster) by halltape. Special thanks for the original implementation and inspiration.
