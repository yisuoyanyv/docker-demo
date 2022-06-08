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
network的名称根据实际名称填写，用`docker network ls` 命令查看
``` 
docker run --rm -it --network docker_spark-network jinglongzh/spark:3.2.1 /bin/sh

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

## 使用spark-shell读取MinIO存储
执行如下命令，打开spark-shell,连接minio
```
./bin/spark-shell \
--conf spark.hadoop.fs.s3a.endpoint=http://192.168.1.6:9000 \
--conf spark.hadoop.fs.s3a.access.key=minio \
--conf spark.hadoop.fs.s3a.secret.key=minio123 \
--conf spark.hadoop.fs.s3a.path.style.access=true \
--conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem
```

执行如下命令读取MinIO存储
```
val b1 = sc.textFile("s3a://spark-test/test.json")
b1.collect().foreach(println)
```

碰到的错误：
```
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.2.1
      /_/

Using Scala version 2.12.15 (OpenJDK 64-Bit Server VM, Java 1.8.0_212)
Type in expressions to have them evaluated.
Type :help for more information.

scala> val b1=sc.textFile("s3a://spark-test/test.json")
b1: org.apache.spark.rdd.RDD[String] = s3a://spark-test/test.json MapPartitionsRDD[1] at textFile at <console>:23

scala> b1.collect().foreach(println)
java.lang.NoClassDefFoundError: com/amazonaws/services/s3/model/MultiObjectDeleteException
  at java.lang.Class.forName0(Native Method)
  at java.lang.Class.forName(Class.java:348)
  at org.apache.hadoop.conf.Configuration.getClassByNameOrNull(Configuration.java:2604)
  at org.apache.hadoop.conf.Configuration.getClassByName(Configuration.java:2569)
  at org.apache.hadoop.conf.Configuration.getClass(Configuration.java:2665)
  at org.apache.hadoop.fs.FileSystem.getFileSystemClass(FileSystem.java:3431)
  at org.apache.hadoop.fs.FileSystem.createFileSystem(FileSystem.java:3466)
  at org.apache.hadoop.fs.FileSystem.access$300(FileSystem.java:174)

```
解决方案：
https://www.it1352.com/2614133.html

新增了依赖包：dependencies\aws-java-sdk-bundle-1.12.231.jar，上传到spark 的jars中，重新开启spark-shell 执行，成功！


## 集成icerberg
先拷贝依赖的jar包到dependencies目录，上传到spark的jars：
- \dependencies\iceberg-spark-runtime-3.2_2.12-0.13.1.jar
- \dependencies\iceberg-spark3-runtime-0.13.1.jar



执行如下命令，打开spark-shell,连接minio，**集成iceberg**
```
完整
./bin/spark-shell \
--conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
--conf spark.sql.catalog.demo=org.apache.iceberg.spark.SparkCatalog \
--conf spark.sql.catalog.demo.type=hadoop \
--conf spark.sql.catalog.demo.io-impl=org.apache.iceberg.aws.s3.S3FileIO \
--conf spark.sql.catalog.demo.warehouse=s3://spark-test/ \
--conf spark.sql.catalog.demo.s3.endpoint=http://192.168.1.6:9000\
--conf spark.hadoop.fs.s3a.endpoint=http://192.168.1.6:9000 \
--conf spark.hadoop.fs.s3a.access.key=minio \
--conf spark.hadoop.fs.s3a.secret.key=minio123 \
--conf spark.hadoop.fs.s3a.path.style.access=true \
--conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \

```

```
测试
./bin/spark-sql \
--conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
--conf spark.sql.catalog.demo=org.apache.iceberg.spark.SparkCatalog \
--conf spark.sql.catalog.demo.type=hadoop \
--conf spark.sql.catalog.demo.io-impl=org.apache.iceberg.hadoop.HadoopFileIO  \
--conf spark.sql.catalog.demo.warehouse=s3a://spark-test/ \
--conf spark.sql.catalog.demo.s3.endpoint=http://192.168.1.6:9000


```
back 
--conf spark.sql.sources.partitionOverwriteMode=dynamic \

--conf spark.sql.catalog.demo.io-impl=org.apache.iceberg.aws.s3.S3FileIO \

--conf spark.hadoop.fs.s3a.endpoint=http://192.168.1.6:9000 \
--conf spark.hadoop.fs.s3a.access.key=minio \
--conf spark.hadoop.fs.s3a.secret.key=minio123 \
--conf spark.hadoop.fs.s3a.path.style.access=true \
--conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \

```

建表测试：
```sql

CREATE TABLE demo.db.sample (
    id bigint COMMENT 'unique id',
    data string)
USING iceberg



```

```scala
spark.sql("CREATE TABLE demo.db.table (id bigint, data string) USING iceberg")

spark.sql("CREATE TABLE demo.db.table1 (id bigint, data string) USING iceberg location 's3a:///spark_test/db/table1'")


spark.sql("CREATE TABLE demo.db.table (id bigint, data string) USING iceberg")

```

## 参考文档：
[在Docker上一键部署你的Spark计算平台](https://www.jianshu.com/p/d6a406da3cba)

[基于Docker部署Spark和MinIO Server](https://www.jianshu.com/p/aaa797181c2d)

[Using Iceberg's S3FileIO Implementation to Store Your Data in MinIO](https://tabular.io/blog/minio/)


[Spark、lceberg、Minio 集成环境搭建](https://www.xianyuew.com/kxjs/8458372.html)