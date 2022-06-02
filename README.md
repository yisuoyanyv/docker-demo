## 目前集成的样例
 - minio 集群化部署
 - nginx 负载均衡，转发请求到minio
 - spark 集群化部署


## 主要命令


###  在spark-docker 目录中编译spark 镜像

```
docker build -t jinglongzh/spark:3.2.1 .
```

### spark 集群扩充spark-worker节点 及启动命令
```
docker-compose up --scale spark-worker=3 -d
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

### 访问spark 控制台页面
http://localhost:8080/

### 访问minio 集群
http://localhost:9001/
账号密码：minio/minio123

### 配置minio 客户端，上传文件测试

使用客户端连接minio 服务端
创建名为spark-test的bucket
并上传测试文件
```
mc config host add myminio http://192.168.1.6:9000 minio minio123
mc mb myminio/spark-test
mc cp test.json myminio/spark-test/test.json


```
执行mc ls myminio 报错
```
sh-4.4# mc ls myminio
mc: <ERROR> Unable to list folder. The request signature we calculated does not match the signature you provided. Check your key and signing method.
```
## Spark读写MinIO存储

## 配置Spark集群
Spark访问MinIO存储需要一些依赖包
放置在了dependencies文件夹下
并配置了copy_dependencies.sh文件，将依赖包copy到spark 集群的jar包



## 参考文档：
在Docker上一键部署你的Spark计算平台
https://www.jianshu.com/p/d6a406da3cba

基于Docker部署Spark和MinIO Server
https://www.jianshu.com/p/aaa797181c2d

