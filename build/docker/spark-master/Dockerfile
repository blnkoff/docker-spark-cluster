ARG spark_base_image=spark-base:latest

FROM ${spark_base_image}

EXPOSE 8080 7077

CMD bin/spark-class org.apache.spark.deploy.master.Master >> logs/spark-master.out
