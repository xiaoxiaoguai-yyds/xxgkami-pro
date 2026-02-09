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

show_menu() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}        XXG-KAMI-PRO 一键部署脚本 v1.0          ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo -e "欢迎使用小小怪卡密管理系统安装脚本！"
    echo -e "开源地址: https://github.com/xiaoxiaoguai-yyds/xxgkami-pro"
    echo -e "管理系统售后群: 1050160397"
    echo -e "${BLUE}================================================${NC}"
    echo -e "1. 安装系统 (全新安装)"
    echo -e "2. 更新系统 (保留数据更新)"
    echo -e "3. 更新本脚本"
    echo -e "4. 单独安装管理命令 (xxgkami)"
    echo -e "0. 退出"
    echo -e "${BLUE}================================================${NC}"
    read -p "请输入选项 [0-4]: " MENU_CHOICE
}

# 循环显示菜单，直到选择安装/更新或退出
while true; do
    show_menu
    case $MENU_CHOICE in
        1)
            echo -e "${GREEN}开始全新安装流程...${NC}"
            break # 跳出循环，继续执行后面的安装逻辑
            ;;
        2)
            echo -e "${GREEN}开始系统更新流程...${NC}"
            # 标记为更新模式，后续逻辑可据此跳过部分步骤（如数据库初始化）
            IS_UPDATE_MODE=true
            break # 跳出循环，继续执行后面的安装逻辑
            ;;
        3)
            echo -e "${YELLOW}正在更新脚本...${NC}"
            wget -O install.sh https://ghfast.top/https://raw.githubusercontent.com/xiaoxiaoguai-yyds/xxgkami-pro/refs/heads/master/install.sh && chmod +x install.sh
            echo -e "${GREEN}脚本更新完成，请重新运行 ./install.sh${NC}"
            exit 0
            ;;
        4)
            # 定义安装目录变量，因为后续生成脚本需要
            INSTALL_DIR="/var/www/xxgkami-pro"
            # 默认中国网络环境，如果需要检测可以在这里添加
            IS_CHINA=true 
            
            # 直接跳转到生成管理脚本的部分
            # 我们可以将管理脚本生成封装成函数，或者在这里直接写入
            # 为了简单起见，我们复制后面的生成逻辑，或者直接跳转
            # 但 Bash 不支持 GOTO，所以我们把生成逻辑封装成函数最好
            # 这里先临时定义一个变量来控制流程
            ONLY_INSTALL_CMD=true
            break
            ;;
        0)
            echo -e "${GREEN}感谢使用，再见！${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选项，请重新输入${NC}"
            sleep 1
            ;;
    esac
done

if [ "$ONLY_INSTALL_CMD" == "true" ]; then
    # 8. 安装管理脚本
    echo -e "${YELLOW}正在安装 xxgkami 管理命令...${NC}"
    cat > /usr/local/bin/xxgkami <<EOF
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
INSTALL_DIR="$INSTALL_DIR"
IS_CHINA=$IS_CHINA

