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

# 0.5 端口占用检测与防火墙提示
echo -e "${YELLOW}[0.5/8] 检测端口占用...${NC}"

check_port() {
    local port=$1
    local desc=$2
    local pid=""
    
    # 尝试检测端口占用并获取PID
    if command -v lsof >/dev/null 2>&1; then
        pid=$(lsof -t -i:$port)
    elif command -v netstat >/dev/null 2>&1; then
        pid=$(netstat -tulpn | grep ":$port " | awk '{print $7}' | cut -d '/' -f 1)
    elif command -v ss >/dev/null 2>&1; then
        pid=$(ss -lptn "sport = :$port" | grep -v State | awk '{print $6}' | cut -d',' -f2 | cut -d'=' -f2)
    fi

    if [ -n "$pid" ]; then
        echo -e "${YELLOW}警告: 端口 $port ($desc) 已被占用 (PID: $pid)。${NC}"
        read -p "是否尝试终止占用该端口的进程? (y/n): " KILL_CHOICE
        if [ "$KILL_CHOICE" == "y" ] || [ "$KILL_CHOICE" == "Y" ]; then
            kill -9 $pid
            echo -e "${GREEN}已终止进程 $pid${NC}"
            sleep 1
        else
            echo -e "${YELLOW}保留该进程，请确保它不会冲突。${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}端口 $port ($desc) 可用${NC}"
    fi
    return 0
}

check_port 80 "Nginx Web"
check_port 8080 "Backend API"
check_port 3306 "MySQL Database"

echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "${RED}重要提示: 请确保您的服务器防火墙/安全组已开放以下端口:${NC}"
echo -e "${GREEN}  - 80   (TCP) : 用于网站访问${NC}"
echo -e "${GREEN}  - 8080 (TCP) : 用于后端API服务${NC}"
echo -e "${GREEN}  - 3306 (TCP) : (可选) 如果需要远程连接数据库${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"
sleep 3

# 1. 网络检测与 Git 源选择
echo -e "${YELLOW}[1/8] 检测网络环境...${NC}"
IS_CHINA=false
if curl -s --connect-timeout 5 https://www.google.com > /dev/null; then
    echo -e "${GREEN}检测到国外网络环境，使用 GitHub 源${NC}"
    GIT_REPO="https://github.com/xiaoxiaoguai-yyds/xxgkami-pro.git"
else
    echo -e "${GREEN}检测到国内网络环境，使用 Gitee 源${NC}"
    IS_CHINA=true
    GIT_REPO="https://gitee.com/xxg-yyds/xxgkami-pro.git"
fi

# 2. 系统检测与基础依赖安装 (MySQL 8.0+, JDK 17, Node 18, Nginx)
echo -e "${YELLOW}[2/8] 安装基础依赖 (MySQL 8.0+, JDK 17, Node 18, Nginx)...${NC}"

check_java() {
    if java -version >/dev/null 2>&1; then
        # 获取 Java 版本号 (例如 17.0.1 -> 17)
        JAVA_VER=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.' '{print $1}')
        if [[ "$JAVA_VER" -ge 17 ]]; then
            echo -e "${GREEN}Java 已安装 (版本: $JAVA_VER)${NC}"
            return 0
        fi
    fi
    return 1
}

check_nginx() {
    if nginx -V >/dev/null 2>&1; then
        echo -e "${GREEN}Nginx 已安装${NC}"
        if systemctl is-active --quiet nginx; then
            echo -e "${GREEN}Nginx 正在运行${NC}"
            NGINX_IS_RUNNING=true
        else
            NGINX_IS_RUNNING=false
        fi
        return 0
    fi
    NGINX_IS_RUNNING=false
    return 1
}

check_node() {
    if node -v >/dev/null 2>&1; then
        NODE_VER_FULL=$(node -v)
        NODE_VER=$(echo "$NODE_VER_FULL" | grep -oP 'v\K[0-9]+')
        if [[ "$NODE_VER" -ge 18 ]]; then
            echo -e "${GREEN}Node.js 已安装 (版本: $NODE_VER_FULL)${NC}"
            return 0
        fi
    fi
    return 1
}

