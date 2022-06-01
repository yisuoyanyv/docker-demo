FROM openjdk:8-alpine

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_MASTER_LOG /spark/logs
ENV SPARK_WORKER_LOG /spark/logs
ENV SPARK_VERSION 3.2.1


##---


# 工具类
RUN apk --update --no-cache add \
        wget tar bash
# Spark 压缩包下载   spark的版本根据需求选择 可带hadoop或不带hadoop  bin-hadoop2.7.tgz  bin-without-hadoop.tgz bin-hadoop3.2.tgz
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz

# 解压并删除多余压缩包
RUN tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.2.tgz   && \
    mv spark-${SPARK_VERSION}-bin-hadoop3.2   /spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.2.tgz 

# 复制环境变量
COPY bashrc /root/.bashrc
# 复制启动脚本(包括启动Master和Worker)到容器根目录
COPY scripts/* /

# 暴露端口
EXPOSE 8080 7077 6066

# 默认启动 Spark-shell 暂不开启
# ENTRYPOINT ["/start-shell.sh"]