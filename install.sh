#!/bin/bash

# XXG-KAMI-PRO 一键安装脚本
# 作者: xiaoxiaoguai-yyds

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}请使用 root 权限运行此脚本${NC}"
  exit 1
fi

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}        XXG-KAMI-PRO 一键部署脚本 v1.0          ${NC}"
echo -e "${BLUE}================================================${NC}"

# 0. 环境选择 (Dev/Prod)
echo -e "${YELLOW}[0/8] 环境选择...${NC}"
read -p "请选择部署环境 (1. prod-生产环境 [默认], 2. dev-开发环境): " ENV_CHOICE
if [ "$ENV_CHOICE" == "2" ]; then
    DEPLOY_ENV="dev"
    echo -e "${GREEN}已选择: 开发环境 (dev)${NC}"
else
    DEPLOY_ENV="prod"
    echo -e "${GREEN}已选择: 生产环境 (prod)${NC}"
fi

# 1. 网络检测与 Git 源选择
echo -e "${YELLOW}[1/8] 检测网络环境...${NC}"
if curl -s --connect-timeout 5 https://www.google.com > /dev/null; then
    echo -e "${GREEN}检测到国外网络环境，使用 GitHub 源${NC}"
    GIT_REPO="https://github.com/xiaoxiaoguai-yyds/xxgkami-pro.git"
else
    echo -e "${GREEN}检测到国内网络环境，使用 Gitee 源${NC}"
    GIT_REPO="https://gitee.com/xxg-yyds/xxgkami-pro.git"
fi

# 2. 系统检测与基础依赖安装 (MySQL 8.0+)
echo -e "${YELLOW}[2/8] 安装基础依赖 (MySQL 8.0+, JDK 17, Node 18, Nginx)...${NC}"

install_mysql8_debian() {
    # 检查是否已安装 MySQL 8
    if dpkg -l | grep -q "mysql-server"; then
        MYSQL_VER=$(mysql --version | awk '{print $5}' | awk -F, '{print $1}')
        if [[ "$MYSQL_VER" == 8.* ]]; then
            echo -e "${GREEN}MySQL $MYSQL_VER 已安装${NC}"
            return
        fi
    fi
    
    echo -e "${YELLOW}配置 MySQL 8.0 源...${NC}"
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.28-1_all.deb
    DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.28-1_all.deb
    apt-get update
    apt-get install -y mysql-server
}

install_mysql8_rhel() {
    if rpm -qa | grep -q "mysql-community-server"; then
        echo -e "${GREEN}MySQL 已安装${NC}"
        return
    fi
    
    echo -e "${YELLOW}配置 MySQL 8.0 源...${NC}"
    rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm
    yum --enablerepo=mysql80-community install -y mysql-community-server
    systemctl start mysqld
    systemctl enable mysqld
    
    # 获取临时密码
    TEMP_PASS=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
    echo -e "${YELLOW}MySQL 初始临时密码: $TEMP_PASS${NC}"
    echo -e "${YELLOW}请务必在脚本运行后尽快修改密码!${NC}"
}

if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu
    apt-get update
    apt-get install -y git curl wget unzip nginx openjdk-17-jdk maven
    
    # MySQL 8.0
    install_mysql8_debian
    
    # Node.js 18.x
    if ! node -v | grep -q "v18"; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
        apt-get install -y nodejs
    fi
elif [ -f /etc/redhat-release ]; then
    # CentOS/RHEL
    yum install -y git curl wget unzip nginx java-17-openjdk-devel maven
    
    # MySQL 8.0
    install_mysql8_rhel
    
    # Node.js 18.x
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs
else
    echo -e "${RED}不支持的操作系统，请手动安装依赖${NC}"
    exit 1
fi

# 验证安装
java -version
mvn -version
node -v
npm -v
mysql --version

# 3. 克隆/更新项目
echo -e "${YELLOW}[3/8] 下载项目源码...${NC}"
INSTALL_DIR="/var/www/xxgkami-pro"

if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}项目目录已存在，尝试更新...${NC}"
    cd $INSTALL_DIR
    git pull
else
    git clone $GIT_REPO $INSTALL_DIR
    cd $INSTALL_DIR
fi

# 4. 数据库配置
echo -e "${YELLOW}[4/8] 配置数据库...${NC}"
DB_NAME="kami"
DB_USER="root"
# 获取数据库密码
read -p "请输入 MySQL root 密码: " DB_PASSWORD

# 创建数据库并导入数据
SQL_FILE="$INSTALL_DIR/databaes/kami.sql"

if [ -f "$SQL_FILE" ]; then
    echo -e "${GREEN}正在导入数据库...${NC}"
    mysql -u$DB_USER -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;"
    mysql -u$DB_USER -p"$DB_PASSWORD" $DB_NAME < $SQL_FILE