while true; do
    clear
    echo -e "\${BLUE}================================================\${NC}"
    echo -e "\${BLUE}           XXG-KAMI-PRO 管理脚本                \${NC}"
    echo -e "\${BLUE}================================================\${NC}"
    echo -e "1. 启动服务 (Backend + Nginx)"
    echo -e "2. 停止服务"
    echo -e "3. 重启服务"
    echo -e "4. 查看后端日志"
    echo -e "5. 查看 Nginx 日志"
    echo -e "6. 更新项目 (git pull + build)"
    echo -e "7. 数据库连接信息"
    echo -e "8. 强制重置 SSL 证书"
    echo -e "9. 卸载系统"
    echo -e "0. 退出"
    echo -e "\${BLUE}================================================\${NC}"
    read -p "请输入选项 [0-9]: " choice
    
    case \$choice in
        1)
            systemctl start xxgkami
            systemctl start nginx
            echo -e "\${GREEN}服务已启动\${NC}"
            ;;
        2)
            systemctl stop xxgkami
            systemctl stop nginx
            echo -e "\${GREEN}服务已停止\${NC}"
            ;;
        3)
            systemctl restart xxgkami
            systemctl restart nginx
            echo -e "\${GREEN}服务已重启\${NC}"
            ;;
        4)
            journalctl -u xxgkami -f -n 50
            ;;
        5)
            tail -f /var/log/nginx/error.log
            ;;
        6)
            echo -e "\${YELLOW}正在拉取最新代码...\${NC}"
            cd \$INSTALL_DIR
            git pull
            
            # Database Update Logic
            echo -e "\${YELLOW}正在检查数据库更新...\${NC}"
            APP_PROP="\$INSTALL_DIR/backend/src/main/resources/application.properties"
            if [ -f "\$APP_PROP" ]; then
                # Extract DB Creds
                DB_USER=\$(grep "spring.datasource.username" \$APP_PROP | cut -d'=' -f2 | tr -d '\r')
                DB_PWD=\$(grep "spring.datasource.password" \$APP_PROP | cut -d'=' -f2 | tr -d '\r')
                DB_NAME="kami"
                
                SQL_FILE="\$INSTALL_DIR/database/kami.sql"
                # Typo fix check
                if [ ! -f "\$SQL_FILE" ] && [ -f "\$INSTALL_DIR/databaes/kami.sql" ]; then
                    SQL_FILE="\$INSTALL_DIR/databaes/kami.sql"
                fi
                
                if [ -f "\$SQL_FILE" ]; then
                    echo -e "\${YELLOW}正在执行数据库智能更新...\${NC}"
                    TEMP_DB="kami_update_temp_\$(date +%s)"
                    
                    # 1. Create Temp DB
                    echo -e "\${BLUE}创建临时数据库 \$TEMP_DB...\${NC}"
                    mysql -u\$DB_USER -p"\$DB_PWD" -e "CREATE DATABASE \$TEMP_DB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;" 2>/dev/null
                    
                    if [ \$? -eq 0 ]; then
                        # 2. Import new SQL
                        echo -e "\${BLUE}导入新版数据到临时库...\${NC}"
                        mysql -u\$DB_USER -p"\$DB_PWD" \$TEMP_DB < "\$SQL_FILE"
                        
                        # 3. Sync Tables
                        echo -e "\${BLUE}检查新增表...\${NC}"
                        TEMP_TABLES=\$(mysql -u\$DB_USER -p"\$DB_PWD" -N -B -e "SHOW TABLES FROM \$TEMP_DB")
                        
                        for TABLE in \$TEMP_TABLES; do
                            TABLE_EXISTS=\$(mysql -u\$DB_USER -p"\$DB_PWD" -N -B -e "SELECT count(*) FROM information_schema.tables WHERE table_schema = '\$DB_NAME' AND table_name = '\$TABLE';")
                            
                            if [ "\$TABLE_EXISTS" -eq 0 ]; then
                                echo -e "\${GREEN}检测到新增表: \$TABLE，正在创建...\${NC}"
                                mysqldump -u\$DB_USER -p"\$DB_PWD" \$TEMP_DB \$TABLE | mysql -u\$DB_USER -p"\$DB_PWD" \$DB_NAME
                            else
                                # 4. Sync Data (Insert Ignore)
                                mysqldump -u\$DB_USER -p"\$DB_PWD" --no-create-info --insert-ignore --complete-insert \$TEMP_DB \$TABLE | mysql -u\$DB_USER -p"\$DB_PWD" \$DB_NAME
                            fi
                        done
                        
                        # 5. Cleanup
                        echo -e "\${BLUE}清理临时数据库...\${NC}"
                        mysql -u\$DB_USER -p"\$DB_PWD" -e "DROP DATABASE \$TEMP_DB;"
                        echo -e "\${GREEN}数据库增量更新完成!\${NC}"
                    else
                         echo -e "\${RED}创建临时数据库失败，可能是密码错误或权限不足，跳过数据库更新\${NC}"
                    fi
                else
                    echo -e "\${RED}错误：找不到数据库文件 \$SQL_FILE\${NC}"
                fi
            else
                echo -e "\${YELLOW}未找到配置文件，跳过数据库更新\${NC}"
            fi
            
            echo -e "\${YELLOW}重新编译后端...\${NC}"
            cd backend
            if [ "\$IS_CHINA" = true ]; then
                 mkdir -p ~/.m2
            fi
            mvn clean package -DskipTests
            systemctl restart xxgkami
            
            echo -e "\${YELLOW}重新编译前端...\${NC}"
            cd ..
            # 自动修正环境配置
            if [ -f ".env.production" ]; then
                sed -i 's|VITE_API_BASE_URL=.*|VITE_API_BASE_URL=/api|g' .env.production
            else
                echo "VITE_API_BASE_URL=/api" > .env.production
            fi
            
            if [ "\$IS_CHINA" = true ]; then
                npm install --registry=https://registry.npmmirror.com
            else
                npm install
            fi
            npm run build
            cp -r dist/* /usr/share/nginx/html/
            echo -e "\${GREEN}项目更新完成\${NC}"
            ;;
        7)
            echo -e "\${YELLOW}数据库配置信息:\${NC}"
            grep "spring.datasource" \$INSTALL_DIR/backend/src/main/resources/application.properties
            read -p "按回车键继续..."
            ;;
        8)
             echo -e "\${YELLOW}正在续签 SSL 证书...\${NC}"
             certbot renew --force-renewal
             systemctl reload nginx
             echo -e "\${GREEN}证书续签尝试完成\${NC}"
             ;;
        9)
            echo -e "\${RED}警告: 此操作将完全删除以下内容：\${NC}"
            echo -e "  - 后端服务与文件"
            echo -e "  - 前端静态文件"
            echo -e "  - 数据库 (kami)"
            echo -e "  - Nginx 配置"
            echo -e "  - 本地安装脚本 (install.sh)"
            read -p "确认要卸载吗？请输入 'yes' 确认: " CONFIRM_UNINSTALL
            if [ "\$CONFIRM_UNINSTALL" == "yes" ]; then
                echo -e "\${YELLOW}正在停止服务...\${NC}"
                systemctl stop xxgkami
                systemctl disable xxgkami
                rm /etc/systemd/system/xxgkami.service
                systemctl daemon-reload
                
                echo -e "\${YELLOW}删除文件...\${NC}"
                rm -rf \$INSTALL_DIR
                rm -rf /usr/share/nginx/html/*
                rm -f /etc/nginx/conf.d/xxgkami.conf
                systemctl reload nginx
                
                # 尝试删除用户当前目录下的 git clone 文件夹
                if [ -d "xxgkami-pro" ]; then
                     echo -e "\${YELLOW}删除当前目录下的源码文件夹 (xxgkami-pro)...\${NC}"
                     rm -rf xxgkami-pro
                elif [ -d "/root/xxgkami-pro" ]; then
                     echo -e "\${YELLOW}删除 /root/xxgkami-pro 源码文件夹...\${NC}"
                     rm -rf /root/xxgkami-pro
                fi
                
                echo -e "\${YELLOW}删除数据库...\${NC}"
                read -p "请输入 MySQL root 密码以删除数据库: " DB_PWD
                mysql -uroot -p"\$DB_PWD" -e "DROP DATABASE IF EXISTS kami;" 2>/dev/null
                
                echo -e "\${YELLOW}删除安装脚本...\${NC}"
                # 尝试删除当前目录下的 install.sh，假设用户是在当前目录运行的
                # 但管理脚本是在 /usr/local/bin 运行的，所以无法直接知道 install.sh 在哪
                # 不过通常用户是在 root 或 home 目录下载的
                if [ -f "install.sh" ]; then
                    rm -f install.sh
                elif [ -f "/root/install.sh" ]; then
                    rm -f /root/install.sh
                fi

                echo -e "\${GREEN}卸载完成！\${NC}"
                echo -e "\${BLUE}================================================\${NC}"
                echo -e "\${GREEN}感谢您使用小小怪卡密管理系统！\${NC}"
                echo -e "山水有相逢，愿我们在代码的世界里再次相遇。"
                echo -e "项目开源地址: https://github.com/xiaoxiaoguai-yyds/xxgkami-pro"
                echo -e "管理系统售后群: 1050160397"
                echo -e "\${BLUE}================================================\${NC}"
                
                # 删除脚本自身
                rm -f /usr/local/bin/xxgkami
                exit 0
            else
                echo -e "\${YELLOW}取消卸载\${NC}"
            fi
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "\${RED}无效选项\${NC}"
            ;;
    esac
    
    if [ "\$choice" != "0" ] && [ "\$choice" != "4" ] && [ "\$choice" != "5" ]; then
        read -p "按回车键返回菜单..."
    fi
done
EOF
    chmod +x /usr/local/bin/xxgkami
    echo -e "${GREEN}管理脚本已安装! 输入 'xxgkami' 即可使用。${NC}"
    exit 0
fi

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
    GIT_REPO="https://gitee.com/xiaoxiaoguai-yyds/xxgkami-pro.git"
fi

# 2. 系统检测与基础依赖安装 (MySQL 8.0+, JDK 17, Node 18, Nginx)
echo -e "${YELLOW}[2/8] 安装基础依赖 (MySQL 8.0+, JDK 17, Node 18, Nginx)...${NC}"

check_mysql_version() {
    echo -e "${YELLOW}[前置检查] 验证 MySQL 版本兼容性...${NC}"
    if ! command -v mysql >/dev/null 2>&1; then
        echo -e "${YELLOW}未检测到 MySQL 已安装，后续将尝试自动安装 MySQL 8.0${NC}"
        return 0
    fi
    
    local mysql_ver_str=$(mysql -V 2>&1)
    # 尝试提取版本号 (优先匹配 Distrib x.x, 其次 Ver x.x)
    local mysql_ver=$(echo "$mysql_ver_str" | sed -n 's/.*Distrib \([0-9]\+\.[0-9]\+\).*/\1/p')
    if [ -z "$mysql_ver" ]; then
        mysql_ver=$(echo "$mysql_ver_str" | sed -n 's/.*Ver \([0-9]\+\.[0-9]\+\).*/\1/p')
    fi
    
    local required_ver="8.0"
    
    if [ -z "$mysql_ver" ]; then
         echo -e "${YELLOW}警告: 无法识别当前 MySQL 版本，跳过检查。${NC}"
         return 0
    fi

    echo -e "当前 MySQL 版本: ${mysql_ver}"
    echo -e "要求 MySQL 版本: ${required_ver}+"
    
    # 版本对比 (使用 awk)
    if awk "BEGIN {exit !($mysql_ver >= $required_ver)}"; then
        echo -e "${GREEN}MySQL 版本符合要求${NC}"
        return 0
    else
        echo -e "${RED}MySQL 版本不符合要求!${NC}"
        echo -e "${YELLOW}警告: 强制执行可能会对其他项目造成影响 (可能导致数据库不兼容或服务中断)!${NC}"
        read -p "是否强制继续安装? (y/n): " FORCE_MYSQL
        if [ "$FORCE_MYSQL" == "y" ] || [ "$FORCE_MYSQL" == "Y" ]; then
            echo -e "${YELLOW}已选择强制继续安装...${NC}"
            return 0
        else
            echo -e "${RED}安装已取消${NC}"
            exit 1
        fi
    fi
}

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