install_mysql8_debian() {
    # 检查是否正在运行
    if systemctl is-active --quiet mysql; then
        echo -e "${GREEN}MySQL 正在运行，跳过安装配置${NC}"
        return
    fi

    # 检查是否已安装 MySQL (通过 mysql -V)
    if mysql -V >/dev/null 2>&1; then
        if [[ "$(mysql -V)" == *"8."* ]]; then
            echo -e "${GREEN}MySQL 已安装 (版本: $(mysql -V))${NC}"
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
    # 检查是否正在运行
    if systemctl is-active --quiet mysqld; then
        echo -e "${GREEN}MySQL 正在运行，跳过安装配置${NC}"
        return
    fi

    if mysql -V >/dev/null 2>&1; then
        echo -e "${GREEN}MySQL 已安装 (版本: $(mysql -V))${NC}"
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
    apt-get install -y git curl wget unzip maven
    
    # Check and Install Nginx
    if ! check_nginx; then
        apt-get install -y nginx
    fi

    # Check and Install Java 17
    if ! check_java; then
        apt-get install -y openjdk-17-jdk
    fi
    
    # MySQL 8.0
    install_mysql8_debian
    
    # Node.js 18.x
    if ! check_node; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
        apt-get install -y nodejs
    fi
elif [ -f /etc/redhat-release ]; then
    # CentOS/RHEL
    yum install -y git curl wget unzip maven
    
    # Check and Install Nginx
    if ! check_nginx; then
        yum install -y nginx
    fi

    # Check and Install Java 17
    if ! check_java; then
        yum install -y java-17-openjdk-devel
    fi
    
    # MySQL 8.0
    install_mysql8_rhel
    
    # Node.js 18.x
    if ! check_node; then
        curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
        yum install -y nodejs
    fi
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
    echo -e "${YELLOW}检测到项目目录已存在: $INSTALL_DIR${NC}"
    read -p "是否强制覆盖更新 (将丢失本地修改)? (y/n/c [取消]): " OVERWRITE_CHOICE
    
    if [ "$OVERWRITE_CHOICE" == "y" ] || [ "$OVERWRITE_CHOICE" == "Y" ]; then
        echo -e "${YELLOW}正在强制更新项目...${NC}"
        
        # 询问是否备份配置文件
        read -p "是否备份原有的 application.properties 配置文件? (y/n): " BACKUP_CHOICE
        if [ "$BACKUP_CHOICE" == "y" ] || [ "$BACKUP_CHOICE" == "Y" ]; then
            if [ -f "$INSTALL_DIR/backend/src/main/resources/application.properties" ]; then
                cp "$INSTALL_DIR/backend/src/main/resources/application.properties" /tmp/application.properties.bak
                echo -e "${GREEN}已备份配置文件到 /tmp/application.properties.bak${NC}"
            else
                echo -e "${YELLOW}未找到配置文件，跳过备份${NC}"
            fi
        else
            echo -e "${YELLOW}跳过配置文件备份${NC}"
        fi
        
        # 删除原有目录并重新克隆
        echo -e "${YELLOW}正在删除原有目录...${NC}"
        rm -rf $INSTALL_DIR
        
        echo -e "${YELLOW}重新克隆项目...${NC}"
        git clone $GIT_REPO $INSTALL_DIR
        cd $INSTALL_DIR
        
        # 恢复配置提示
        if [ -f "/tmp/application.properties.bak" ] && [[ "$BACKUP_CHOICE" == "y" || "$BACKUP_CHOICE" == "Y" ]]; then
            echo -e "${YELLOW}提示: 之前的配置文件已备份 (/tmp/application.properties.bak)，如需恢复请手动操作${NC}"
        fi
    elif [ "$OVERWRITE_CHOICE" == "c" ] || [ "$OVERWRITE_CHOICE" == "C" ]; then
        echo -e "${RED}用户取消安装，脚本退出${NC}"
        exit 0
    else
        echo -e "${GREEN}选择保留现有文件，仅尝试普通更新 (git pull)...${NC}"
        cd $INSTALL_DIR
        git pull
    fi
else
    git clone $GIT_REPO $INSTALL_DIR
    cd $INSTALL_DIR
fi

# 4. 数据库配置
echo -e "${YELLOW}[4/8] 配置数据库...${NC}"
DB_NAME="kami"
DB_USER="root"

while true; do
    # 获取数据库密码
    read -p "请输入 MySQL root 密码: " DB_PASSWORD
    
    # 验证数据库连接
    echo -e "${YELLOW}正在验证数据库连接...${NC}"
    if mysql -u$DB_USER -p"$DB_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; then
        echo -e "${GREEN}数据库连接成功!${NC}"
        break
    else
        echo -e "${RED}数据库连接失败! 密码错误或服务未启动。${NC}"
        echo -e "${YELLOW}请重新输入密码，或检查 MySQL 服务状态。${NC}"
        read -p "是否重试? (y/n): " RETRY_CHOICE
        if [ "$RETRY_CHOICE" != "y" ] && [ "$RETRY_CHOICE" != "Y" ]; then
            echo -e "${RED}放弃配置数据库，脚本退出。${NC}"
            exit 1
        fi
    fi
done

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

# 配置 Maven 镜像 (如果是国内环境)
if [ "$IS_CHINA" = true ]; then
    echo -e "${YELLOW}配置 Maven 阿里云镜像...${NC}"
    mkdir -p ~/.m2
    cat > ~/.m2/settings.xml <<EOF
<settings>
  <mirrors>
    <mirror>
      <id>aliyunmaven</id>
      <mirrorOf>*</mirrorOf>
      <name>阿里云公共仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
fi

mvn clean package -DskipTests

# 创建系统服务 (支持开机自启)
SERVICE_FILE="/etc/systemd/system/xxgkami.service"
JAR_FILE=$(find target -name "backend-*.jar" | head -n 1)
ABS_JAR_PATH="$INSTALL_DIR/backend/$JAR_FILE"

# 动态获取 Java 路径 (优先使用 which java)
JAVA_PATH=$(which java)
if [ -z "$JAVA_PATH" ]; then
    JAVA_PATH="/usr/bin/java"
fi
echo -e "${GREEN}检测到 Java 路径: $JAVA_PATH${NC}"

# 根据环境设置 Profile，并添加内存限制参数
JAVA_OPTS="-Dspring.profiles.active=$DEPLOY_ENV -Xmx1024M -Xms256M"

cat > $SERVICE_FILE <<EOF
[Unit]
Description=XXG-KAMI-PRO Backend Service
After=syslog.target network.target mysql.service

[Service]
User=root
ExecStart=$JAVA_PATH -jar $JAVA_OPTS $ABS_JAR_PATH
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

# 修正前端环境配置 (强制使用 /api 相对路径，解决 Mixed Content 和跨域问题)
echo -e "${YELLOW}正在修正前端 API 配置...${NC}"
if [ -f ".env.production" ]; then
    sed -i 's|VITE_API_BASE_URL=.*|VITE_API_BASE_URL=/api|g' .env.production
else
    echo "VITE_API_BASE_URL=/api" > .env.production
fi

# 安装依赖
if [ "$IS_CHINA" = true ]; then
    echo -e "${YELLOW}使用淘宝 NPM 镜像...${NC}"
    npm install --registry=https://registry.npmmirror.com
else
    npm install
fi
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

# 7. 配置 Nginx 与域名
echo -e "${YELLOW}[7/8] 配置 Nginx 与域名...${NC}"

verify_domain() {
    local domain=$1
    echo -e "${YELLOW}正在验证域名解析: $domain${NC}"
    
    local public_ip=$(curl -s ifconfig.me)
    if [ -z "$public_ip" ]; then
        echo -e "${YELLOW}无法获取服务器公网 IP，跳过自动验证${NC}"
        return 0
    fi
    
    local domain_ip=""
    if command -v getent >/dev/null 2>&1; then
        domain_ip=$(getent hosts "$domain" | awk '{print $1}' | head -n 1)
    elif command -v ping >/dev/null 2>&1; then
        domain_ip=$(ping -c 1 "$domain" 2>/dev/null | grep -oP '(\d{1,3}\.){3}\d{1,3}' | head -n 1)
    fi
    
    if [ -z "$domain_ip" ]; then
        echo -e "${RED}无法解析域名 $domain${NC}"
        echo -e "${YELLOW}请确保域名已正确解析到服务器 IP: $public_ip${NC}"
        return 1
    fi
    
    if [ "$domain_ip" == "$public_ip" ]; then
        echo -e "${GREEN}域名解析验证通过: $domain -> $public_ip${NC}"
        return 0
    else
        echo -e "${RED}域名解析不匹配!${NC}"
        echo -e "域名指向: $domain_ip"
        echo -e "服务器IP: $public_ip"
        return 1
    fi
}

NGINX_CONF="/etc/nginx/conf.d/xxgkami.conf"

# 询问是否绑定域名
read -p "是否需要绑定域名？(y/n): " BIND_DOMAIN_CHOICE

if [ "$BIND_DOMAIN_CHOICE" == "y" ] || [ "$BIND_DOMAIN_CHOICE" == "Y" ]; then
    # 1. 获取服务器公网 IP
    PUBLIC_IP=$(curl -s ifconfig.me)
    echo -e "${GREEN}检测到服务器公网 IP: ${PUBLIC_IP}${NC}"
    
    # 2. 输入域名
    while true; do
        read -p "请输入您要绑定的域名 (例如: example.com): " USER_DOMAIN
        if [ -z "$USER_DOMAIN" ]; then
            continue
        fi
        
        # 验证域名
        if verify_domain "$USER_DOMAIN"; then
            break
        else
            read -p "域名解析似乎未生效或不匹配，是否强制继续? (y/n): " FORCE_CONTINUE
            if [ "$FORCE_CONTINUE" == "y" ] || [ "$FORCE_CONTINUE" == "Y" ]; then
                break
            fi
        fi
    done
    
    # 3. 生成 Nginx 配置 (HTTP)
    echo -e "${YELLOW}正在生成 Nginx 配置 (HTTP)...${NC}"
    cat > $NGINX_CONF <<EOF
server {
    listen 80;
    server_name $USER_DOMAIN;

    # 字符集配置
    charset utf-8;

    # 前端静态文件
    location / {
        root $NGINX_WEB_ROOT;
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }
    
    # 上传文件路径映射
    location /uploads {
        alias $INSTALL_DIR/backend/uploads;
    }

    # 后端 API 代理
    location /api {
        proxy_pass http://localhost:8080/api;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    echo -e "${GREEN}Nginx 配置已更新 (HTTP)${NC}"
    
    # 重载 Nginx 以确保 HTTP 生效 (为 Certbot 做准备)
    nginx -t && systemctl restart nginx
    
    # 4. 询问是否申请 HTTPS
    read -p "是否申请免费 HTTPS 证书 (Let's Encrypt)? (y/n): " HTTPS_CHOICE
    if [ "$HTTPS_CHOICE" == "y" ] || [ "$HTTPS_CHOICE" == "Y" ]; then
        echo -e "${YELLOW}正在安装 Certbot...${NC}"
        if [ -f /etc/debian_version ]; then
            apt-get update
            apt-get install -y certbot python3-certbot-nginx cron
        elif [ -f /etc/redhat-release ]; then
            yum install -y epel-release
            yum install -y certbot python3-certbot-nginx cronie
        fi
        
        echo -e "${YELLOW}开始申请证书...${NC}"
        read -p "请输入您的邮箱 (用于证书到期通知): " SSL_EMAIL
        if [ -z "$SSL_EMAIL" ]; then
            SSL_EMAIL="admin@$USER_DOMAIN"
        fi

        # 使用 nginx 插件自动配置
        if certbot --nginx -d $USER_DOMAIN --email $SSL_EMAIL --agree-tos --non-interactive --redirect; then
            echo -e "${GREEN}HTTPS 证书申请成功并已自动配置!${NC}"
            
            # 添加自动续签任务
            echo -e "${YELLOW}添加自动续签任务...${NC}"
            CRON_JOB="0 3 * * * certbot renew --quiet --nginx"
            (crontab -l 2>/dev/null | grep -v "certbot renew"; echo "$CRON_JOB") | crontab -
        else
            echo -e "${RED}HTTPS 证书申请失败 (certbot --nginx 模式)${NC}"
            echo -e "${YELLOW}尝试使用 standalone 模式重试...${NC}"
            
            systemctl stop nginx
            if certbot certonly --standalone -d $USER_DOMAIN --email $SSL_EMAIL --agree-tos --non-interactive; then
                 echo -e "${GREEN}HTTPS 证书申请成功 (standalone 模式)!${NC}"
                 
                 # 手动修改 Nginx 配置
                 cat > $NGINX_CONF <<EOF
server {
    listen 80;
    server_name $USER_DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $USER_DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$USER_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$USER_DOMAIN/privkey.pem;
    
    charset utf-8;

    location / {
        root $NGINX_WEB_ROOT;
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }
    
    location /uploads {
        alias $INSTALL_DIR/backend/uploads;
    }

    location /api {
        proxy_pass http://localhost:8080/api;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
                systemctl start nginx
                echo -e "${GREEN}Nginx SSL 配置已手动更新${NC}"
            else
                echo -e "${RED}HTTPS 证书申请最终失败，保留 HTTP 配置${NC}"
                systemctl start nginx
            fi
        fi
    fi

else
    # 不绑定域名，走原有逻辑
    if [ "$NGINX_IS_RUNNING" = true ]; then
        echo -e "${GREEN}Nginx 正在运行且未请求绑定域名，跳过配置修改${NC}"
    else
        # 尝试获取公网 IP，如果获取失败则回退到 localhost
        PUBLIC_IP=$(curl -s ifconfig.me)
        if [ -z "$PUBLIC_IP" ]; then
            SERVER_NAME="_"
        else
            SERVER_NAME="$PUBLIC_IP"
        fi

        # 备份原有配置
        if [ -f "$NGINX_CONF" ]; then
            cp "$NGINX_CONF" "${NGINX_CONF}.bak_$(date +%Y%m%d%H%M%S)"
        fi

        cat > $NGINX_CONF <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $SERVER_NAME _;

    # 字符集配置
    charset utf-8;

    # 前端静态文件 (指向标准目录)
    location / {
        root $NGINX_WEB_ROOT;
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }
    
    # 上传文件路径映射
    location /uploads {
        alias $INSTALL_DIR/backend/uploads;
    }

    # 后端 API 代理 (显式代理 /api 开头的请求)
    location /api {
        proxy_pass http://localhost:8080/api;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
        # 检查 Nginx 配置并重启
        nginx -t
        if [ $? -eq 0 ]; then
            systemctl enable nginx
            systemctl restart nginx
            echo -e "${GREEN}Nginx 配置已更新并重启${NC}"
        else
            echo -e "${RED}Nginx 配置语法有误，请检查配置文件${NC}"
            # 尝试回滚
            if [ -f "${NGINX_CONF}.bak_*" ]; then
                LATEST_BAK=$(ls -t ${NGINX_CONF}.bak_* | head -n1)
                cp "$LATEST_BAK" "$NGINX_CONF"
                echo -e "${YELLOW}已回滚到最近的备份配置: $LATEST_BAK${NC}"
            fi
        fi
    fi
fi

# 8. 健康检查
echo -e "${YELLOW}[8/8] 执行健康检查...${NC}"
sleep 30 # 等待服务启动

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