else
    echo -e "${RED}错误：找不到数据库文件 $SQL_FILE${NC}"
    # 尝试查找其他位置
    if [ -f "$INSTALL_DIR/database/kami.sql" ]; then
        mysql -u$DB_USER -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;"
        mysql -u$DB_USER -p"$DB_PASSWORD" $DB_NAME < "$INSTALL_DIR/database/kami.sql"
    fi
fi

# 修改后端配置
APP_PROP="$INSTALL_DIR/backend/src/main/resources/application.properties"
if [ -f "$APP_PROP" ]; then
    sed -i "s/spring.datasource.password=.*/spring.datasource.password=$DB_PASSWORD/" $APP_PROP
    sed -i "s/spring.datasource.username=.*/spring.datasource.username=$DB_USER/" $APP_PROP
fi

# 5. 编译后端
echo -e "${YELLOW}[5/8] 编译后端服务...${NC}"
cd $INSTALL_DIR/backend
mvn clean package -DskipTests

# 创建系统服务 (支持开机自启)
SERVICE_FILE="/etc/systemd/system/xxgkami.service"
JAR_FILE=$(find target -name "backend-*.jar" | head -n 1)
ABS_JAR_PATH="$INSTALL_DIR/backend/$JAR_FILE"

# 根据环境设置 Profile
JAVA_OPTS="-Dspring.profiles.active=$DEPLOY_ENV"

cat > $SERVICE_FILE <<EOF
[Unit]
Description=XXG-KAMI-PRO Backend Service
After=syslog.target network.target mysql.service

[Service]
User=root
ExecStart=/usr/bin/java $JAVA_OPTS -jar $ABS_JAR_PATH
SuccessExitStatus=143
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable xxgkami
systemctl restart xxgkami
echo -e "${GREEN}后端服务已配置并启动 (开机自启)${NC}"

# 6. 编译前端并部署到 Nginx
echo -e "${YELLOW}[6/8] 编译前端页面...${NC}"
cd $INSTALL_DIR
# 安装依赖
npm install --registry=https://registry.npmmirror.com
# 构建 (支持多环境)
if [ "$DEPLOY_ENV" == "dev" ]; then
    # 假设 package.json 中有 build:dev，如果没有则使用默认 build
    if grep -q "build:dev" package.json; then
        npm run build:dev
    else
        npm run build
    fi
else
    npm run build
fi

# 部署到 Nginx 标准目录
NGINX_WEB_ROOT="/usr/share/nginx/html"
# 备份原有文件
if [ -d "$NGINX_WEB_ROOT" ]; then
    mv $NGINX_WEB_ROOT "${NGINX_WEB_ROOT}_backup_$(date +%s)"
fi
mkdir -p $NGINX_WEB_ROOT
cp -r $INSTALL_DIR/dist/* $NGINX_WEB_ROOT/
echo -e "${GREEN}前端静态文件已部署到 $NGINX_WEB_ROOT${NC}"

# 7. 配置 Nginx
echo -e "${YELLOW}[7/8] 配置 Nginx...${NC}"
NGINX_CONF="/etc/nginx/conf.d/xxgkami.conf"

cat > $NGINX_CONF <<EOF
server {
    listen 80;
    server_name localhost;

    # 前端静态文件 (指向标准目录)
    location / {
        root $NGINX_WEB_ROOT;
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }

    # 后端 API 代理
    location /api {
        proxy_pass http://localhost:8080/api;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # 上传文件路径映射
    location /uploads {
        alias $INSTALL_DIR/backend/uploads;
    }
}
EOF

# 检查 Nginx 配置并重启
nginx -t
systemctl enable nginx
systemctl restart nginx

# 8. 健康检查
echo -e "${YELLOW}[8/8] 执行健康检查...${NC}"
sleep 10 # 等待服务启动

# 检查后端 API
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/auth/login)
if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "401" ]] || [[ "$HTTP_CODE" == "405" ]]; then
    echo -e "${GREEN}[成功] 后端服务响应正常 (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}[失败] 后端服务响应异常 (HTTP $HTTP_CODE)${NC}"
    echo -e "请检查日志: journalctl -u xxgkami -n 50"
fi

# 检查前端页面
HTTP_CODE_WEB=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [[ "$HTTP_CODE_WEB" == "200" ]]; then
    echo -e "${GREEN}[成功] 前端页面访问正常${NC}"
else
    echo -e "${RED}[失败] 前端页面访问异常 (HTTP $HTTP_CODE_WEB)${NC}"
fi

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}      部署流程结束      ${NC}"
echo -e "${BLUE}================================================${NC}"
echo -e "访问地址: http://$(curl -s ifconfig.me)"
echo -e "后端服务状态: systemctl status xxgkami"
echo -e "Nginx状态: systemctl status nginx"