# 执行 MySQL 版本检查
check_mysql_version

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
    
    # Redis (新增)
    if ! command -v redis-server >/dev/null 2>&1; then
        echo -e "${YELLOW}正在安装 Redis...${NC}"
        apt-get install -y redis-server
        systemctl enable redis-server
        systemctl start redis-server
    fi
    
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
    
    # Redis (新增)
    if ! command -v redis-server >/dev/null 2>&1; then
        echo -e "${YELLOW}正在安装 Redis...${NC}"
        yum install -y redis
        systemctl enable redis
        systemctl start redis
    fi
    
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
            
            # 备份密钥目录 (防止密钥丢失导致数据无法解密)
            if [ -d "$INSTALL_DIR/backend/keys" ]; then
                cp -r "$INSTALL_DIR/backend/keys" /tmp/keys_backup
                echo -e "${GREEN}已备份密钥目录到 /tmp/keys_backup${NC}"
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
        
        # 自动恢复密钥目录
        if [ -d "/tmp/keys_backup" ] && [[ "$BACKUP_CHOICE" == "y" || "$BACKUP_CHOICE" == "Y" ]]; then
             mkdir -p "$INSTALL_DIR/backend"
             cp -r /tmp/keys_backup "$INSTALL_DIR/backend/keys"
             echo -e "${GREEN}已自动恢复密钥目录${NC}"
             rm -rf /tmp/keys_backup
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

