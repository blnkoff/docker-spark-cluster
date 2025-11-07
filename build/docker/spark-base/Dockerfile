FROM base

ARG spark_version
ARG hadoop_version
ARG build_variant=""

RUN curl https://archive.apache.org/dist/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz -o spark.tgz && \
    tar -xf spark.tgz && \
    mv spark-${spark_version}-bin-hadoop${hadoop_version} /usr/bin/ && \
    echo "alias pyspark=/usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/bin/pyspark" >> ~/.bashrc && \
    echo "alias spark-shell=/usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/bin/spark-shell" >> ~/.bashrc && \
    mkdir /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/logs && \
    rm spark.tgz

ENV SPARK_HOME /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3

# Conditional installation of AWS libraries for S3 support
RUN if [ "$build_variant" = "aws" ]; then \
        echo "Installing AWS libraries for S3 support..." && \
        curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar \
            -o ${SPARK_HOME}/jars/hadoop-aws-3.3.4.jar && \
        curl -L https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar \
            -o ${SPARK_HOME}/jars/aws-java-sdk-bundle-1.12.262.jar && \
        echo "AWS libraries installed successfully"; \
    else \
        echo "Building standard version without AWS support"; \
    fi

WORKDIR ${SPARK_HOME}