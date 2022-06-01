## minio 集群化部署
## nginx 负载均衡，转发请求到minio
## spark 集群化部署

## 参考文档：

https://www.jianshu.com/p/d6a406da3cba

## 主要命令


###  在spark-docker 目录中编译spark 镜像

```
docker build -t jinglongzh/spark:3.2.1 .
```

### spark 集群扩充spark-worker节点
```
docker-compose up --scale spark-worker=3
```
### 启动spark 测试容器
``` 
docker run --rm -it --network spark-network jinglongzh/spark:3.2.1 /bin/sh

```
### 运行官方示例
```
/spark/bin/spark-submit --master spark://spark-master:7077 --class \
    org.apache.spark.examples.SparkPi \
    /spark/examples/jars/spark-examples_2.12-3.2.1.jar 1000
```