# 修正可能存在的路径拼写问题
if [ ! -f "$SQL_FILE" ] && [ -f "$INSTALL_DIR/database/kami.sql" ]; then
    SQL_FILE="$INSTALL_DIR/database/kami.sql"
fi

if [ -f "$SQL_FILE" ]; then
    if [ "$IS_UPDATE_MODE" == "true" ]; then
        echo -e "${YELLOW}正在执行数据库智能更新...${NC}"
        TEMP_DB="kami_update_temp_$(date +%s)"
        
        # 1. 创建临时数据库
        echo -e "${BLUE}创建临时数据库 $TEMP_DB...${NC}"
        mysql -u$DB_USER -p"$DB_PASSWORD" -e "CREATE DATABASE $TEMP_DB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;"
        
        # 2. 导入新版 SQL 到临时数据库
        echo -e "${BLUE}导入新版数据到临时库...${NC}"
        mysql -u$DB_USER -p"$DB_PASSWORD" $TEMP_DB < "$SQL_FILE"
        
        # 3. 同步表结构 (新增表)
        echo -e "${BLUE}检查新增表...${NC}"
        # 获取临时库的所有表名
        TEMP_TABLES=$(mysql -u$DB_USER -p"$DB_PASSWORD" -N -B -e "SHOW TABLES FROM $TEMP_DB")
        
        for TABLE in $TEMP_TABLES; do
            # 检查目标库是否存在该表
            TABLE_EXISTS=$(mysql -u$DB_USER -p"$DB_PASSWORD" -N -B -e "SELECT count(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND table_name = '$TABLE';")
            
            if [ "$TABLE_EXISTS" -eq 0 ]; then
                echo -e "${GREEN}检测到新增表: $TABLE，正在创建...${NC}"
                # 从临时库导出该表结构和数据，导入到目标库
                mysqldump -u$DB_USER -p"$DB_PASSWORD" $TEMP_DB $TABLE | mysql -u$DB_USER -p"$DB_PASSWORD" $DB_NAME
            else
                # 4. 同步数据 (新增行) - 仅对存在的表执行插入
                # 使用 INSERT IGNORE 避免主键冲突，保留现有数据
                # echo -e "${BLUE}检查表 $TABLE 数据更新...${NC}"
                mysqldump -u$DB_USER -p"$DB_PASSWORD" --no-create-info --insert-ignore --complete-insert $TEMP_DB $TABLE | mysql -u$DB_USER -p"$DB_PASSWORD" $DB_NAME
            fi
        done
        
        echo -e "${GREEN}数据库增量更新完成!${NC}"
        
        # 5. 清理临时数据库
        echo -e "${BLUE}清理临时数据库...${NC}"
        mysql -u$DB_USER -p"$DB_PASSWORD" -e "DROP DATABASE $TEMP_DB;"
        
    else
        echo -e "${GREEN}正在导入数据库...${NC}"
        mysql -u$DB_USER -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;"
        mysql -u$DB_USER -p"$DB_PASSWORD" $DB_NAME < "$SQL_FILE"
    fi
