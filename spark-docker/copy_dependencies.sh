#!/bin/bash
SPARK_MASTER="spark-master"
##  spark worker的容器名称不确定，根据实际情况调整
SPARK_WORKER="docker-spark-worker-1"

docker cp ./dependencies/. ${SPARK_MASTER}:/spark/jars
docker cp ./dependencies/. ${SPARK_WORKER}:/spark/jars
