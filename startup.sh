#!/bin/sh 

#初始化环境
mkdir yapi && cd yapi

wget https://github.com/YMFE/yapi/archive/refs/heads/master.zip #如果服务器访问不了github自己找个镜像
unzip master.zip
mv yapi-master vendors
cp vendors/config_example.json ./config.json

#复制完成后替换相关配置
sed -i "2 a  \"closeRegister\":${CLOSE_REGISTER:-false}," config.json
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

#启动
cd vendors
rm package-lock.json #这个不删会导致安装失败
npm install --production --registry https://registry.npm.taobao.org

#初始化账号和数据库索引，可在第一次运行时单独跑(进入容器yapi/vendors目录运行)，不然后面每次重启都因为这句卡住： UnhandledPromiseRejectionWarning: Error: 初始化管理员账号 "***@gmail.com" 失败, E11000 duplicate key error collection: yapi.user index: email_1 dup key
#npm run install-server 
node server/app.js


