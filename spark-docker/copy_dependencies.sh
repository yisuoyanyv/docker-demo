#!/bin/bash
SPARK_MASTER="spark-master"
SPARK_WORKER="spark-worker"

docker cp ./dependencies/. ${SPARK_MASTER}:/spark/jars
docker cp ./dependencies/. ${SPARK_WORKER}:/spark/jars