else
    echo -e "${RED}错误：找不到数据库文件 $SQL_FILE${NC}"
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
    
    # 优先获取 IPv4 公网 IP
    local public_ip=$(curl -s -4 ifconfig.me)
    if [ -z "$public_ip" ]; then
        public_ip=$(curl -s ifconfig.me)
    fi

    if [ -z "$public_ip" ]; then
        echo -e "${YELLOW}无法获取服务器公网 IP，跳过自动验证${NC}"
        return 0
    fi
    
    local domain_ip=""
    # 优先使用 ping 获取 IPv4 地址 (通过 grep 筛选 IPv4 格式)
    if command -v ping >/dev/null 2>&1; then
        domain_ip=$(ping -c 1 "$domain" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
    fi
    
    # 如果 ping 失败，尝试 getent 并筛选 IPv4
    if [ -z "$domain_ip" ] && command -v getent >/dev/null 2>&1; then
        domain_ip=$(getent hosts "$domain" | awk '{print $1}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
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
    # 1. 获取服务器公网 IP (优先 IPv4)
    PUBLIC_IP=$(curl -s -4 ifconfig.me)
    if [ -z "$PUBLIC_IP" ]; then
        PUBLIC_IP=$(curl -s ifconfig.me)
    fi
    echo -e "${GREEN}检测到服务器公网 IP: ${PUBLIC_IP}${NC}"
    
    # 2. 输入域名
    while true; do
        read -p "请输入您要绑定的域名 (例如: example.com): " USER_DOMAIN
        
        # 自动去除 http://, https://, 和尾部 /
        USER_DOMAIN=$(echo "$USER_DOMAIN" | sed 's|http://||g' | sed 's|https://||g' | sed 's|/$||g')
        
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
    
    # 移除默认配置以避免冲突
    if [ -f /etc/nginx/sites-enabled/default ]; then
        rm -f /etc/nginx/sites-enabled/default
        echo -e "${YELLOW}已移除默认 Nginx 站点配置 (/etc/nginx/sites-enabled/default)${NC}"
    fi
    if [ -f /etc/nginx/conf.d/default.conf ]; then
        mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
        echo -e "${YELLOW}已备份默认 Nginx 配置文件 (/etc/nginx/conf.d/default.conf -> .bak)${NC}"
    fi

    # 3. 生成 Nginx 配置 (HTTP)
    echo -e "${YELLOW}正在生成 Nginx 配置 (HTTP)...${NC}"
    cat > $NGINX_CONF <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
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
        
        # 增加超时时间，防止长时间请求中断
        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;
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

# 8. 安装管理脚本
echo -e "${YELLOW}[8/9] 安装 xxgkami 管理命令...${NC}"
cat > /usr/local/bin/xxgkami <<EOF
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
INSTALL_DIR="$INSTALL_DIR"
IS_CHINA=$IS_CHINA

while true; do
    clear
    echo -e "\${BLUE}================================================\${NC}"
    echo -e "\${BLUE}           XXG-KAMI-PRO 管理脚本                \${NC}"
    echo -e "\${BLUE}================================================\${NC}"
    echo -e "1. 启动服务 (Backend + Nginx)"
    echo -e "2. 停止服务"
    echo -e "3. 重启服务"
    echo -e "4. 查看后端日志"
    echo -e "5. 查看 Nginx 日志"
    echo -e "6. 更新项目 (git pull + build)"
    echo -e "7. 数据库连接信息"
    echo -e "8. 强制重置 SSL 证书"
    echo -e "9. 卸载系统"
    echo -e "0. 退出"
    echo -e "\${BLUE}================================================\${NC}"
    read -p "请输入选项 [0-9]: " choice
    
    case \$choice in
        1)
            systemctl start xxgkami
            systemctl start nginx
            echo -e "\${GREEN}服务已启动\${NC}"
            ;;
        2)
            systemctl stop xxgkami
            systemctl stop nginx
            echo -e "\${GREEN}服务已停止\${NC}"
            ;;
        3)
            systemctl restart xxgkami
            systemctl restart nginx
            echo -e "\${GREEN}服务已重启\${NC}"
            ;;
        4)
            journalctl -u xxgkami -f -n 50
            ;;
        5)
            tail -f /var/log/nginx/error.log
            ;;
        6)
            echo -e "\${YELLOW}正在拉取最新代码...\${NC}"
            cd \$INSTALL_DIR
            git pull
            
            # Database Update Logic
            echo -e "\${YELLOW}正在检查数据库更新...\${NC}"
            APP_PROP="\$INSTALL_DIR/backend/src/main/resources/application.properties"
            if [ -f "\$APP_PROP" ]; then
                # Extract DB Creds
                DB_USER=\$(grep "spring.datasource.username" \$APP_PROP | cut -d'=' -f2 | tr -d '\r')
                DB_PWD=\$(grep "spring.datasource.password" \$APP_PROP | cut -d'=' -f2 | tr -d '\r')
                DB_NAME="kami"
                
                SQL_FILE="\$INSTALL_DIR/database/kami.sql"
                # Typo fix check
                if [ ! -f "\$SQL_FILE" ] && [ -f "\$INSTALL_DIR/databaes/kami.sql" ]; then
                    SQL_FILE="\$INSTALL_DIR/databaes/kami.sql"
                fi
                
                if [ -f "\$SQL_FILE" ]; then
                    echo -e "\${YELLOW}正在执行数据库智能更新...\${NC}"
                    TEMP_DB="kami_update_temp_\$(date +%s)"
                    
                    # 1. Create Temp DB
                    echo -e "\${BLUE}创建临时数据库 \$TEMP_DB...\${NC}"
                    mysql -u\$DB_USER -p"\$DB_PWD" -e "CREATE DATABASE \$TEMP_DB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;" 2>/dev/null
                    
                    if [ \$? -eq 0 ]; then
                        # 2. Import new SQL
                        echo -e "\${BLUE}导入新版数据到临时库...\${NC}"
                        mysql -u\$DB_USER -p"\$DB_PWD" \$TEMP_DB < "\$SQL_FILE"
                        
                        # 3. Sync Tables
                        echo -e "\${BLUE}检查新增表...\${NC}"
                        TEMP_TABLES=\$(mysql -u\$DB_USER -p"\$DB_PWD" -N -B -e "SHOW TABLES FROM \$TEMP_DB")
                        
                        for TABLE in \$TEMP_TABLES; do
                            TABLE_EXISTS=\$(mysql -u\$DB_USER -p"\$DB_PWD" -N -B -e "SELECT count(*) FROM information_schema.tables WHERE table_schema = '\$DB_NAME' AND table_name = '\$TABLE';")
                            
                            if [ "\$TABLE_EXISTS" -eq 0 ]; then
                                echo -e "\${GREEN}检测到新增表: \$TABLE，正在创建...\${NC}"
                                mysqldump -u\$DB_USER -p"\$DB_PWD" \$TEMP_DB \$TABLE | mysql -u\$DB_USER -p"\$DB_PWD" \$DB_NAME
                            else
                                # 4. Sync Data (Insert Ignore)
                                mysqldump -u\$DB_USER -p"\$DB_PWD" --no-create-info --insert-ignore --complete-insert \$TEMP_DB \$TABLE | mysql -u\$DB_USER -p"\$DB_PWD" \$DB_NAME
                            fi
                        done
                        
                        # 5. Cleanup
                        echo -e "\${BLUE}清理临时数据库...\${NC}"
                        mysql -u\$DB_USER -p"\$DB_PWD" -e "DROP DATABASE \$TEMP_DB;"
                        echo -e "\${GREEN}数据库增量更新完成!\${NC}"
                    else
                         echo -e "\${RED}创建临时数据库失败，可能是密码错误或权限不足，跳过数据库更新\${NC}"
                    fi
                else
                    echo -e "\${RED}错误：找不到数据库文件 \$SQL_FILE\${NC}"
                fi
            else
                echo -e "\${YELLOW}未找到配置文件，跳过数据库更新\${NC}"
            fi
            
            echo -e "\${YELLOW}重新编译后端...\${NC}"
            cd backend
            if [ "\$IS_CHINA" = true ]; then
                 mkdir -p ~/.m2
            fi
            mvn clean package -DskipTests
            systemctl restart xxgkami
            
            echo -e "\${YELLOW}重新编译前端...\${NC}"
            cd ..
            # 自动修正环境配置
            if [ -f ".env.production" ]; then
                sed -i 's|VITE_API_BASE_URL=.*|VITE_API_BASE_URL=/api|g' .env.production
            else
                echo "VITE_API_BASE_URL=/api" > .env.production
            fi
            
            if [ "\$IS_CHINA" = true ]; then
                npm install --registry=https://registry.npmmirror.com
            else
                npm install
            fi
            npm run build
            cp -r dist/* /usr/share/nginx/html/
            echo -e "\${GREEN}项目更新完成\${NC}"
            ;;
        7)
            echo -e "\${YELLOW}数据库配置信息:\${NC}"
            grep "spring.datasource" \$INSTALL_DIR/backend/src/main/resources/application.properties
            read -p "按回车键继续..."
            ;;
        8)
             echo -e "\${YELLOW}正在续签 SSL 证书...\${NC}"
             certbot renew --force-renewal
             systemctl reload nginx
             echo -e "\${GREEN}证书续签尝试完成\${NC}"
             ;;
        9)
            echo -e "\${RED}警告: 此操作将完全删除以下内容：\${NC}"
            echo -e "  - 后端服务与文件"
            echo -e "  - 前端静态文件"
            echo -e "  - 数据库 (kami)"
            echo -e "  - Nginx 配置"
            read -p "确认要卸载吗？请输入 'yes' 确认: " CONFIRM_UNINSTALL
            if [ "\$CONFIRM_UNINSTALL" == "yes" ]; then
                echo -e "\${YELLOW}正在停止服务...\${NC}"
                systemctl stop xxgkami
                systemctl disable xxgkami
                rm /etc/systemd/system/xxgkami.service
                systemctl daemon-reload
                
                echo -e "\${YELLOW}删除文件...\${NC}"
                rm -rf \$INSTALL_DIR
                rm -rf /usr/share/nginx/html/*
                rm -f /etc/nginx/conf.d/xxgkami.conf
                systemctl reload nginx
                
                echo -e "\${YELLOW}删除数据库...\${NC}"
                read -p "请输入 MySQL root 密码以删除数据库: " DB_PWD
                mysql -uroot -p"\$DB_PWD" -e "DROP DATABASE IF EXISTS kami;" 2>/dev/null
                
                echo -e "\${GREEN}卸载完成！\${NC}"
                echo -e "\${BLUE}================================================\${NC}"
                echo -e "\${GREEN}感谢您使用小小怪卡密管理系统！\${NC}"
                echo -e "山水有相逢，愿我们在代码的世界里再次相遇。"
                echo -e "项目开源地址: https://github.com/xiaoxiaoguai-yyds/xxgkami-pro"
                echo -e "管理系统售后群: 1050160397"
                echo -e "\${BLUE}================================================\${NC}"
                
                # 删除脚本自身
                rm -f /usr/local/bin/xxgkami
                exit 0
            else
                echo -e "\${YELLOW}取消卸载\${NC}"
            fi
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "\${RED}无效选项\${NC}"
            ;;
    esac
    
    if [ "\$choice" != "0" ] && [ "\$choice" != "4" ] && [ "\$choice" != "5" ]; then
        read -p "按回车键返回菜单..."
    fi
done
EOF
chmod +x /usr/local/bin/xxgkami
echo -e "${GREEN}管理脚本已安装! 部署完成后输入 'xxgkami' 即可使用。${NC}"

# 9. 健康检查
echo -e "${YELLOW}[9/9] 执行健康检查...${NC}"
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
# 构建访问地址
CURRENT_IP=$(curl -s ifconfig.me)
if [ -n "$USER_DOMAIN" ]; then
    PROTOCOL="http"
    if [ "$HTTPS_CHOICE" == "y" ] || [ "$HTTPS_CHOICE" == "Y" ]; then
        PROTOCOL="https"
    fi
    SITE_URL="${PROTOCOL}://${USER_DOMAIN}"
else
    SITE_URL="http://${CURRENT_IP}"
fi

echo -e "用户端地址: ${SITE_URL}"
echo -e "管理端地址: ${SITE_URL}/#/admin"
echo -e "------------------------------------------------"
echo -e "默认管理员账号: admin"
echo -e "默认管理员密码: 123465"
echo -e "------------------------------------------------"
echo -e "后端服务状态: systemctl status xxgkami"
echo -e "Nginx状态: systemctl status nginx"
