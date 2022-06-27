# 背景

找来找去都没找到简单方便的部署yapi到k8s的教程，就自己写了个；

**本教程部署的版本是: 1.10.2** 



# 部署步骤

克隆仓库：

```
git clone https://github.com/gebiWangshushu/hei-yapi-k8s-deploy.git
```



## 第一步 部署MongoDB

> 如果已有MongoDB请跳过这步

## 先创建命名空间

```
kubectl create ns yapi
```



## 创建pv的Secret

```
kubectl create secret generic mongo-azure-secret --from-literal=azurestorageaccountname=<blobAccountName> --from-literal=azurestorageaccountkey=<blobAccountKey> -n yapi
```

> 如果大家不是很清楚什么是pv/pvc 的需要先去了解下；



# 创建pv/pvc

```
kubectl apply -f mogon-pv.yaml
```

> 我这里是挂载到azure blob file share，大家可以改为挂载到自己喜欢的地方；



## 部署mongo

```
kubectl apply -f mogon.yaml
```



**验证mongo部署**

用端口转发访问mongo

https://kubernetes.io/zh-cn/docs/tasks/access-application-cluster/port-forward-access-application-cluster/

```
kubectl get deployment

kubectl port-forward deployment/mongodb 27017:27017

这样就可以用 mongodb://127.0.0.1:27017 连接到mongo了
```





# 第二步 部署Yapi构建程序

```
kubectl apply -f yapi.yaml
```





# 第三步 开始部署Yapi



### 方式一 使用WebUI部署(推荐)

需要service为NodePort(也可以用kubectl port-forward)，打开：集群ip:<nodeport> 可看到：

## ![1656343915360](images/641760-20220627233206600-238122206-1656344177764.png)

填好配置后看“开始部署“按钮即可，这种简单方便且是官方推荐方式；



### 方式二 其他方式(只是思路)

参考：https://hellosean1025.github.io/yapi/devops/index.html

1、先准备环境

```
进入pod:
mkdir yapi
cd yapi

wget https://github.91chi.fun//https://github.com/YMFE/yapi/archive/refs/heads/master.zip

unzip master.zip

vm yapi-master venders

cp vendors/config_example.json ./config.json //复制完成后请修改相关配置
cd vendors
rm package-lock.json #这个不删会导致安装失败
```



2、准备配置

替换配置：config.json的值：

```
{
    "port": "3000",
    "adminAccount": "admin@admin.com",
    "timeout": 120000,
    "db": {
      "servername": "127.0.0.1",
      "DATABASE": "yapi",
      "port": 27017,
      "user": "test1",
      "pass": "test1",
      "authSource": ""
    },
    "mail": {
      "enable": true,
      "host": "smtp.163.com",
      "port": 465,
      "from": "***@163.com",
      "auth": {
        "user": "***@163.com",
        "pass": "*****"
      }
    }
}
```

替换脚本

```
sed -i 's/\"adminAccount\": \"admin@admin.com\"/\"adminAccount\": '\"${YAPI_ADMIN_ACCOUNT}\"'/g' config.json
sed -i 's/\"servername\": \"127.0.0.1\"/\"servername\": '\"${YAPI_DB_SERVERNAME}\"'/g' config.json
sed -i 's/\"DATABASE\": \"yapi\"/\"DATABASE\": '\"${YAPI_DB_DATABASE}\"'/g' config.json
sed -i 's/\"user\": \"test1\"/\"user\": '\"${YAPI_DB_USER}\"'/g' config.json
sed -i 's/\"pass\": \"test1\"/\"pass\": '\"${YAPI_DB_PASS}\"'/g' config.json
sed -i 's/\"authSource\": \"\"/\"authSource\": '\"${YAPI_DB_AUTH_SOURCE}\"'/g' config.json
sed -i 's/\"host\": \"smtp.163.com\"/\"host\": '\"${YAPI_MAIL_HOST}\"'/g' config.json
sed -i 's/\"from\": \"\*\*\*@163.com\"/\"from\": '\"${YAPI_MAIL_FROM}\"'/g' config.json
sed -i 's/\"user\": \"\*\*\*@163.com\"/\"user\": '\"${YAPI_MAIL_AUTH}\"'/g' config.json
sed -i 's/\"pass\": \"\*\*\*\*\*\"/\"pass\": '\"${YAPI_MAIL_PASS}\"'/g' config.json
#defual
sed -i 's/\"port\": \"3000\"/\"port\": '${YAPI_PORT:-3000}'/g' config.json
sed -i 's/\"port\": 27017/\"port\": '${YAPI_DB_PORT:-27017}'/g' config.json
sed -i 's/\"enable\": true/\"enable\": '${YAPI_MAIL_ENABlE:-false}'/g' config.json
sed -i 's/\"port\": 465/\"port\": '${YAPI_MAIL_PORT:-465}'/g' config.json
```



3、启动程序

```
npm install --production --registry https://registry.npm.taobao.org
npm run install-server //安装程序会初始化数据库索引和管理员账号，管理员账号名可在 config.json 配置
node server/app.js //启动服务器后，请访问 127.0.0.1:{config.json配置的端口}，初次运行会有个编译的过程，请耐心等候
```



# 源码

https://github.com/gebiWangshushu/hei-yapi-k8s-deploy