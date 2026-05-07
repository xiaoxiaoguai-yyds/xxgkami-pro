#!/bin/bash

# XXG-KAMI-PRO 一键安装脚本
# 作者: xiaoxiaoguai-yyds

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 国内 GitHub / 境外脚本拉取加速（用法：${GH_PROXY_CN}/<原始完整URL>，见 https://gh-proxy.com/ ）
GH_PROXY_CN="${GH_PROXY_CN:-https://gh-proxy.com}"

# 项目部署根目录：源码、maven 工作区、后端 JAR（宝塔常见 /www/wwwroot/xxgkami）
: "${XXGKAMI_DEPLOY_ROOT:=/www/wwwroot/xxgkami}"
# 前端 dist（默认同在项目根下的 dist）
: "${XXGKAMI_WEB_ROOT:=$XXGKAMI_DEPLOY_ROOT/dist}"

# 查找含 index.html 的前端构建目录（Vite 默认 <项目根>/dist；部分仓库可能在子目录）
_xxgkami_find_frontend_dist_dir() {
    local base="${1%/}"
    local cand
    [ -n "$base" ] && [ -d "$base" ] || return 1
    for cand in "$base/dist" "$base/frontend/dist" "$base/vue/dist" "$base/web/dist" "$base/admin/dist" "$base/xxgkami-vue/dist"; do
        if [ -f "$cand/index.html" ]; then
            printf '%s\n' "${cand%/}"
            return 0
        fi
    done
    return 1
}

# 将构建产物同步到 Nginx 站点根。若 WEB_ROOT 与 Vite outDir 为同一路径，禁止 rm + cp（会先清空刚构建的文件）
_xxgkami_sync_frontend_to_webroot() {
    local install_dir="${1%/}"
    local web_root="${2%/}"
    local src=""

    src=$(_xxgkami_find_frontend_dist_dir "$install_dir") || true
    if [ -z "$src" ]; then
        echo -e "${RED}未找到前端构建产物（需存在 …/dist/index.html）。请确认在项目根执行 npm run build 已成功。${NC}"
        echo -e "${YELLOW}已检查: ${install_dir}/dist、(frontend|vue|web|admin|xxgkami-vue)/dist ${NC}"
        ls -la "$install_dir" 2>/dev/null | head -n 30 || true
        return 1
    fi
    echo -e "${GREEN}前端构建目录: ${src}${NC}"

    if [ "$src" = "$web_root" ]; then
        echo -e "${GREEN}站点根与构建输出为同一路径，跳过清空/拷贝（避免误删构建结果）。${NC}"
        mkdir -p "$web_root"
        return 0
    fi

    if [ "$web_root" = "/usr/share/nginx/html" ] && [ -d "$web_root" ] && [ -n "$(ls -A "$web_root" 2>/dev/null)" ]; then
        mv "$web_root" "${web_root}_backup_$(date +%s)"
    fi
    mkdir -p "$web_root"
    chmod 775 "$(dirname "$web_root")" 2>/dev/null || true
    rm -rf "${web_root:?}"/* 2>/dev/null || true
    cp -a "${src}/." "$web_root/"
    return 0
}

# 整行替换 application.properties 中的 key=（密码含 /、&、$ 时 sed 易写坏，导致 JDBC Access denied）
_xxgkami_set_app_property_line() {
    local file="$1" key="$2" value="$3"
    local tmp="${file}.xxgk.$$"
    [ -f "$file" ] || return 1
    # 去掉 CRLF 行尾，否则 substr 与 key= 比较失败，密码行不会被替换（宝塔/Windows 检出常见）
    awk -v k="$key" -v v="$value" '
        { sub(/\r$/, "") }
        substr($0, 1, length(k) + 1) == k "=" { print k "=" v; next }
        { print }
    ' "$file" > "$tmp" && mv "$tmp" "$file"
}

# 在 mvn package 前写入数据源（打进 fat JAR）；宝塔「Java项目」往往不读 systemd 的 EnvironmentFile，必须依赖此项
_xxgkami_bake_backend_datasource_props() {
    local app_prop="$1"
    local db_pass="$2"
    [ -f "$app_prop" ] || {
        echo -e "${RED}未找到 ${app_prop}${NC}"
        return 1
    }
    sed -i 's/\r$//' "$app_prop" 2>/dev/null || true
    _xxgkami_set_app_property_line "$app_prop" "spring.datasource.username" "root"
    _xxgkami_set_app_property_line "$app_prop" "spring.datasource.password" "$db_pass"
    return 0
}

# systemd EnvironmentFile：Spring Boot 会以环境变量覆盖 JAR 内嵌 spring.datasource.*，防止构建与实况不一致
_xxgkami_write_db_env_for_systemd() {
    local dir="/etc/xxgkami"
    local f="$dir/backend-datasource.env"
    mkdir -p "$dir"
    chmod 700 "$dir" 2>/dev/null || true
    {
        printf '%s=%s\n' "SPRING_DATASOURCE_USERNAME" "$DB_USER"
        printf '%s=%s\n' "SPRING_DATASOURCE_PASSWORD" "$DB_PASSWORD"
    } > "$f"
    chmod 600 "$f"
}

# 将安装时的数据库凭证、前台/后台地址与默认管理员信息写入部署根（供「更新」免交互读取）；权限 600
# 第三参数：XXGKAMI_SQL_SERIES → 56 或 80（增量更新时选取 kami_mysql56.sql / kami.sql）
_xxgkami_write_install_record_bundle() {
    local home_url="$1" admin_url="$2"
    local sql_series="${3:-80}"
    local rf="${XXGKAMI_DEPLOY_ROOT%/}/.xxgkami-install-record"
    mkdir -p "$XXGKAMI_DEPLOY_ROOT"
    (
        umask 077
        {
            printf '%s\n' "# XXGKAMI 一键安装记录（机密文件，chmod 600，请勿泄露或入库）"
            printf '%s=%s\n' "XXGKAMI_DB_USER" "$DB_USER"
            printf '%s=%s\n' "XXGKAMI_DB_PASSWORD" "$DB_PASSWORD"
            printf '%s=%s\n' "XXGKAMI_HOME_URL" "$home_url"
            printf '%s=%s\n' "XXGKAMI_ADMIN_URL" "$admin_url"
            printf '%s=%s\n' "XXGKAMI_ADMIN_USER" "admin"
            printf '%s=%s\n' "XXGKAMI_ADMIN_PASSWORD" "123456"
            printf '%s=%s\n' "XXGKAMI_SQL_SERIES" "$sql_series"
        } >"$rf.$$" && mv -f "$rf.$$" "$rf"
    )
    chmod 600 "$rf" 2>/dev/null || true
}

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}请使用 root 权限运行此脚本${NC}"
  exit 1
fi

# 向导「安装 MySQL」时写入 56 / 80；为空则仅按 MYSQL_DETECTED_VARIANT 与版本推断 SQL 脚本
XXGKAMI_USER_SQL_SERIES=""

# ---------- 国内 / 外网判定（全局，供分步安装与 Git 仓库使用）----------
detect_network_region() {
    IS_CHINA=false
    if curl -s --connect-timeout 5 https://www.google.com >/dev/null 2>&1; then
        echo -e "${GREEN}检测到国外网络环境${NC}"
        GIT_REPO="https://github.com/xiaoxiaoguai-yyds/xxgkami-pro.git"
    else
        IS_CHINA=true
        echo -e "${GREEN}检测到国内网络环境${NC}"
        GIT_REPO="https://gitee.com/xiaoxiaoguai-yyds/xxgkami-pro.git"
    fi
}

# ---------- 运行时版本判定：0 表示已满足要求，1 表示需安装或版本过低 ----------
# 宝塔 Nginx：/www/server/nginx/sbin/nginx（不可用 APT 自带的 /usr/sbin/nginx + /usr/share/nginx/modules/*.so；否则宝塔无法接管）
need_nginx_install() {
    local v ng
    for ng in "/www/server/nginx/sbin/nginx" "/www/server/nginx/bin/nginx"; do
        [ -x "$ng" ] || continue
        v=$("$ng" -v 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -n 1)
        [ -n "$v" ] && awk -v a="$v" 'BEGIN {exit !(a >= 1.18)}' && return 0
    done
    if ! command -v nginx >/dev/null 2>&1; then return 1; fi
    v=$(nginx -v 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -n 1)
    [ -n "$v" ] && awk -v a="$v" 'BEGIN {exit !(a >= 1.18)}'
}

need_mysql_install() {
    local v mysql_ver_str
    if ! command -v mysql >/dev/null 2>&1; then return 1; fi
    mysql_ver_str=$(mysql -V 2>&1)
    v=$(echo "$mysql_ver_str" | sed -n 's/.*Distrib \([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p')
    if [ -z "$v" ]; then
        v=$(echo "$mysql_ver_str" | sed -n 's/.*Ver \([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p')
    fi
    [ -z "$v" ] && return 1
    if ! awk -v a="$v" 'BEGIN {exit !(a > 5.0)}'; then return 1; fi
    # 仅检测到客户端不够：要求本地 mysqld/mariadb 已运行并可响应 ping（避免 dpk g 半截仍显示「通过」）
    if systemctl list-unit-files 2>/dev/null | grep -qE '^mysql\.service'; then
        systemctl is-active --quiet mysql 2>/dev/null || return 1
    elif systemctl list-unit-files 2>/dev/null | grep -qE '^mysqld\.service'; then
        systemctl is-active --quiet mysqld 2>/dev/null || return 1
    elif systemctl list-unit-files 2>/dev/null | grep -qE '^mariadb\.service'; then
        systemctl is-active --quiet mariadb 2>/dev/null || return 1
    else
        # 无 systemd 列表时退化为 ping
        :
    fi
    _mysql_ping_ok && return 0
    return 1
}

# 在未检测到可用 MySQL 时，在安装前询问主版本（影响后续种子 SQL）
_xxgkami_prompt_mysql_major_for_install() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━ MySQL 主版本选择 ━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}建议选择 ${YELLOW}MySQL 8.0 ${GREEN}[1]${NC}"
    echo -e "  · 与各发行版 ${YELLOW}mysql-server ${NC}契合度高，兼容性更好。"
    echo -e "  · 安装成功后默认导入仓库内 ${YELLOW}databaes/kami.sql ${NC}(或 database/kami.sql)。"
    echo ""
    echo -e "${YELLOW}MySQL 5.6 / 5.x 兼容脚本 [2]${NC}"
    echo -e "  · 将导入 ${YELLOW}databaes/kami_mysql56.sql ${NC}(或 database/kami_mysql56.sql)，适合旧语法/低版本服务端。"
    echo -e "${RED}注意：Ubuntu 22+ / EL9 等默认源通常无 Oracle MySQL 5.6；若选此项，脚本会优先尝试安装 ${YELLOW}MariaDB Server ${RED}承载数据，仍失败时请改选 [1]。${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -r -p "请选择 [1]=MySQL8.0 [2]=5.x/5.6脚本 (默认 1): " _msql_pick
    case "${_msql_pick:-1}" in
        2|56|5.6|5.7)
            XXGKAMI_USER_SQL_SERIES="56"
            echo -e "${YELLOW}已记录：种子 SQL → kami_mysql56.sql 系列${NC}"
            ;;
        *)
            XXGKAMI_USER_SQL_SERIES="80"
            echo -e "${GREEN}已记录：种子 SQL → kami.sql（MySQL 8.0 配套）${NC}"
            ;;
    esac
}

# 若为 56、或检测到 MySQL 版本在 [5.6, 8.0) 且无用户强制 80 → 选用 kami_mysql56.sql
_xxgkami_should_use_kami_mysql56_sql() {
    if [ "${XXGKAMI_USER_SQL_SERIES:-}" = "56" ]; then
        return 0
    fi
    if [ "${XXGKAMI_USER_SQL_SERIES:-}" = "80" ]; then
        return 1
    fi
    if [ "${MYSQL_DETECTED_VARIANT:-}" = "5" ]; then
        return 0
    fi
    return 1
}

# 根据目录与上文规则，选出存在的种子 SQL 路径（兼容 database/ 与 databaes 拼写）
_xxgkami_pick_kami_seed_sql_file() {
    local inst="${1%/}" p=""
    local k8_a="${inst}/databaes/kami.sql"
    local k8_b="${inst}/database/kami.sql"
    local k56_a="${inst}/databaes/kami_mysql56.sql"
    local k56_b="${inst}/database/kami_mysql56.sql"

    if _xxgkami_should_use_kami_mysql56_sql; then
        for p in "$k56_a" "$k56_b"; do
            [ -f "$p" ] && { echo "$p"; return 0; }
        done
        echo -e "${YELLOW}[SQL] 未找到 kami_mysql56.sql ，将回退为 kami.sql（若仍失败请检查仓库）。${NC}" >&2
    fi
    for p in "$k8_a" "$k8_b"; do
        [ -f "$p" ] && { echo "$p"; return 0; }
    done
    return 1
}

need_redis_install() {
    local v
    if command -v redis-server >/dev/null 2>&1; then
        v=$(redis-server -v 2>/dev/null | grep -oE 'v=[0-9]+\.[0-9]+' | cut -d= -f2 | head -n 1)
    elif command -v redis-cli >/dev/null 2>&1; then
        v=$(redis-cli --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -n 1)
    else
        return 1
    fi
    [ -z "$v" ] && return 1
    awk -v a="$v" 'BEGIN {exit !(a >= 6.0)}'
}

need_java_install() {
    local j
    if ! command -v java >/dev/null 2>&1; then return 1; fi
    j=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    j=${j%%.*}
    [ "$j" = "1" ] && j=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.' '{print $2}')
    [ -z "$j" ] && return 1
    [ "$j" -ge 20 ] 2>/dev/null || return 1
    return 0
}

# Maven 在非登录 shell 或未 source profile 时需有效 JAVA_HOME；Temurin/OpenJDK RPM 已装但未 export 时会报 JAVA_HOME incorrectly defined
_xxgkami_ensure_java_home() {
    export JAVA_HOME
    if [ -n "${JAVA_HOME:-}" ] && [ -x "${JAVA_HOME}/bin/java" ] && [ -x "${JAVA_HOME}/bin/javac" ]; then
        export PATH="$JAVA_HOME/bin:${PATH}"
        echo -e "${BLUE}[Java] JAVA_HOME=${JAVA_HOME}${NC}"
        return 0
    fi
    if [ -n "${JAVA_HOME:-}" ]; then
        unset JAVA_HOME
        echo -e "${YELLOW}[Java] JAVA_HOME 未指向完整 JDK（将按 java 可执行文件推断） …${NC}"
    fi
    if ! command -v java >/dev/null 2>&1; then
        echo -e "${RED}[Java] PATH 中无 java，请先安装 JDK 20+${NC}"
        return 1
    fi
    local jb
    jb="$(command -v java)"
    jb="$(readlink -f "$jb")"
    JAVA_HOME="$(dirname "$(dirname "$jb")")"
    export JAVA_HOME
    export PATH="$JAVA_HOME/bin:${PATH}"
    if [ ! -x "${JAVA_HOME}/bin/javac" ]; then
        local jd
        for jd in /usr/lib/jvm/*; do
            [ -x "${jd}/bin/javac" ] || continue
            JAVA_HOME="${jd}"
            export JAVA_HOME
            export PATH="$JAVA_HOME/bin:${PATH}"
            break
        done
    fi
    if [ ! -x "${JAVA_HOME}/bin/javac" ]; then
        echo -e "${RED}[Java] 未找到 JDK（需 bin/javac），仅 JRE 无法运行 Maven 编译${NC}"
        return 1
    fi
    echo -e "${BLUE}[Java] JAVA_HOME=${JAVA_HOME}${NC}"
    return 0
}

need_node_install() {
    local nv
    if ! command -v node >/dev/null 2>&1; then return 1; fi
    nv=$(node -v 2>/dev/null | sed 's/^v//' | grep -oE '^[0-9]+')
    [ -z "$nv" ] && return 1
    [ "$nv" -ge 22 ] 2>/dev/null || return 1
    return 0
}

_run_nodesource_setup_22() {
    local url="https://deb.nodesource.com/setup_22.x"
    if [ "$IS_CHINA" = true ]; then
        echo -e "${YELLOW}Node：经 gh-proxy.com 加速拉取 NodeSource 安装脚本…${NC}"
        url="${GH_PROXY_CN}/https://deb.nodesource.com/setup_22.x"
        if curl -fsSL "$url" -o /tmp/nodesource_setup_22.sh; then
            bash /tmp/nodesource_setup_22.sh
            return $?
        fi
        echo -e "${YELLOW}镜像拉取失败，尝试直连 NodeSource…${NC}"
    fi
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
}

# 卸载系统包 Nginx（与宝塔自带的 Nginx 冲突，会引发「动态模块无法接管 *.so」）
_remove_distro_nginx_for_panel() {
    if [ -f /etc/debian_version ]; then
        systemctl stop nginx 2>/dev/null || true
        systemctl disable nginx 2>/dev/null || true
        DEBIAN_FRONTEND=noninteractive apt-get purge -y nginx nginx-common nginx-core nginx-full nginx-extras nginx-light 2>/dev/null || true
        DEBIAN_FRONTEND=noninteractive apt-get autoremove -y 2>/dev/null || true
    elif [ -f /etc/redhat-release ]; then
        systemctl stop nginx 2>/dev/null || true
        systemctl disable nginx 2>/dev/null || true
        (dnf remove -y nginx nginx-all-modules 2>/dev/null) || (yum remove -y nginx 2>/dev/null) || true
    fi
}

# CentOS/RHEL/Rocky/Alma 等：Redis、Certbot、maven 等常以 EPEL 为依赖；未满则静默尝试安装 epel-release
_xxgkami_ensure_epel_rhel_optional() {
    [ -f /etc/redhat-release ] || return 0
    if rpm -q epel-release &>/dev/null; then
        return 0
    fi
    echo -e "${YELLOW}[RPM] 尝试安装 epel-release（EPEL：Redis/Certbot 等常见于该仓库）…${NC}"
    if command -v dnf >/dev/null 2>&1; then
        dnf install -y epel-release 2>/dev/null || yum install -y epel-release 2>/dev/null || true
    else
        yum install -y epel-release 2>/dev/null || true
    fi
}

# 安装「运行环境」(Nginx/MySQL/…) 前先同步软件源索引；不做整系统全量 upgrade，避免牵动内核与安全更新策略
_xxgkami_refresh_pkg_index_before_env() {
    echo -e "${BLUE}正在刷新软件包索引（apt-get update / dnf|yum makecache）…${NC}"
    if [ -f /etc/debian_version ]; then
        if ! DEBIAN_FRONTEND=noninteractive apt-get update -y; then
            echo -e "${RED}apt-get update 失败，请检查 /etc/apt/sources.list 与网络。${NC}"
            return 1
        fi
    elif [ -f /etc/redhat-release ]; then
        if command -v dnf >/dev/null 2>&1; then
            if ! dnf makecache -y 2>/dev/null; then
                dnf clean expire-cache >/dev/null 2>&1 || true
                dnf makecache -y 2>/dev/null || echo -e "${YELLOW}[RPM] dnf makecache 未完全成功，可稍后手动执行后再装包。${NC}"
            fi
        elif command -v yum >/dev/null 2>&1; then
            yum makecache fast 2>/dev/null || yum makecache 2>/dev/null || echo -e "${YELLOW}[RPM] yum makecache 未完全成功。${NC}"
        fi
    fi
}

install_nginx_pkg() {
    echo -e "${BLUE}安装 / 配置 Nginx…${NC}"
    local baota_here=false
    [ -d "/www/server/panel" ] && baota_here=true

    if [ "$baota_here" = true ]; then
        echo -e "${YELLOW}检测到宝塔面板：请勿使用 APT/YUM 安装系统 Nginx（会加载 /usr/share/nginx/modules 动态模块导致面板「无法接管」）。${NC}"
        echo -e "${YELLOW}正在尝试停止并卸载系统自带的 Nginx 软件包以便宝塔接管…${NC}"
        _remove_distro_nginx_for_panel

        if [ -x "/www/server/nginx/sbin/nginx" ] || [ -x "/www/server/nginx/bin/nginx" ]; then
            echo -e "${GREEN}已检测到宝塔 Nginx：请在面板「软件商店 / 首页」确认 Nginx 服务为运行状态。${NC}"
            return 0
        fi

        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}【必须】请到宝塔控制台 → 「软件商店」→ 搜索并安装「Nginx」。${NC}"
        echo -e "${YELLOW}若已卸载系统 Nginx，安装完成后宝塔即可正常接管「Nginx 服务」。${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        read -r -p "已在宝塔软件商店完成 Nginx 安装后，输入 y 重新检测（其他键跳过并视为未就绪） [y/N]: " BT_NGINX_OK
        if [[ "$BT_NGINX_OK" =~ ^[Yy]$ ]]; then
            if need_nginx_install >/dev/null 2>&1; then
                echo -e "${GREEN}✓ 宝塔 Nginx 检测通过${NC}"
                return 0
            fi
            echo -e "${RED}仍未检测到可用的 Nginx，请确认软件商店安装成功并已启动${NC}"
        fi
        return 1
    fi

    if [ -f /etc/debian_version ]; then
        DEBIAN_FRONTEND=noninteractive apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
    elif [ -f /etc/redhat-release ]; then
        (command -v dnf >/dev/null 2>&1 && dnf install -y nginx) || yum install -y nginx
    else return 1; fi
    systemctl enable nginx 2>/dev/null || true
    systemctl start nginx 2>/dev/null || true
}

# MySQL systemd 单元名（Debian/Ubuntu 常为 mysql.service，RHEL 常为 mysqld）
_mysql_detect_service_name() {
    if systemctl list-unit-files 2>/dev/null | grep -qE '^mysql\.service'; then
        echo "mysql"
    elif systemctl list-unit-files 2>/dev/null | grep -qE '^mysqld\.service'; then
        echo "mysqld"
    elif systemctl list-unit-files 2>/dev/null | grep -qE '^mariadb\.service'; then
        echo "mariadb"
    else
        echo "mysql"
    fi
}

# Debian/Ubuntu：若曾删除 /etc/mysql 或 dpkg 中断，mysql-server postinst 会因
# "update-alternatives: alternative path /etc/mysql/mysql.cnf doesn't exist" 而失败；先补足该文件再继续配置。
_mysql_ensure_etc_mysql_cnf_debian() {
    [ -f /etc/debian_version ] || return 0
    mkdir -p /etc/mysql/conf.d /etc/mysql/mysql.conf.d
    chmod 755 /etc/mysql /etc/mysql/conf.d /etc/mysql/mysql.conf.d 2>/dev/null || true
    if [ -f /etc/mysql/mysql.cnf ]; then
        return 0
    fi
    echo -e "${YELLOW}[MySQL] /etc/mysql/mysql.cnf 缺失，尝试修复 mysql-common 并补齐配置（可避免 dpkg configure 报错）…${NC}"
    DEBIAN_FRONTEND=noninteractive apt-get install -y --reinstall mysql-common 2>/dev/null \
        || DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-common 2>/dev/null \
        || true
    if [ ! -f /etc/mysql/mysql.cnf ]; then
        cat >/etc/mysql/mysql.cnf << 'XXGKAMI_MYSQL_CNF_EOF'
#
# Fallback when packaged mysql.cnf is missing (e.g. /etc/mysql was removed mid-install).
#
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/
XXGKAMI_MYSQL_CNF_EOF
        chmod 644 /etc/mysql/mysql.cnf 2>/dev/null || true
    fi
    return 0
}

# Ubuntu/Debian：修复常见「无法拉起 mysqld」（/var/run/mysqld、数据目录属主、dpkg 中断）
_mysql_fix_runtime_debian() {
    _mysql_ensure_etc_mysql_cnf_debian
    mkdir -p /var/run/mysqld
    if id mysql &>/dev/null; then
        chown mysql:mysql /var/run/mysqld
    elif id _mysql &>/dev/null; then
        chown _mysql:_mysql /var/run/mysqld
    fi
    chmod 755 /var/run/mysqld
    if [ -d /var/lib/mysql ]; then
        if id mysql &>/dev/null; then
            chown -R mysql:mysql /var/lib/mysql
        elif id _mysql &>/dev/null; then
            chown -R _mysql:_mysql /var/lib/mysql
        fi
    fi
    DEBIAN_FRONTEND=noninteractive dpkg --configure -a 2>/dev/null || true
}

# Debian/Ubuntu：为 mysql/mysqladmin 写入默认 socket，避免误认为 /tmp/mysql.sock（小写 mysql -v 会尝试连服务器）
_mysql_write_client_socket_cnf_debian() {
    [ -f /etc/debian_version ] || return 0
    mkdir -p /etc/mysql/conf.d
    local f="/etc/mysql/conf.d/zz-xxgkami-client-socket.cnf"
    local sock="/var/run/mysqld/mysqld.sock"
    [ -S /run/mysqld/mysqld.sock ] && [ ! -S "$sock" ] && sock="/run/mysqld/mysqld.sock"
    cat >"$f" << EOF
# xxgkami install.sh: client default unix socket (prevents ERROR 2002 on /tmp/mysql.sock)
[client]
socket=${sock}

[mysql]
socket=${sock}

[mysqladmin]
socket=${sock}
EOF
    chmod 644 "$f"
}

_mysql_ping_ok() {
    local sock
    for sock in /var/run/mysqld/mysqld.sock /run/mysqld/mysqld.sock; do
        if [ -S "$sock" ]; then
            mysqladmin ping -S "$sock" --silent 2>/dev/null && return 0
            mysqladmin ping -uroot -S "$sock" --silent 2>/dev/null && return 0
            mysql -uroot -S "$sock" -e "SELECT 1" >/dev/null 2>&1 && return 0
            mysql -S "$sock" -e "SELECT 1" >/dev/null 2>&1 && return 0
        fi
    done
    mysqladmin ping --silent 2>/dev/null && return 0
    mysqladmin ping -uroot --silent 2>/dev/null && return 0
    mysql -uroot -e "SELECT 1" >/dev/null 2>&1 && return 0
    mysql -e "SELECT 1" >/dev/null 2>&1 && return 0
    return 1
}

# 客户端显式指向常见 socket（部分环境默认 ~/.my.cnf 或搜索顺序会导致找不到 mysqld.sock）
_mysql_run_mysql() {
    if [ -S /var/run/mysqld/mysqld.sock ]; then
        mysql -S /var/run/mysqld/mysqld.sock "$@"
    elif [ -S /run/mysqld/mysqld.sock ]; then
        mysql -S /run/mysqld/mysqld.sock "$@"
    else
        mysql "$@"
    fi
}

# SQL 字符串中单引号转义为标准 ''（用于字面量）
_xxgkami_sql_escape_single_quotes() {
    printf '%s' "$1" | sed "s/'/''/g"
}

# 与 JDBC 一致的检测：TCP 连 127.0.0.1 + 密码
_xxgkami_mysql_root_tcp_pw_ok() {
    local pw="$1"
    MYSQL_PWD="$pw" mysql -h127.0.0.1 -P3306 -uroot --connect-timeout=5 -e "SELECT 1" >/dev/null 2>&1
}

# 仅走 Unix socket（与 -h127.0.0.1 不同）
_xxgkami_mysql_root_socket_pw_ok() {
    local pw="$1"
    _mysql_run_mysql -uroot -p"$pw" -e "SELECT 1" >/dev/null 2>&1
}

# Ubuntu/Debian 常见 auth_socket：系统 root / mysql 运行时可无密进库
_xxgkami_mysql_root_socket_nopw_ok() {
    _mysql_run_mysql -uroot -e "SELECT 1" >/dev/null 2>&1
}

# 任一路径能通过即视为「密码或本机特权」校验通过
_xxgkami_mysql_root_accept_install_password() {
    local pw="$1"
    _xxgkami_mysql_root_tcp_pw_ok "$pw" && return 0
    _xxgkami_mysql_root_socket_pw_ok "$pw" && return 0
    if [ "$(id -u)" -eq 0 ]; then
        _xxgkami_mysql_root_socket_nopw_ok && return 0
    fi
    return 1
}

# 以 socket+密码优先、其次 socket 免密(socket 管理员)连接 MySQL
_xxgkami_mysql_exec_as_root_admin() {
    local pw="$1"; shift
    if _xxgkami_mysql_root_socket_pw_ok "$pw"; then
        _mysql_run_mysql -uroot -p"$pw" "$@"
        return $?
    fi
    if _xxgkami_mysql_root_socket_nopw_ok; then
        _mysql_run_mysql -uroot "$@"
        return $?
    fi
    return 1
}

# 为 Spring Boot JDBC 写入与「您输入密码」一致的 root TCP 账号（并尽量保留 socket 管理员入口）
_xxgkami_ensure_mysql_root_tcp_same_password() {
    local pw="$1"
    local esc
    esc=$(_xxgkami_sql_escape_single_quotes "$pw")

    if _xxgkami_mysql_root_tcp_pw_ok "$pw"; then
        echo -e "${GREEN}MySQL：root 已可通过 TCP 127.0.0.1 + 密码登录（与 JDBC 兼容）。${NC}"
        return 0
    fi

    echo -e "${YELLOW}检测到 root 尚不能用 TCP（127.0.0.1）+ 密码登录；常见原因为 Debian/Ubuntu 默认 auth_socket。${NC}"
    echo -e "${YELLOW}将使用本机 Unix socket（您输入的 root 密码 或 socket 管理员）执行 ALTER USER，与您输入密码对齐…${NC}"

    if ! _xxgkami_mysql_exec_as_root_admin "$pw" -e "SELECT 1" >/dev/null 2>&1; then
        echo -e "${RED}无法用 socket 以管理员身份连接 MySQL，无法自动写入 TCP root 密码。${NC}"
        return 1
    fi

    # root@localhost：供 jdbc:mysql://localhost:3306/... 与普通本机 mysql -uroot -p
    if ! _xxgkami_mysql_exec_as_root_admin "$pw" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${esc}';" 2>/dev/null; then
        echo -e "${RED}ALTER USER root@localhost 失败（MySQL 需支持该语法；若仍使用纯 auth_socket 请手动改插件后再试）。${NC}"
        return 1
    fi

    # root@127.0.0.1：与 mysql -h127.0.0.1、JDBC 部分场景一致
    if _xxgkami_mysql_exec_as_root_admin "$pw" -e "CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY '${esc}';" 2>/dev/null; then
        _xxgkami_mysql_exec_as_root_admin "$pw" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;" 2>/dev/null || true
    elif _xxgkami_mysql_exec_as_root_admin "$pw" -e "CREATE USER 'root'@'127.0.0.1' IDENTIFIED BY '${esc}';" 2>/dev/null; then
        _xxgkami_mysql_exec_as_root_admin "$pw" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;" 2>/dev/null || true
    else
        _xxgkami_mysql_exec_as_root_admin "$pw" -e "ALTER USER 'root'@'127.0.0.1' IDENTIFIED BY '${esc}';" 2>/dev/null || true
    fi

    _xxgkami_mysql_exec_as_root_admin "$pw" -e "FLUSH PRIVILEGES;" 2>/dev/null || true

    if ! _xxgkami_mysql_root_tcp_pw_ok "$pw"; then
        echo -e "${RED}已执行 ALTER，但自检「mysql -h127.0.0.1 -uroot」仍失败。请检查 mysqld bind-address/skip-networking/firewall。${NC}"
        return 1
    fi
    echo -e "${GREEN}MySQL：已启用 root 通过 TCP 127.0.0.1 + 您输入的密码登录。${NC}"
    return 0
}

_mysql_wait_active_and_ping() {
    local svc="$1"
    local i=0
    local max=50
    systemctl daemon-reload 2>/dev/null || true
    while [ "$i" -lt "$max" ]; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            if _mysql_ping_ok; then
                return 0
            fi
        else
            systemctl start "$svc" 2>/dev/null || true
        fi
        sleep 2
        i=$((i + 1))
    done
    return 1
}

# 参考常见「MySQL 无法启动」排查清单（磁盘/端口/权限/AppArmor/systemd）；DeepSeek 分享页若打不开可逐项对照此处输出
_mysql_diagnose_failed_start() {
    local svc="${1:-mysql}"
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        echo -e "${RED}────────── MySQL：服务已 active，但脚本未能通过 ping/mysql 探测（以下为当时快照）──────────${NC}"
    else
        echo -e "${RED}────────── MySQL 启动失败 · 自检信息 ──────────${NC}"
    fi
    echo -e "${YELLOW}[1] systemd 状态（最近）${NC}"
    systemctl status "$svc" --no-pager -l 2>/dev/null | head -n 28 || true
    echo ""
    echo -e "${YELLOW}[2] journalctl（本服务最近 24 条）${NC}"
    journalctl -u "$svc" -n 24 --no-pager 2>/dev/null || true
    echo ""
    echo -e "${YELLOW}[3] 错误日志（若存在）${NC}"
    tail -n 35 /var/log/mysql/error.log 2>/dev/null || tail -n 35 /var/log/mysqld.log 2>/dev/null || true
    echo ""
    if [ -f /etc/debian_version ]; then
        echo -e "${YELLOW}[3b] Debian/Ubuntu 配置路径（缺 mysql.cnf 会导致 dpkg / update-alternatives 失败）${NC}"
        ls -la /etc/mysql/mysql.cnf /etc/mysql/my.cnf 2>/dev/null || echo "    （/etc/mysql/mysql.cnf 或 my.cnf 不可用）"
        echo ""
    fi
    echo -e "${YELLOW}[4] 3306 端口占用${NC}"
    (command -v ss >/dev/null 2>&1 && ss -tlnp 2>/dev/null | grep -E ':3306\b') || (command -v lsof >/dev/null 2>&1 && lsof -i :3306 2>/dev/null) || echo "（未检测到 ss/lsof 或无占用）"
    echo ""
    echo -e "${YELLOW}[5] 磁盘空间（/var/lib/mysql 所在分区）${NC}"
    df -h /var/lib/mysql 2>/dev/null || df -h /
    echo ""
    echo -e "${YELLOW}[6] 数据目录与 socket 目录权限（摘要）${NC}"
    ls -la /var/run/mysqld 2>/dev/null || true
    ls -la /var/lib/mysql 2>/dev/null | head -n 15 || true
    echo ""
    echo -e "${YELLOW}[7] AppArmor（若安装）与 MySQL 相关配置${NC}"
    if command -v aa-status >/dev/null 2>&1; then
        aa-status 2>/dev/null | grep -i mysql || echo "（无 mysql 相关 profile 或未加载）"
    else
        echo "（未安装 apparmor-utils，可忽略）"
    fi
    if [ -f /etc/apparmor.d/usr.sbin.mysqld ]; then
        echo "  存在: /etc/apparmor.d/usr.sbin.mysqld"
    fi
    echo ""
    echo -e "${YELLOW}[8] SELinux（RHEL 系）${NC}"
    if command -v getenforce >/dev/null 2>&1; then
        getenforce 2>/dev/null || true
    else
        echo "（非 RHEL/无 SELinux）"
    fi
    echo -e "${RED}────────────────────────────────────────────${NC}"
}

# 安装成功后：确保开机自启并已启动，输出客户端/服务端/SQL 版本与 root 密码
_mysql_enable_start_and_report() {
    local svc="$1"
    local pwfile="/root/.xxgkami_mysql_root_password"
    echo -e "${BLUE}━━━━━━━━ MySQL 安装完成 · 状态与版本 ━━━━━━━━${NC}"
    systemctl enable "$svc" 2>/dev/null || true
    systemctl start "$svc" 2>/dev/null || true
    sleep 1
    systemctl is-active --quiet "$svc" 2>/dev/null && \
        echo -e "  服务 ${svc}: ${GREEN}$(systemctl is-active "$svc")${NC}（已 enable + start）" || \
        echo -e "  服务 ${svc}: ${YELLOW}$(systemctl is-active "$svc" 2>/dev/null)${NC}"
    if command -v mysql >/dev/null 2>&1; then
        echo -e "  客户端: $(mysql -V 2>&1)"
    fi
    if command -v mysqld >/dev/null 2>&1; then
        echo -e "  mysqld:  $(mysqld --version 2>&1 | head -n 1)"
    fi
    local ver_sql=""
    if [ -f "$pwfile" ]; then
        local rp
        rp=$(tr -d '\r\n' < "$pwfile")
        ver_sql=$(_mysql_run_mysql -N -B -uroot -p"${rp}" -e "SELECT VERSION();" 2>/dev/null)
    fi
    if [ -z "$ver_sql" ]; then
        ver_sql=$(_mysql_run_mysql -N -B -uroot -e "SELECT VERSION();" 2>/dev/null) \
            || ver_sql=$(_mysql_run_mysql -N -B -e "SELECT VERSION();" 2>/dev/null) \
            || true
    fi
    if [ -n "$ver_sql" ]; then
        echo -e "  服务器版本(SQL): ${GREEN}${ver_sql}${NC}"
    fi
    echo -e "${BLUE}━━━━━━━━ MySQL root 密码（请妥善保存）━━━━━━━━${NC}"
    if [ -f "$pwfile" ]; then
        echo -e "  ${GREEN}$(tr -d '\r\n' < "$pwfile")${NC}"
        echo -e "  文件: ${pwfile}（权限 600）"
    else
        echo -e "  ${YELLOW}未写入密码文件。若系统使用 auth_socket，可用: sudo mysql -uroot${NC}"
    fi
    echo -e "${YELLOW}  提示：仅看客户端版本请用 mysql -V（大写）；mysql -v 会带 verbose 去连服务器。${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 为 root@localhost 设置密码并写入 /root/.xxgkami_mysql_root_password（600）；优先使用本地 socket 免密
_mysql_set_root_password_or_show() {
    local pwfile="/root/.xxgkami_mysql_root_password"
    local NEW_PW
    if [ -f "$pwfile" ]; then
        echo -e "${YELLOW}[MySQL] 已存在密码文件 ${pwfile} ，未重复改密。${NC}"
        return 0
    fi
    if ! _mysql_ping_ok; then
        echo -e "${YELLOW}[MySQL] 服务未就绪，跳过自动设置 root 密码。${NC}"
        return 1
    fi
    if _mysql_run_mysql -uroot -e "SELECT 1" >/dev/null 2>&1 || _mysql_run_mysql -e "SELECT 1" >/dev/null 2>&1; then
        NEW_PW=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 18)
        if _mysql_run_mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${NEW_PW}'; FLUSH PRIVILEGES;" 2>/dev/null; then
            :
        elif _mysql_run_mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${NEW_PW}'; FLUSH PRIVILEGES;" 2>/dev/null; then
            :
        else
            _mysql_run_mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${NEW_PW}'; FLUSH PRIVILEGES;" 2>/dev/null \
                || _mysql_run_mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${NEW_PW}'; FLUSH PRIVILEGES;" 2>/dev/null \
                || {
                    echo -e "${YELLOW}[MySQL] 无法自动 ALTER root 密码（可能已手动配置）。请用 socket 登录后自行设置。${NC}"
                    return 1
                }
        fi
        umask 077
        printf '%s\n' "$NEW_PW" > "$pwfile"
        chmod 600 "$pwfile"
        return 0
    fi
    echo -e "${YELLOW}[MySQL] 当前 root 无法通过本地 socket 免密连接，未自动改密。可尝试: sudo mysql -uroot${NC}"
    return 1
}

install_mysql_pkg() {
    echo -e "${BLUE}安装 MySQL Server…${NC}"
    local mysql_svc
    mysql_svc=$(_mysql_detect_service_name)

    # 当前无可用本机 MySQL 时，在安装前选择种子 SQL 配套（8.0 / 5.x 脚本）
    if need_mysql_install; then
        :
    else
        _xxgkami_prompt_mysql_major_for_install
    fi

    if [ -f /etc/debian_version ]; then
        if [ "$IS_CHINA" = true ]; then
            echo -e "${YELLOW}国内环境：建议使用系统已配置的阿里云 / 清华等 APT 镜像以加速 mysql-server 下载${NC}"
        fi
        _mysql_fix_runtime_debian
        DEBIAN_FRONTEND=noninteractive apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get install -y -f 2>/dev/null || true
        if [ "${XXGKAMI_USER_SQL_SERIES:-}" = "56" ]; then
            echo -e "${YELLOW}[MySQL 5.x/兼容] 优先尝试安装 MariaDB Server（常见发行版源内可用）…${NC}"
            DEBIAN_FRONTEND=noninteractive apt-get install -y \
                mariadb-server mariadb-client 2>/dev/null \
                || DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server 2>/dev/null \
                || true
            _mysql_fix_runtime_debian
            mysql_svc=$(_mysql_detect_service_name)
            if _mysql_wait_active_and_ping "$mysql_svc" || _mysql_ping_ok; then
                _mysql_write_client_socket_cnf_debian
                _mysql_set_root_password_or_show
                _mysql_enable_start_and_report "$mysql_svc"
                return 0
            fi
            echo -e "${YELLOW}[MySQL] MariaDB 未能就绪，回退安装 mysql-server（通常为 8.0）；种子 SQL 将改为 kami.sql。${NC}"
            XXGKAMI_USER_SQL_SERIES="80"
        fi
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
            -o Dpkg::Options::="--force-confold" \
            mysql-server mysql-client 2>/dev/null \
            || DEBIAN_FRONTEND=noninteractive apt-get install -y \
            -o Dpkg::Options::="--force-confold" \
            mysql-server default-mysql-client
        _mysql_fix_runtime_debian
        mysql_svc=$(_mysql_detect_service_name)
        if ! _mysql_wait_active_and_ping "$mysql_svc"; then
            if systemctl is-active --quiet "$mysql_svc" 2>/dev/null && _mysql_ping_ok; then
                echo -e "${GREEN}[MySQL] 轮询结束时未探测到就绪，复检已通过（服务已正常）。${NC}"
            else
                _mysql_diagnose_failed_start "$mysql_svc"
                echo -e "${RED}[MySQL] 服务启动失败，请根据上方自检信息处理。${NC}"
                echo -e "${YELLOW}常见处理：${NC}"
                echo -e "${YELLOW}  · 若为 update-alternatives 报 /etc/mysql/mysql.cnf 不存在：本脚本已尝试自动补齐；仍可执行: sudo apt install --reinstall mysql-common ; sudo dpkg --configure -a${NC}"
                echo -e "${YELLOW}  · 若为数据目录损坏：清理后重装（会删库）: sudo apt purge 'mysql-server*' ; sudo rm -rf /var/lib/mysql /var/log/mysql ; 再执行安装${NC}"
                return 1
            fi
        fi
        _mysql_write_client_socket_cnf_debian
        _mysql_set_root_password_or_show
        _mysql_enable_start_and_report "$mysql_svc"
        return 0

    elif [ -f /etc/redhat-release ]; then
        if [ "$IS_CHINA" = true ]; then
            echo -e "${YELLOW}国内环境：若下载慢请在 yum/dnf 中配置阿里云 Vault / Base 镜像后重试${NC}"
        fi
        if [ "${XXGKAMI_USER_SQL_SERIES:-}" = "56" ]; then
            echo -e "${YELLOW}[MySQL 5.x/兼容] 优先尝试安装 MariaDB Server…${NC}"
            if command -v dnf >/dev/null 2>&1; then
                dnf install -y mariadb-server mariadb 2>/dev/null || dnf install -y mariadb-server 2>/dev/null || true
            else
                yum install -y mariadb-server mariadb 2>/dev/null || yum install -y mariadb-server 2>/dev/null || true
            fi
            mysql_svc=$(_mysql_detect_service_name)
            systemctl enable "$mysql_svc" 2>/dev/null || true
            mkdir -p /var/run/mysqld
            chown mysql:mysql /var/run/mysqld 2>/dev/null || true
            if _mysql_wait_active_and_ping "$mysql_svc" || _mysql_ping_ok; then
                _mysql_set_root_password_or_show
                _mysql_enable_start_and_report "$mysql_svc"
                return 0
            fi
            echo -e "${YELLOW}[MySQL] MariaDB 未能就绪，回退安装 mysql-server；种子 SQL 将改为 kami.sql。${NC}"
            XXGKAMI_USER_SQL_SERIES="80"
        fi
        if command -v dnf >/dev/null 2>&1; then
            dnf install -y mysql-server || yum install -y mysql-server || yum module install -y mysql:8.0
        else
            yum install -y mysql-server || yum module install -y mysql:8.0
        fi
        mysql_svc=$(_mysql_detect_service_name)
        systemctl enable "$mysql_svc" 2>/dev/null || true
        mkdir -p /var/run/mysqld
        chown mysql:mysql /var/run/mysqld 2>/dev/null || true
        if ! _mysql_wait_active_and_ping "$mysql_svc"; then
            if systemctl is-active --quiet "$mysql_svc" 2>/dev/null && _mysql_ping_ok; then
                echo -e "${GREEN}[MySQL] 轮询结束时未探测到就绪，复检已通过（服务已正常）。${NC}"
            else
                _mysql_diagnose_failed_start "$mysql_svc"
                return 1
            fi
        fi
        _mysql_set_root_password_or_show
        _mysql_enable_start_and_report "$mysql_svc"
        return 0
    fi
    return 1
}

install_redis_pkg() {
    echo -e "${BLUE}安装 Redis…${NC}"
    if [ -f /etc/debian_version ]; then
        if [ "$IS_CHINA" = true ]; then
            echo -e "${YELLOW}国内环境：使用系统 APT 镜像源加速 redis-server${NC}"
        fi
        DEBIAN_FRONTEND=noninteractive apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get install -y redis-server
        systemctl enable redis-server
        systemctl start redis-server
    elif [ -f /etc/redhat-release ]; then
        _xxgkami_ensure_epel_rhel_optional
        if command -v dnf >/dev/null 2>&1; then
            dnf install -y redis 2>/dev/null || yum install -y redis
        else
            yum install -y redis || dnf install -y redis 2>/dev/null
        fi
        systemctl enable redis
        systemctl start redis
    else return 1; fi
}

# Debian/Ubuntu：APT 不含 openjdk-20-jdk 时（常见于 Ubuntu 22.04 Jammy），使用 Adoptium Temurin 20
_install_java20_via_temurin_debian() {
    echo -e "${YELLOW}[Java] 系统源无 JDK 20 时改用 Eclipse Temurin（Adoptium）APT …${NC}"
    DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl wget gnupg || true

    mkdir -p /etc/apt/keyrings
    rm -f /etc/apt/keyrings/adoptium.gpg

    ADOPTIUM_KEY_PRIMARY="https://packages.adoptium.net/artifactory/api/security/keyhub/gpg/pub?name=eclipse-adoptium-archive-key.asc"
    ADOPTIUM_KEY_FALLBACK="https://packages.adoptium.net/artifactory/api/gpg/key/public"

    if [ "$IS_CHINA" = true ]; then
        if curl -fsSL "${GH_PROXY_CN}/${ADOPTIUM_KEY_FALLBACK}" | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg 2>/dev/null; then
            :
        elif wget -qO- "${GH_PROXY_CN}/${ADOPTIUM_KEY_FALLBACK}" 2>/dev/null | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg 2>/dev/null; then
            :
        elif curl -fsSL "${ADOPTIUM_KEY_PRIMARY}" | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg 2>/dev/null; then
            :
        elif curl -fsSL "${ADOPTIUM_KEY_FALLBACK}" | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg 2>/dev/null; then
            :
        else
            wget -qO- "${ADOPTIUM_KEY_FALLBACK}" | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg 2>/dev/null || return 1
        fi
    else
        if curl -fsSL "${ADOPTIUM_KEY_PRIMARY}" | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg 2>/dev/null; then
            :
        elif curl -fsSL "${ADOPTIUM_KEY_FALLBACK}" | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg 2>/dev/null; then
            :
        else
            wget -qO- "${ADOPTIUM_KEY_FALLBACK}" | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg 2>/dev/null || return 1
        fi
    fi

    # shellcheck source=/dev/null
    . /etc/os-release
    local codename="${VERSION_CODENAME:-}"
    [ -z "$codename" ] && codename=$(lsb_release -cs 2>/dev/null)
    if [ -z "$codename" ]; then
        echo -e "${RED}[Java] 无法解析发行版代号（VERSION_CODENAME）。${NC}"
        return 1
    fi

    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb ${codename} main" >/etc/apt/sources.list.d/adoptium.list

    DEBIAN_FRONTEND=noninteractive apt-get update -y
    echo -e "${BLUE}[Java] Adoptium 仓库中常为 LTS（如 21）与新版（如 25），非 LTS 的 20 可能不提供；本项目需 JDK≥20 ，将按版本依次尝试 …${NC}"
    local _jv=""
    for _jv in 21 25 22 23 24 20; do
        if DEBIAN_FRONTEND=noninteractive apt-get install -y "temurin-${_jv}-jdk" 2>/dev/null; then
            echo -e "${GREEN}[Java] 已安装 Eclipse Temurin ${_jv}${NC}"
            return 0
        fi
    done
    echo -e "${RED}[Java] Eclipse Temurin（temurin-21-jdk / 25 …）均安装失败${NC}"
    return 1
}

# CentOS/RHEL/Rocky/Alma：系统源无 OpenJDK20；Adoptium RPM 常为 8/11/17/21/25 等，非 LTS 的 20 在 EL9 / Stream 常缺失，故按「JDK≥20」依次尝试 Temurin
_install_java20_via_temurin_rhel() {
    echo -e "${YELLOW}[Java] 配置 Eclipse Temurin RPM 源，并依次尝试 JDK 21→25→22…→20（需 ≥20 即可编译） …${NC}"

    local adoptium_repo="/etc/yum.repos.d/adoptium.repo"
    local distro_key _orig_distro

    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        if command -v dnf >/dev/null 2>&1; then
            dnf install -y curl 2>/dev/null || yum install -y curl 2>/dev/null || true
        else
            yum install -y curl wget 2>/dev/null || true
        fi
    fi

    if [ ! -f /etc/os-release ]; then
        echo -e "${RED}[Java] 缺少 /etc/os-release ，无法写入 Adoptium baseurl。${NC}"
        return 1
    fi

    # shellcheck source=/dev/null
    . /etc/os-release
    _orig_distro="$(echo "${ID:-}" | tr '[:upper:]' '[:lower:]')"
    distro_key="${_orig_distro}"
    case "$distro_key" in
        ol|"oracle linux"|oracle_linux|oracle*)
            distro_key="oraclelinux"
            ;;
    esac

    xxgkami_write_adoptium_rpm_repo_and_install() {
        local _repo_fn="$1" _slug="$2" _ret=1 _v=""
        cat >"${_repo_fn}" <<EOF
[Adoptium]
name=Eclipse Temurin (Adoptium) — ${_slug}
baseurl=https://packages.adoptium.net/artifactory/rpm/${_slug}/\$releasever/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.adoptium.net/artifactory/api/gpg/key/public
EOF

        echo -e "${BLUE}[Java] Adoptium baseurl distro=${_slug}（源自 /etc/os-release ID=${_orig_distro:-?}）${NC}"

        temurin_versions=(21 25 22 23 24 20)
        if command -v dnf >/dev/null 2>&1; then
            dnf clean expire-cache >/dev/null 2>&1 || true
            dnf makecache -y 2>/dev/null || true
            for _v in "${temurin_versions[@]}"; do
                echo -e "${BLUE}[Java] 尝试安装 temurin-${_v}-jdk …${NC}"
                if dnf install -y "temurin-${_v}-jdk"; then
                    echo -e "${GREEN}[Java] 已安装 Eclipse Temurin ${_v}（≥20，可满足构建）${NC}"
                    _ret=0
                    break
                fi
            done
        else
            yum clean expire-cache >/dev/null 2>&1 || true
            yum makecache fast 2>/dev/null || yum makecache 2>/dev/null || true
            for _v in "${temurin_versions[@]}"; do
                echo -e "${BLUE}[Java] 尝试安装 temurin-${_v}-jdk …${NC}"
                if yum install -y "temurin-${_v}-jdk"; then
                    echo -e "${GREEN}[Java] 已安装 Eclipse Temurin ${_v}（≥20，可满足构建）${NC}"
                    _ret=0
                    break
                fi
            done
        fi
        return "${_ret}"
    }

    if xxgkami_write_adoptium_rpm_repo_and_install "$adoptium_repo" "$distro_key"; then
        unset -f xxgkami_write_adoptium_rpm_repo_and_install 2>/dev/null || true
        return 0
    fi

    if [ "$distro_key" != "rhel" ] && echo "$distro_key" | grep -qxE 'centos|rocky|almalinux'; then
        echo -e "${YELLOW}[Java] distro=${distro_key} 下未找到可用的 temurin-*-jdk，再尝试 RHEL 兼容路径 rhel/\$releasever …${NC}"
        if xxgkami_write_adoptium_rpm_repo_and_install "${adoptium_repo}" "rhel"; then
            unset -f xxgkami_write_adoptium_rpm_repo_and_install 2>/dev/null || true
            return 0
        fi
    fi

    echo -e "${YELLOW}[Java] fallback：再尝试 Adoptium 的 centos 路径 …${NC}"
    if [ "$distro_key" != "centos" ] && xxgkami_write_adoptium_rpm_repo_and_install "${adoptium_repo}" "centos"; then
        unset -f xxgkami_write_adoptium_rpm_repo_and_install 2>/dev/null || true
        return 0
    fi

    unset -f xxgkami_write_adoptium_rpm_repo_and_install 2>/dev/null || true
    echo -e "${RED}[Java] 未能在 Adoptium 仓库装上 temurin-21-jdk（或更新的 22/…/25）；请参见 https://adoptium.net/supported-platforms 与 \$releasever 是否受支持${NC}"
    return 1
}

install_java20_pkg() {
    echo -e "${BLUE}安装 JDK（需 ≥20；CentOS/RHEL 上推荐 Adoptium Temurin 21 LTS 或 25 等）…${NC}"
    if [ -f /etc/debian_version ]; then
        if [ "$IS_CHINA" = true ]; then
            echo -e "${YELLOW}国内环境：可先配置阿里云等 APT 镜像；JDK 若走 Temurin 将按需拉取 Adoptium 仓库${NC}"
        fi
        DEBIAN_FRONTEND=noninteractive apt-get update -y
        if DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-20-jdk 2>/dev/null; then
            return 0
        fi
        echo -e "${YELLOW}[Java] openjdk-20-jdk 在当前源中不可用，尝试 Eclipse Temurin（21 LTS / 新版…） …${NC}"
        if ! _install_java20_via_temurin_debian; then
            echo -e "${RED}[Java] Eclipse Temurin JDK 安装失败（需 ≥20）。${NC}"
            echo -e "${YELLOW}请参考: https://adoptium.net/installation/linux （或改用带 OpenJDK 20 的软件源）。${NC}"
            return 1
        fi
    elif [ -f /etc/redhat-release ]; then
        if [ "$IS_CHINA" = true ]; then
            echo -e "${YELLOW}国内环境：Temurin 需访问 packages.adoptium.net ，若超时请换网络或使用可出海的代理。${NC}"
        fi
        if command -v dnf >/dev/null 2>&1; then
            dnf install -y java-20-openjdk-devel 2>/dev/null && return 0
        fi
        yum install -y java-20-openjdk-devel 2>/dev/null && return 0
        echo -e "${YELLOW}[Java] 系统源未提供 java-20-openjdk-devel ，改用 Eclipse Temurin RPM（temurin-20-jdk）…${NC}"
        if ! _install_java20_via_temurin_rhel; then
            echo -e "${RED}[Java] JDK 20 仍未安装成功。${NC}"
            echo -e "${YELLOW}请参阅: https://adoptium.net/installation/linux 中「CentOS/RHEL/Fedora」一节。${NC}"
            return 1
        fi
    else return 1; fi
}

install_node22_pkg() {
    echo -e "${BLUE}安装 Node.js 22.x…${NC}"
    if [ -f /etc/debian_version ]; then
        DEBIAN_FRONTEND=noninteractive apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg
        _run_nodesource_setup_22
        DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
    elif [ -f /etc/redhat-release ]; then
        yum install -y curl ca-certificates || dnf install -y curl ca-certificates
        if [ "$IS_CHINA" = true ]; then
            curl -fsSL "${GH_PROXY_CN}/https://rpm.nodesource.com/setup_22.x" | bash - || curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
        else
            curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
        fi
        yum install -y nodejs || dnf install -y nodejs
    else return 1; fi
}

print_runtime_needs_summary() {
    echo -e "${BLUE}======== 当前运行时检测结果 ========${NC}"
    need_nginx_install >/dev/null 2>&1 && echo -e "  Nginx    : ${GREEN}[已就绪]$(nginx -v 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -n 1 || true)${NC}" || echo -e "  Nginx    : ${RED}[需安装或升级]${NC}"
    need_mysql_install >/dev/null 2>&1 && echo -e "  MySQL    : ${GREEN}[已就绪]$(mysql -V 2>&1 | head -n 1 | cut -c1-48)…${NC}" || echo -e "  MySQL    : ${RED}[需安装或版本≤5.0 / 缺失客户端]${NC}"
    need_redis_install >/dev/null 2>&1 && echo -e "  Redis    : ${GREEN}[已就绪]${NC}" || echo -e "  Redis    : ${RED}[需安装或升级]${NC}"
    need_java_install >/dev/null 2>&1 && echo -e "  Java JDK : ${GREEN}[已就绪 JDK 20+]${NC}" || echo -e "  Java JDK : ${RED}[需安装或升级]${NC}"
    need_node_install >/dev/null 2>&1 && echo -e "  Node.js  : ${GREEN}[已就绪 $(node -v 2>/dev/null)]${NC}" || echo -e "  Node.js  : ${RED}[需安装或升级至 22+]${NC}"
    echo -e "${BLUE}====================================${NC}"
}

# 按需分步安装：与检测结果展示顺序一致——Nginx → MySQL → Redis → JDK → Node；每步安装后自检，是否继续下一项须手动确认（国内走镜像加速）。
install_runtime_stack_interactive() {
    detect_network_region
    if ! _xxgkami_refresh_pkg_index_before_env; then
        echo -e "${RED}软件源索引刷新失败，请先检查网络与源配置后重试。${NC}"
        exit 1
    fi
    echo -e "${YELLOW}按项检测运行环境（未就绪将逐个询问；全部就绪后才进行代码下载与编译）。${NC}"
    sleep 1

    print_runtime_needs_summary
    ng_ok=false; my_ok=false; rd_ok=false; ja_ok=false; no_ok=false
    need_nginx_install >/dev/null 2>&1 && ng_ok=true
    need_mysql_install >/dev/null 2>&1 && my_ok=true
    need_redis_install >/dev/null 2>&1 && rd_ok=true
    need_java_install >/dev/null 2>&1 && ja_ok=true
    need_node_install >/dev/null 2>&1 && no_ok=true

    if [ "$ng_ok" = true ] && [ "$my_ok" = true ] && [ "$rd_ok" = true ] && [ "$ja_ok" = true ] && [ "$no_ok" = true ]; then
        echo -e "${GREEN}✓ Nginx / MySQL / Redis / JDK / Node 均已就绪，直接进入部署流程。${NC}"
        return 0
    fi

    echo -e "${YELLOW}存在未就绪项：将暂不执行克隆/编译，请按需安装下列环境。${NC}"

    step_nginx=false; step_mysql=false; step_redis=false; step_java=false; step_node=false
    need_nginx_install >/dev/null 2>&1 || step_nginx=true
    need_mysql_install >/dev/null 2>&1 || step_mysql=true
    need_redis_install >/dev/null 2>&1 || step_redis=true
    need_java_install >/dev/null 2>&1 || step_java=true
    need_node_install >/dev/null 2>&1 || step_node=true

    MIR_LABEL="官方下载源"
    [ "$IS_CHINA" = true ] && MIR_LABEL="国内加速（GitHub 类资源：${GH_PROXY_CN}；APT/YUM 请配阿里云等镜像）"

    for comp_tag in nginx mysql redis java node; do
        case $comp_tag in
            nginx)   need_step=$step_nginx;;
            mysql)   need_step=$step_mysql;;
            redis)   need_step=$step_redis;;
            java)    need_step=$step_java;;
            node)    need_step=$step_node;;
            *)       continue;;
        esac
        [ "$need_step" = false ] && continue

        echo ""
        read -r -p "是否现在安装 [$comp_tag] ?（下载源：${MIR_LABEL}） [y/N]: " DO_INSTALL_THIS
        if [[ ! "$DO_INSTALL_THIS" =~ ^[Yy]$ ]]; then
            read -r -p "已跳过该项。是否仍继续处理其余环境？[y/N]: " CONT_REST
            if [[ ! "$CONT_REST" =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}用户结束环境安装向导。${NC}"
                break
            fi
            continue
        fi

        case $comp_tag in
            nginx) install_nginx_pkg ;;
            mysql) install_mysql_pkg ;;
            redis) install_redis_pkg ;;
            java) install_java20_pkg ;;
            node) install_node22_pkg ;;
        esac

        ok=false
        case $comp_tag in
            nginx) need_nginx_install >/dev/null 2>&1 && ok=true;;
            mysql) need_mysql_install >/dev/null 2>&1 && ok=true;;
            redis) need_redis_install >/dev/null 2>&1 && ok=true;;
            java) need_java_install >/dev/null 2>&1 && ok=true;;
            node) need_node_install >/dev/null 2>&1 && ok=true;;
        esac
        if [ "$ok" = true ]; then
            echo -e "${GREEN}✓ [$comp_tag] 安装后检测：通过${NC}"
        else
            echo -e "${RED}✗ [$comp_tag] 安装后检测未通过，请排查日志或手动修复${NC}"
        fi

        read -r -p "是否继续安装下一个环境？[y/N]: " NEXT_OK
        if [[ ! "$NEXT_OK" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}已在本步后暂停，不再继续后续环境安装。${NC}"
            break
        fi
    done

    need_nginx_install >/dev/null 2>&1 && ng_ok=true || ng_ok=false
    need_mysql_install >/dev/null 2>&1 && my_ok=true || my_ok=false
    need_redis_install >/dev/null 2>&1 && rd_ok=true || rd_ok=false
    need_java_install >/dev/null 2>&1 && ja_ok=true || ja_ok=false
    need_node_install >/dev/null 2>&1 && no_ok=true || no_ok=false
    if [ "$ng_ok" = true ] && [ "$my_ok" = true ] && [ "$rd_ok" = true ] && [ "$ja_ok" = true ] && [ "$no_ok" = true ]; then
        echo -e "${GREEN}✓ 运行环境已全部就绪${NC}"
        return 0
    fi

    echo -e "${RED}[错误] 运行环境仍未全部就绪，已中止一键部署后续步骤（下载源码、编译等）。请修好环境后重新执行本脚本。${NC}"
    exit 1
}

show_menu() {
    clear
    # 获取系统信息
    SYS_OS=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d= -f2 | tr -d '"')
    SYS_KERNEL=$(uname -r)
    SYS_ARCH=$(uname -m)
    SYS_MEM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
    SYS_MEM_USED=$(free -h | grep Mem | awk '{print $3}')
    SYS_CPU_MODEL=$(cat /proc/cpuinfo | grep "model name" | head -n 1 | cut -d: -f2 | xargs)
    SYS_CPU_CORES=$(nproc)
    
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}        XXG-KAMI-PRO 一键部署脚本 v1.1          ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo -e "欢迎使用小小怪卡密管理系统安装脚本！"
    echo -e "开源地址: https://github.com/xiaoxiaoguai-yyds/xxgkami-pro"
    echo -e "管理系统售后群: 1050160397"
    echo -e "${BLUE}================================================${NC}"
    echo -e "系统信息:"
    echo -e "  系统版本: $SYS_OS"
    echo -e "  内核版本: $SYS_KERNEL"
    echo -e "  系统架构: $SYS_ARCH"
    echo -e "  CPU型号 : $SYS_CPU_MODEL ($SYS_CPU_CORES 核)"
    echo -e "  内存占用: $SYS_MEM_USED / $SYS_MEM_TOTAL"
    # 辅助函数：状态检查
    check_env_status() {
        local req_ver="$1"
        local cur_ver="$2"
        local is_installed="$3"
        
        if [ "$is_installed" != "true" ]; then
             echo -e "${RED}[未安装]${NC}"
             return
        fi
        
        # 简单版本比较 (使用 awk)
        if awk "BEGIN {exit !($cur_ver >= $req_ver)}"; then
             echo -e "${GREEN}[已安装] ${cur_ver}${NC}"
        else
             echo -e "${YELLOW}[版本过低] ${cur_ver}${NC}"
        fi
    }

    # 收集环境信息
    # 1. OS Check
    if [ -f /etc/debian_version ] || [ -f /etc/redhat-release ]; then
        OS_MSG="${GREEN}[支持]${NC}"
    else
        OS_MSG="${RED}[不支持]${NC}"
    fi

    # 2. Nginx Check (1.18+)
    if command -v nginx >/dev/null 2>&1; then
        NGINX_INSTALLED="true"
        NGINX_VER=$(nginx -v 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -n 1)
    else
        NGINX_INSTALLED="false"
        NGINX_VER="0"
    fi
    NGINX_MSG=$(check_env_status "1.18" "$NGINX_VER" "$NGINX_INSTALLED")

    # 3. MySQL Check（> 5.0；8.0+ 与 5.x 使用不同 SQL）
    if command -v mysql >/dev/null 2>&1; then
        MYSQL_INSTALLED="true"
        # 优先匹配 Distrib x.x, 其次 Ver x.x
        MYSQL_VER=$(mysql -V 2>&1 | grep -oE '(Distrib|Ver) [0-9]+\.[0-9]+' | awk '{print $2}' | head -n 1)
        MYSQL_VER=$(echo "$MYSQL_VER" | grep -oE '[0-9]+\.[0-9]+' | head -n 1)
    else
        MYSQL_INSTALLED="false"
        MYSQL_VER="0"
    fi
    MYSQL_MSG=""
    if [ "$MYSQL_INSTALLED" != "true" ]; then
        MYSQL_MSG="${RED}[未安装]${NC}"
    elif [ -z "$MYSQL_VER" ]; then
        MYSQL_MSG="${YELLOW}[已安装·无法解析版本] 请自行确认已按版本准备正确 SQL${NC}"
    elif awk "BEGIN {exit !($MYSQL_VER > 5.0)}" ; then
        if awk "BEGIN {exit !($MYSQL_VER >= 8.0)}" ; then
            MYSQL_MSG="${GREEN}[已安装] ${MYSQL_VER}${NC} — ${GREEN}可运行 MySQL 8.0+ 配套脚本，请使用默认 kami.sql${NC}"
        else
            MYSQL_MSG="${GREEN}[已安装] ${MYSQL_VER}${NC} — ${YELLOW}可运行 MySQL 5.x 兼容脚本，请使用如 kami_mysql56.sql${NC}"
        fi
    else
        MYSQL_MSG="${RED}[版本过低] ${MYSQL_VER}（需 MySQL 严格大于 5.0）${NC}"
    fi

    # 4. Redis Check (6.0+)
    if command -v redis-server >/dev/null 2>&1; then
        REDIS_INSTALLED="true"
        REDIS_VER=$(redis-server -v | grep -oE 'v=[0-9]+\.[0-9]+' | cut -d= -f2 | head -n 1)
    else
        REDIS_INSTALLED="false"
        REDIS_VER="0"
    fi
    REDIS_MSG=$(check_env_status "6.0" "$REDIS_VER" "$REDIS_INSTALLED")

    # 5. Java Check (20+)
    if command -v java >/dev/null 2>&1; then
        JAVA_INSTALLED="true"
        JAVA_VER=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.' '{print $1}')
        if [ "$JAVA_VER" == "1" ]; then # Handle 1.8
             JAVA_VER=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.' '{print $2}')
        fi
    else
        JAVA_INSTALLED="false"
        JAVA_VER="0"
    fi
    JAVA_MSG=$(check_env_status "20" "$JAVA_VER" "$JAVA_INSTALLED")

    # 6. Node.js Check (22+)
    if command -v node >/dev/null 2>&1; then
        NODE_INSTALLED="true"
        NODE_VER=$(node -v | sed 's/v//' | grep -oE '[0-9]+' | head -n 1)
    else
        NODE_INSTALLED="false"
        NODE_VER="0"
    fi
    NODE_MSG=$(check_env_status "22" "$NODE_VER" "$NODE_INSTALLED")

    echo -e "${BLUE}================================================${NC}"
    echo -e "运行环境检测 (要求 -> 当前状态):"
    echo -e "  Linux系统: CentOS 7+ / Debian 10+ ... -> ${OS_MSG} ${SYS_OS}"
    echo -e "  Nginx    : 1.18+                      -> ${NGINX_MSG}"
    echo -e "  MySQL    : > 5.0（8.0+ 默认 SQL / 5.x 兼容 SQL） -> ${MYSQL_MSG}"
    echo -e "  Redis    : 6.0+                       -> ${REDIS_MSG}"
    echo -e "  Java JDK : 20+                        -> ${JAVA_MSG}"
    echo -e "  Node.js  : 22+                        -> ${NODE_MSG}"
    echo -e ""
    echo -e "  图例: ${GREEN}■ 已满足${NC}  ${YELLOW}■ 版本过低${NC}  ${RED}■ 未安装${NC}"
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
            _RAW_MASTER="https://raw.githubusercontent.com/xiaoxiaoguai-yyds/xxgkami-pro/refs/heads/master/install.sh"
            if wget -O install.sh "${GH_PROXY_CN}/${_RAW_MASTER}" 2>/dev/null || curl -fsSL -o install.sh "${GH_PROXY_CN}/${_RAW_MASTER}"; then
                chmod +x install.sh
            elif wget -O install.sh "$_RAW_MASTER" 2>/dev/null || curl -fsSL -o install.sh "$_RAW_MASTER"; then
                chmod +x install.sh
            else
                echo -e "${RED}脚本下载失败（已尝试 gh-proxy 与直连）${NC}"
                exit 1
            fi
            echo -e "${GREEN}脚本更新完成，请重新运行 ./install.sh${NC}"
            exit 0
            ;;
        4)
            # 定义安装目录变量，因为后续生成脚本需要
            INSTALL_DIR="$XXGKAMI_DEPLOY_ROOT"
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
        5)
            modify_db_config
            # 不需要 break，继续循环
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
WEB_ROOT="$XXGKAMI_WEB_ROOT"
DEPLOY_ROOT="$XXGKAMI_DEPLOY_ROOT"

# 与一键安装对齐：写入 application.properties 整行（供 mvn 打入 JAR）
_xxgkami_embed_set_application_property_line() {
    local _pf="\$1" _pk="\$2" _pv="\$3"
    local _pt="\${_pf}.xxgkembed.\$\$"
    local _afs="/usr/local/lib/xxgkami/application-property-line.awk"
    [ -f "\${_pf}" ] || return 1
    [ -f "\${_afs}" ] || { echo -e "\${YELLOW}缺少 \${_afs}，请重新运行 install.sh 安装/覆盖管理脚本以写入库文件\${NC}"; return 1; }
    awk -v k="\${_pk}" -v v="\${_pv}" -f "\${_afs}" "\${_pf}" > "\${_pt}" && mv "\${_pt}" "\${_pf}"
}
_xxgkami_embed_bake_jdbc_before_mvn() {
    local _pf="\$INSTALL_DIR/backend/src/main/resources/application.properties"
    local _pu="\$1" _pp="\$2"
    [ -f "\${_pf}" ] || { echo -e "\${RED}缺少 \${_pf}\${NC}"; return 1; }
    sed -i 's/\r$//' "\${_pf}" 2>/dev/null || true
    _xxgkami_embed_set_application_property_line "\${_pf}" "spring.datasource.username" "\${_pu}"
    _xxgkami_embed_set_application_property_line "\${_pf}" "spring.datasource.password" "\${_pp}"
}

_xxgkami_embed_ensure_java_home() {
    export JAVA_HOME
    if [ -n "\${JAVA_HOME:-}" ] && [ -x "\${JAVA_HOME}/bin/java" ] && [ -x "\${JAVA_HOME}/bin/javac" ]; then
        export PATH="\${JAVA_HOME}/bin:\${PATH}"
        return 0
    fi
    unset JAVA_HOME
    if ! command -v java >/dev/null 2>&1; then
        echo -e "\${RED}[Java] PATH 无 java\${NC}"
        return 1
    fi
    local jb
    jb="\$(command -v java)"
    jb="\$(readlink -f "\$jb")"
    JAVA_HOME="\$(dirname "\$(dirname "\$jb")")"
    export JAVA_HOME
    export PATH="\${JAVA_HOME}/bin:\${PATH}"
    if [ ! -x "\${JAVA_HOME}/bin/javac" ]; then
        local _jd
        for _jd in /usr/lib/jvm/*; do
            [ -x "\${_jd}/bin/javac" ] || continue
            JAVA_HOME="\${_jd}"
            export JAVA_HOME PATH="\${JAVA_HOME}/bin:\${PATH}"
            break
        done
    fi
    if [ ! -x "\${JAVA_HOME}/bin/javac" ]; then
        echo -e "\${RED}[Java] 未找到 JDK（需 javac）；Maven 无法编译\${NC}"
        return 1
    fi
    echo -e "\${BLUE}[Java] JAVA_HOME=\${JAVA_HOME}\${NC}"
    return 0
}

_xxgkami_embed_refresh_backend_datasource_env() {
    local _du="\$1" _dp="\$2"
    mkdir -p /etc/xxgkami
    chmod 700 /etc/xxgkami 2>/dev/null || true
    printf \$'SPRING_DATASOURCE_USERNAME=%s\n' "\${_du}" > /etc/xxgkami/backend-datasource.env
    printf \$'SPRING_DATASOURCE_PASSWORD=%s\n' "\${_dp}" >> /etc/xxgkami/backend-datasource.env
    chmod 600 /etc/xxgkami/backend-datasource.env
}

_xxgkami_embed_find_frontend_dist_dir() {
    local base="\${1%/}" cand=""
    [ -n "\$base" ] && [ -d "\$base" ] || return 1
    for cand in "\$base/dist" "\$base/frontend/dist" "\$base/vue/dist" "\$base/web/dist" "\$base/admin/dist" "\$base/xxgkami-vue/dist"; do
        if [ -f "\$cand/index.html" ]; then
            printf \$'%s\n' "\${cand%/}"
            return 0
        fi
    done
    return 1
}

_xxgkami_embed_sync_frontend_to_webroot() {
    local install_dir="\${1%/}" web_root="\${2%/}" src=""
    src=\$(_xxgkami_embed_find_frontend_dist_dir "\$install_dir") || true
    if [ -z "\$src" ]; then
        echo -e "\${RED}未找到前端构建产物（需存在 …/dist/index.html）。请确认 npm run build 已成功。\${NC}"
        echo -e "\${YELLOW}已检查: \${install_dir}/dist、(frontend|vue|web|admin|xxgkami-vue)/dist\${NC}"
        return 1
    fi
    echo -e "\${GREEN}前端构建目录: \${src}\${NC}"
    if [ "\$src" = "\$web_root" ]; then
        echo -e "\${GREEN}站点根与构建输出为同一路径，跳过清空/拷贝。\${NC}"
        mkdir -p "\$web_root"
        return 0
    fi
    if [ "\$web_root" = "/usr/share/nginx/html" ] && [ -d "\$web_root" ] && [ -n "\$( ls -A "\$web_root" 2>/dev/null )" ]; then
        mv "\$web_root" "\${web_root}_backup_\$( date +%s )"
    fi
    mkdir -p "\$web_root"
    chmod 775 "\$( dirname "\$web_root" )" 2>/dev/null || true
    rm -rf "\${web_root:?}"/* 2>/dev/null || true
    cp -a "\${src}/." "\$web_root/"
    return 0
}

_xxgkami_embed_configure_maven_china_mirror() {
    if [ "\$IS_CHINA" != true ]; then
        return 0
    fi
    echo -e "\${YELLOW}配置 Maven 阿里云镜像...\${NC}"
    mkdir -p ~/.m2
    cat > ~/.m2/settings.xml <<'SETTINGSXML'
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
SETTINGSXML
}

# 一键安装记录 (.xxgkami-install-record) 优先；否则 env / props；再没有则交互输入
_xxgkami_embed_resolve_db_credentials_for_update() {
    local rf="\${DEPLOY_ROOT%/}/.xxgkami-install-record"
    ENV_DB=/etc/xxgkami/backend-datasource.env
    APP_PROP="\$INSTALL_DIR/backend/src/main/resources/application.properties"
    DB_USER=""
    DB_PWD=""
    local line from_record=false
    
    if [ -f "\$rf" ]; then
        while IFS= read -r line || [ -n "\$line" ]; do
            case "\$line" in
                ''|'#'*) continue ;;
                XXGKAMI_DB_USER=*) DB_USER="\${line#XXGKAMI_DB_USER=}" ;;
                XXGKAMI_DB_PASSWORD=*) DB_PWD="\${line#XXGKAMI_DB_PASSWORD=}" ;;
                *) ;;
            esac
        done < "\$rf"
        if [ -n "\$DB_USER" ] && [ -n "\$DB_PWD" ]; then
            from_record=true
        fi
    fi
    if [ -z "\$DB_USER" ] && [ -f "\$ENV_DB" ]; then
        DB_USER=\$(grep -m1 '^SPRING_DATASOURCE_USERNAME=' "\$ENV_DB" | cut -d= -f2- | tr -d '\r')
    fi
    if [ -z "\$DB_PWD" ] && [ -f "\$ENV_DB" ]; then
        DB_PWD=\$(grep -m1 '^SPRING_DATASOURCE_PASSWORD=' "\$ENV_DB" | cut -d= -f2- | tr -d '\r')
    fi
    if [ -z "\$DB_USER" ] && [ -f "\$APP_PROP" ]; then
        DB_USER=\$(grep -m1 'spring.datasource.username' "\$APP_PROP" | cut -d= -f2- | tr -d '\r')
    fi
    if [ -z "\$DB_PWD" ] && [ -f "\$APP_PROP" ]; then
        DB_PWD=\$(grep -m1 'spring.datasource.password' "\$APP_PROP" | cut -d= -f2- | tr -d '\r')
    fi
    DB_USER=\$(echo "\$DB_USER" | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//')
    DB_PWD=\$(echo "\$DB_PWD" | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//')
    
    if [ -n "\$DB_USER" ] && [ -n "\$DB_PWD" ]; then
        if [ "\$from_record" = true ]; then
            echo -e "\${GREEN}[更新] 已从一键安装备忘文件载入数据库账号: \$rf\${NC}"
        fi
        return 0
    fi
    echo -e "\${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
    echo -e "\${YELLOW}[更新] 未找到或未完整读取安装备忘 \$rf 。\${NC}"
    echo -e "\${YELLOW}[更新] 当前系统很可能不是使用本脚本「一键安装」部署（或备忘录已删除）；且未能从 systemd 环境文件/application.properties 补全。\${NC}"
    echo -e "\${YELLOW}[更新] 请手动输入数据库账号和密码以继续增量更新（密码输入不回显）。\${NC}"
    echo -e "\${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
    local _in_u _in_p=""
    read -r -p "MySQL 用户名 [root]: " _in_u
    [ -z "\$_in_u" ] && _in_u=root
    read -r -s -p "MySQL 密码: " _in_p
    echo ""
    DB_USER="\$(echo "\$_in_u" | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//')"
    DB_PWD="\$(echo "\$_in_p" | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//')"
}

# 根据安装备忘 XXGKAMI_SQL_SERIES（56= kami_mysql56.sql，其它= kami.sql）选取增量合并脚本路径
_xxgkami_embed_pick_seed_sql_path_for_update() {
    local base="\${INSTALL_DIR%/}" rf="\${DEPLOY_ROOT%/}/.xxgkami-install-record" ser="" line="" p=""
    if [ -f "\$rf" ]; then
        while IFS= read -r line || [ -n "\$line" ]; do
            case "\$line" in
                ''|'#'*) continue ;;
                XXGKAMI_SQL_SERIES=*) ser="\${line#XXGKAMI_SQL_SERIES=}" ;;
            esac
        done < "\$rf"
    fi
    ser=\$(echo "\$ser" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//')
    if [ "\$ser" = "56" ]; then
        for p in "\$base/databaes/kami_mysql56.sql" "\$base/database/kami_mysql56.sql"; do
            [ -f "\$p" ] && { echo "\$p"; return 0; }
        done
        for p in "\$base/databaes/kami.sql" "\$base/database/kami.sql"; do
            [ -f "\$p" ] && { echo "\$p"; return 0; }
        done
        echo "\$base/databaes/kami_mysql56.sql"
        return 0
    fi
    for p in "\$base/databaes/kami.sql" "\$base/database/kami.sql"; do
        [ -f "\$p" ] && { echo "\$p"; return 0; }
    done
    echo "\$base/databaes/kami.sql"
    return 0
}

while true; do
    clear
    if systemctl is-active --quiet xxgkami 2>/dev/null; then
        _ST_BE="\${GREEN}运行中\${NC}"
    else
        _ST_BE="\${RED}未运行\${NC}"
    fi
    _ST_NG="\${RED}未运行\${NC}"
    if systemctl is-active --quiet nginx 2>/dev/null || systemctl is-active --quiet openresty 2>/dev/null; then
        _ST_NG="\${GREEN}运行中\${NC}"
    elif command -v pgrep >/dev/null 2>&1 && pgrep -x nginx >/dev/null 2>&1; then
        _ST_NG="\${YELLOW}运行中（nginx 进程在，未见 systemd active）\${NC}"
    fi
    if [ -f "\${WEB_ROOT}/index.html" ]; then
        _ST_FE="\${GREEN}已就绪\${NC} — \${WEB_ROOT}"
    else
        _ST_FE="\${YELLOW}未检测到 index.html\${NC} — \${WEB_ROOT}"
    fi
    echo -e "\${BLUE}━━━━━━━━ 当前运行概况 ━━━━━━━━\${NC}"
    if [ -f /etc/systemd/system/xxgkami.service ]; then
        _RU=\$(systemctl show xxgkami -p User --value 2>/dev/null | tr -d '\r\n')
        [ -z "\$_RU" ] && _RU=root
        if [ "\$_RU" = "root" ]; then
            echo -e "  后端 systemd User（运行身份）             : \${RED}root\${NC} \${YELLOW}[检测：以超级用户运行]\${NC}"
        else
            echo -e "  后端 systemd User（运行身份）             : \${GREEN}\${_RU}\${NC}"
        fi
    else
        echo -e "  后端 systemd User（运行身份）             : \${YELLOW}未检测到 /etc/systemd/system/xxgkami.service\${NC}"
    fi
    echo -e "  后端服务状态 (≈8080/api)                  : \${_ST_BE}"
    echo -e "  Nginx（前端静态 · /api 反代）               : \${_ST_NG}"
    echo -e "  前端（站点 root）                           : \${_ST_FE}"
    echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
    echo ""
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
            echo -e "\${YELLOW}[更新] git pull...\${NC}"
            cd "\$INSTALL_DIR" || { echo -e "\${RED}安装目录不存在: \$INSTALL_DIR\${NC}"; continue; }
            git pull || true
            
            DB_NAME="kami"

            echo -e "\${BLUE}[数据库] 增量合并说明：将把仓库自带全量脚本导入【临时数据库】，再向您已有「\$DB_NAME」库补建新表、mysqldump --insert-ignore 补缺失数据行；不会在「\$DB_NAME」上 DROP/整库替换。\${NC}"

            _xxgkami_embed_resolve_db_credentials_for_update

            if [ -z "\$DB_USER" ] || [ -z "\$DB_PWD" ]; then
                echo -e "\${RED}[更新] 数据库用户名或密码仍为空，已中止。\${NC}"
                continue
            fi

            SQL_FILE="\$(_xxgkami_embed_pick_seed_sql_path_for_update)"
            
            echo -e "\${YELLOW}[数据库] 确保业务库 \$DB_NAME 存在...\${NC}"
            mysql -u"\$DB_USER" -p"\$DB_PWD" -e "CREATE DATABASE IF NOT EXISTS \$DB_NAME DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;" || {
                echo -e "\${RED}[数据库] 无法连接或权限不足（CREATE DATABASE）；请检查账号密码。\${NC}"
                continue
            }
            
            if [ -f "\$SQL_FILE" ]; then
                echo -e "\${YELLOW}[数据库] 正在执行增量合并...\${NC}"
                TEMP_DB="kami_update_temp_\$(date +%s)"
                echo -e "\${BLUE}[数据库] 创建临时库 \$TEMP_DB...\${NC}"
                mysql -u"\$DB_USER" -p"\$DB_PWD" -e "CREATE DATABASE \$TEMP_DB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;" || {
                    echo -e "\${RED}[数据库] 创建临时库失败，跳过库合并。\${NC}"
                    TEMP_DB=""
                }
                if [ -n "\$TEMP_DB" ]; then
                    echo -e "\${BLUE}[数据库] 向临时库导入仓库脚本...\${NC}"
                    if mysql -u"\$DB_USER" -p"\$DB_PWD" "\$TEMP_DB" < "\$SQL_FILE"; then
                        echo -e "\${BLUE}[数据库] 对比表并按需补齐...\${NC}"
                        TEMP_TABLES=\$(mysql -u"\$DB_USER" -p"\$DB_PWD" -N -B -e "SHOW TABLES FROM \$TEMP_DB")
                        for TABLE in \$TEMP_TABLES; do
                            TABLE_EXISTS=\$(mysql -u"\$DB_USER" -p"\$DB_PWD" -N -B -e "SELECT count(*) FROM information_schema.tables WHERE table_schema = '\$DB_NAME' AND table_name = '\$TABLE';")
                            if [ "\$TABLE_EXISTS" -eq 0 ]; then
                                echo -e "\${GREEN}[数据库] 新增表 \$TABLE ，正在写入...\${NC}"
                                mysqldump -u"\$DB_USER" -p"\$DB_PWD" "\$TEMP_DB" "\$TABLE" | mysql -u"\$DB_USER" -p"\$DB_PWD" "\$DB_NAME"
                            else
                                mysqldump -u"\$DB_USER" -p"\$DB_PWD" --no-create-info --insert-ignore --complete-insert "\$TEMP_DB" "\$TABLE" | mysql -u"\$DB_USER" -p"\$DB_PWD" "\$DB_NAME"
                            fi
                        done
                        echo -e "\${GREEN}[数据库] 增量合并完成。\${NC}"
                    else
                        echo -e "\${RED}[数据库] 脚本导入临时库失败，已跳过合并（\$SQL_FILE）。\${NC}"
                    fi
                    echo -e "\${BLUE}[数据库] 删除临时库 \$TEMP_DB...\${NC}"
                    mysql -u"\$DB_USER" -p"\$DB_PWD" -e "DROP DATABASE \$TEMP_DB;" 2>/dev/null || true
                fi
            else
                echo -e "\${YELLOW}[数据库] 未找到 \$SQL_FILE ，跳过合并（后端仍将按 JDBC 编译）。\${NC}"
            fi
            
            _xxgkami_embed_refresh_backend_datasource_env "\$DB_USER" "\$DB_PWD"
            echo -e "\${GREEN}已刷新 /etc/xxgkami/backend-datasource.env\${NC}"
            
            echo -e "\${YELLOW}[后端] 与安装对齐：Maven 阿里云镜像、bake JDBC、mvn package、fat JAR 复制到 \$DEPLOY_ROOT...\${NC}"
            _xxgkami_embed_configure_maven_china_mirror
            cd "\$INSTALL_DIR/backend" || { echo -e "\${RED}后端目录不存在\${NC}"; continue; }
            _xxgkami_embed_bake_jdbc_before_mvn "\$DB_USER" "\$DB_PWD" || { echo -e "\${RED}bake JDBC 写入 application.properties 失败\${NC}"; continue; }
            _xxgkami_embed_ensure_java_home || { echo -e "\${RED}[Java] JAVA_HOME/Maven 需要完整 JDK ，请排查后重试更新\${NC}"; continue; }
            mvn clean package -DskipTests
            _J=\$(find target -maxdepth 1 -type f -name "backend-*.jar" ! -name "*-plain.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" 2>/dev/null | head -n 1)
            [ -z "\$_J" ] && _J=\$(find target -maxdepth 1 -type f -name "backend-*.jar" ! -name "*-sources.jar" 2>/dev/null | head -n 1)
            if [ -z "\$_J" ]; then
                echo -e "\${RED}未在 backend/target 找到 backend-*.jar ，Maven 可能失败。\${NC}"
                continue
            fi
            mkdir -p "\$DEPLOY_ROOT"
            ABS_J="\$DEPLOY_ROOT/\$(basename "\$_J")"
            cp -f "\$INSTALL_DIR/backend/\$_J" "\$ABS_J"
            chmod 664 "\$ABS_J" 2>/dev/null || true
            echo -e "\${GREEN}后端 JAR 已复制到: \$ABS_J\${NC}"
            systemctl restart xxgkami
            
            DEPLOY_ENV=prod
            if [ -f /etc/systemd/system/xxgkami.service ]; then
                _de=\$(grep -Eo -- '-Dspring\\.profiles\\.active=[^[:space:]"]+' /etc/systemd/system/xxgkami.service | head -n1 | sed 's/.*=//')
                [ -n "\$_de" ] && DEPLOY_ENV="\$_de"
            fi
            
            echo -e "\${YELLOW}[前端] 与安装对齐：npm 源、\$DEPLOY_ENV 构建 (\$DEPLOY_ENV=dev 时优先 build:dev)、同步到 \$WEB_ROOT...\${NC}"
            cd "\$INSTALL_DIR" || { echo -e "\${RED}项目根目录不存在\${NC}"; continue; }
            if [ -f ".env.production" ]; then
                sed -i 's|VITE_API_BASE_URL=.*|VITE_API_BASE_URL=/api|g' .env.production
            else
                echo "VITE_API_BASE_URL=/api" > .env.production
            fi
            if [ "\$IS_CHINA" = true ]; then
                npm config set registry https://registry.npmmirror.com/
                npm install
            else
                npm config set registry https://registry.npmjs.org/
                npm install
            fi
            if [ "\$DEPLOY_ENV" = "dev" ]; then
                if grep -q "build:dev" package.json; then
                    npm run build:dev
                else
                    npm run build
                fi
            else
                npm run build
            fi
            _xxgkami_embed_sync_frontend_to_webroot "\$INSTALL_DIR" "\$WEB_ROOT" || { echo -e "\${RED}前端同步失败\${NC}"; continue; }
            echo -e "\${YELLOW}正在修复前端文件权限 (\$WEB_ROOT) ...\${NC}"
            find "\$WEB_ROOT" -type d -exec chmod 775 {} +
            find "\$WEB_ROOT" -type f -exec chmod 664 {} +
            chmod 775 "\$WEB_ROOT" 2>/dev/null || true
            NGINX_USER=root
            if id "www" &>/dev/null; then NGINX_USER=www
            elif id "www-data" &>/dev/null; then NGINX_USER=www-data
            elif id "nginx" &>/dev/null; then NGINX_USER=nginx
            fi
            chown -R "\${NGINX_USER}:\${NGINX_USER}" "\$WEB_ROOT"
            if command -v restorecon &>/dev/null; then
                restorecon -R "\$WEB_ROOT"
            fi
            if [ -d "/www/server/panel" ]; then
                echo -e "\${YELLOW}宝塔：站点 root 请指向 \$WEB_ROOT ；后端 JAR 为 \$ABS_J ；无需双启。\${NC}"
            fi
            
            CURRENT_IP=\$(curl -s -4 --connect-timeout 3 ifconfig.me 2>/dev/null || curl -s --connect-timeout 3 ifconfig.me 2>/dev/null || hostname -I 2>/dev/null | awk '{print \$1}' || echo 127.0.0.1)
            SITE_URL="http://\$CURRENT_IP"
            echo -e "\${BLUE}================================================\${NC}"
            echo -e "\${GREEN}更新完成（与一键安装同源路径）：\${NC}"
            echo -e "管理端地址（示例）       : \$SITE_URL/#/admin"
            echo -e "用户入口（示例）         : \$SITE_URL"
            echo -e "\${GREEN}前端静态路径 (WEB_ROOT) : \$WEB_ROOT\${NC}"
            echo -e "\${GREEN}后端 JAR (DEPLOY_ROOT)  : \$ABS_J\${NC}"
            echo -e "\${BLUE}/api ≈ localhost:8080（由 Nginx 反代）；若已配置 HTTPS/域名请以实际站点为准。\${NC}"
            echo -e "\${BLUE}================================================\${NC}"
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
                rm -rf "\$WEB_ROOT"/*
                rm -f /etc/nginx/conf.d/xxgkami.conf /etc/nginx/conf.d/xxgkami-domain.conf
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
                
                # 删除脚本自身与管理脚本 awk 辅助库
                rm -rf /usr/local/lib/xxgkami
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
    mkdir -p /usr/local/lib/xxgkami
    cat > /usr/local/lib/xxgkami/application-property-line.awk <<'XXGKAMI_PROP_AWK'
{ sub(/\r$/, "") }
substr($0, 1, length(k) + 1) == k "=" { print k "=" v; next }
{ print }
XXGKAMI_PROP_AWK
    chmod 644 /usr/local/lib/xxgkami/application-property-line.awk
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

SKIP_PORT_80=false
SKIP_PORT_3306=false
if need_nginx_install >/dev/null 2>&1; then
    SKIP_PORT_80=true
    echo -e "${GREEN}已检测到 Nginx 已安装且版本满足要求，跳过 80 端口占用检测（视为正常 Web 服务监听）。${NC}"
fi
if need_mysql_install >/dev/null 2>&1; then
    SKIP_PORT_3306=true
    echo -e "${GREEN}已检测到 MySQL 已就绪，跳过 3306 端口占用检测（视为数据库正常监听）。${NC}"
fi

[ "$SKIP_PORT_80" != true ] && check_port 80 "Nginx Web"
check_port 8080 "Backend API"
[ "$SKIP_PORT_3306" != true ] && check_port 3306 "MySQL Database"

echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "${RED}重要提示: 请确保您的服务器防火墙/安全组已开放以下端口:${NC}"
echo -e "${GREEN}  - 80   (TCP) : 用于网站访问${NC}"
echo -e "${GREEN}  - 8080 (TCP) : 用于后端API服务${NC}"
echo -e "${GREEN}  - 3306 (TCP) : (可选) 如果需要远程连接数据库${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"
sleep 3

echo -e "${YELLOW}[1/8] 运行环境：分步检测与安装 Nginx / MySQL / Redis / JDK / Node…${NC}"
install_runtime_stack_interactive

# 2. 工具链（git / maven 等；运行环境已在上一节就绪）
echo -e "${YELLOW}[2/8] 安装构建工具 (git, maven, curl…)…${NC}"

check_mysql_version() {
    echo -e "${YELLOW}[前置检查] 验证 MySQL 版本兼容性...${NC}"
    MYSQL_DETECTED_VARIANT=""
    if ! command -v mysql >/dev/null 2>&1; then
        echo -e "${RED}未检测到 MySQL 客户端，请先安装 MySQL（版本需严格大于 5.0）。${NC}"
        exit 1
    fi

    local mysql_ver_str
    mysql_ver_str=$(mysql -V 2>&1)
    local mysql_ver
    mysql_ver=$(echo "$mysql_ver_str" | sed -n 's/.*Distrib \([0-9]\+\.[0-9]\+\).*/\1/p')
    if [ -z "$mysql_ver" ]; then
        mysql_ver=$(echo "$mysql_ver_str" | sed -n 's/.*Ver \([0-9]\+\.[0-9]\+\).*/\1/p')
    fi

    if [ -z "$mysql_ver" ]; then
        echo -e "${YELLOW}警告: 无法识别当前 MySQL 版本。${NC}"
        echo -e "${YELLOW}若为 MySQL 8.0+，请使用默认 kami.sql；若为 MySQL 5.x（>5.0），请使用 5.x 兼容 SQL（如 kami_mysql56.sql）。${NC}"
        read -p "确认已按实际版本准备对应 SQL 并继续? (y/n): " CONFIRM_VER
        if [ "$CONFIRM_VER" != "y" ] && [ "$CONFIRM_VER" != "Y" ]; then
            echo -e "${RED}退出脚本。${NC}"
            exit 1
        fi
        export MYSQL_DETECTED_VARIANT="unknown"
        return 0
    fi

    echo -e "当前 MySQL 版本: ${mysql_ver}"

    if ! awk "BEGIN {exit !($mysql_ver > 5.0)}"; then
        echo -e "${RED}当前 MySQL 版本为 ${mysql_ver}，需要严格大于 5.0 方可继续。${NC}"
        exit 1
    fi

    if awk "BEGIN {exit !($mysql_ver >= 8.0)}"; then
        echo -e "${GREEN}检测到 MySQL 8.0+，可使用「MySQL 8.0」配套流程与默认 SQL（如 databaes/kami.sql）。${NC}"
        export MYSQL_DETECTED_VARIANT="8"
        return 0
    fi

    if awk "BEGIN {exit !($mysql_ver >= 5.6 && $mysql_ver < 8.0)}"; then
        echo -e "${YELLOW}检测到 MySQL 版本为 ${mysql_ver}（5.6 ≤ 版本 < 8.0）。${NC}"
        echo -e "${YELLOW}将自动选用 5.x 兼容 SQL（kami_mysql56.sql）；若已放入 database/ 或 databaes/ 目录，安装流程将自动查找。${NC}"
        export MYSQL_DETECTED_VARIANT="5"
        return 0
    fi

    if awk "BEGIN {exit !($mysql_ver > 5.0 && $mysql_ver < 5.6)}"; then
        echo -e "${YELLOW}检测到 MySQL ${mysql_ver}（介于 5.0 与 5.6 之间）。将尝试默认 kami.sql；若导入失败请升级至 5.6+ 或 8.0。${NC}"
        export MYSQL_DETECTED_VARIANT="8"
        return 0
    fi

    echo -e "${YELLOW}无法自动分类 MySQL ${mysql_ver}，将按 8.0 配套 kami.sql 继续。${NC}"
    export MYSQL_DETECTED_VARIANT="8"
    return 0
}

check_java() {
    if java -version >/dev/null 2>&1; then
        # 获取 Java 版本号 (例如 20.0.1 -> 20)
        JAVA_VER=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.' '{print $1}')
        if [[ "$JAVA_VER" -ge 20 ]]; then
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
        if [[ "$NODE_VER" -ge 22 ]]; then
            echo -e "${GREEN}Node.js 已安装 (版本: $NODE_VER_FULL)${NC}"
            return 0
        fi
    fi
    return 1
}



# 执行 MySQL 版本检查
check_mysql_version

if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu（索引已在 [1/8] 开始处 apt-get update）
    DEBIAN_FRONTEND=noninteractive apt-get install -y git curl wget unzip maven
elif [ -f /etc/redhat-release ]; then
    # CentOS 7 maven 等在 EPEL 或 PowerTools/Codeready 较多；先做 EPEL 再安装
    _xxgkami_ensure_epel_rhel_optional
    # CentOS/RHEL（优先 dnf）
    if command -v dnf >/dev/null 2>&1; then
        dnf install -y git curl wget unzip maven
    else
        yum install -y git curl wget unzip maven
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

# 宝塔等：站点目录常见 .user.ini 带不可变属性（chattr +i），会导致 rm 失败、git clone 报「目录非空」
_xxgkami_baota_unlock_tree() {
    local root="$1"
    [ -z "$root" ] || [ ! -d "$root" ] && return 0
    command -v chattr >/dev/null 2>&1 || return 0
    find "$root" -name '.user.ini' -exec chattr -i {} + 2>/dev/null || true
    [ -f "$root/.user.ini" ] && chattr -i "$root/.user.ini" 2>/dev/null || true
}

# 腾退安装目录以便重新 git clone（先删，失败则整目录 rename 备份）
_xxgkami_remove_install_dir_for_reclone() {
    local d="$1"
    [ ! -e "$d" ] && return 0
    echo -e "${YELLOW}正在腾退目录（解除 .user.ini 不可变属性后删除）…${NC}"
    _xxgkami_baota_unlock_tree "$d"
    rm -rf "$d" 2>/dev/null || true
    if [ -e "$d" ]; then
        echo -e "${YELLOW}仍未清空，尝试将整目录改名为备份…${NC}"
        _xxgkami_baota_unlock_tree "$d"
        local bak="${d}.xxgkami.bak.$(date +%s)"
        if mv "$d" "$bak" 2>/dev/null; then
            echo -e "${GREEN}已备份为 ${bak}，可稍后手动删除${NC}"
            return 0
        fi
        echo -e "${RED}无法删除或移动 ${d}。请在宝塔「网站」中关闭防篡改，或执行: chattr -i ${d}/.user.ini 后重试。${NC}"
        return 1
    fi
    return 0
}

# 3. 克隆/更新项目
echo -e "${YELLOW}[3/8] 下载项目源码...${NC}"
INSTALL_DIR="$XXGKAMI_DEPLOY_ROOT"
mkdir -p "$(dirname "$INSTALL_DIR")"
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
        
        # 删除原有目录并重新克隆（处理宝塔 .user.ini 等导致 rm 不完全的情况）
        if ! _xxgkami_remove_install_dir_for_reclone "$INSTALL_DIR"; then
            exit 1
        fi

        echo -e "${YELLOW}重新克隆项目...${NC}"
        if ! git clone $GIT_REPO "$INSTALL_DIR"; then
            echo -e "${RED}git clone 失败，请检查网络与仓库地址。${NC}"
            exit 1
        fi
        cd "$INSTALL_DIR" || exit 1
        
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
        cd "$INSTALL_DIR"
        git pull
    fi
else
    if ! git clone $GIT_REPO "$INSTALL_DIR"; then
        echo -e "${RED}git clone 失败。若提示目录非空，请在宝塔对 .user.ini 执行 chattr -i 后删除目录再试。${NC}"
        exit 1
    fi
    cd "$INSTALL_DIR" || exit 1
fi

if [ ! -d "$INSTALL_DIR/backend" ] || [ ! -f "$INSTALL_DIR/backend/pom.xml" ]; then
    echo -e "${RED}[3/8] 源码不完整：缺少 ${INSTALL_DIR}/backend（克隆未成功或目录被占用）。请修复后重新运行脚本。${NC}"
    exit 1
fi
cd "$INSTALL_DIR" || exit 1

# 4. 数据库配置
echo -e "${YELLOW}[4/8] 配置数据库...${NC}"
DB_NAME="kami"
DB_USER="root"

while true; do
    read -p "请输入 MySQL root 密码: " DB_PASSWORD

    echo -e "${YELLOW}正在验证数据库连接（TCP、socket+密码、socket 免密管理员 任一可用即可）…${NC}"
    if _xxgkami_mysql_root_accept_install_password "$DB_PASSWORD"; then
        echo -e "${GREEN}能通过其中一种方式连上 MySQL。${NC}"
        if _xxgkami_mysql_root_socket_nopw_ok && ! _xxgkami_mysql_root_socket_pw_ok "$DB_PASSWORD" && ! _xxgkami_mysql_root_tcp_pw_ok "$DB_PASSWORD"; then
            echo -e "${YELLOW}[说明] 当前凭本机 Unix socket（免密/admin）连通；将把您刚才输入的值设为 root 的数据库密码，并启用 TCP(JDBC)+密码。${NC}"
        fi
        if ! _xxgkami_ensure_mysql_root_tcp_same_password "$DB_PASSWORD"; then
            echo -e "${RED}无法为 JDBC 就绪 TCP root 账号，后端仍将无法访问数据库；安装中止。${NC}"
            exit 1
        fi
        break
    else
        echo -e "${RED}数据库连接失败! 密码错误、无本机 socket 权限或 mysqld 未启动。${NC}"
        echo -e "${YELLOW}Ubuntu/Debian 若仅配置过 auth_socket，可先执行 sudo mysql 确认能进库，再重试本脚本（将用您输入的密码写入 TCP）。${NC}"
        read -p "是否重试? (y/n): " RETRY_CHOICE
        if [ "$RETRY_CHOICE" != "y" ] && [ "$RETRY_CHOICE" != "Y" ]; then
            echo -e "${RED}放弃配置数据库，脚本退出。${NC}"
            exit 1
        fi
    fi
done

# 创建数据库并导入数据
SQL_FILE=""
if p=$(_xxgkami_pick_kami_seed_sql_file "$INSTALL_DIR"); then
    SQL_FILE="$p"
    echo -e "${GREEN}种子 SQL 文件：${SQL_FILE}${NC}"
else
    SQL_FILE="$INSTALL_DIR/databaes/kami.sql"
    if [ ! -f "$SQL_FILE" ] && [ -f "$INSTALL_DIR/database/kami.sql" ]; then
        SQL_FILE="$INSTALL_DIR/database/kami.sql"
    fi
    echo -e "${YELLOW}[SQL] 未在仓库中找到预期种子脚本，将尝试：${SQL_FILE}${NC}"
fi

SKIP_SQL_IMPORT=false

if [ -f "$SQL_FILE" ]; then
    echo ""
    echo -e "${BLUE}━━━━━━━━ 数据库「${DB_NAME}」写入提示 ━━━━━━━━${NC}"
    echo -e "  · 即将执行的 SQL 将直接作用于 ${RED}${DB_NAME}${NC}（建库、建表并写入初始化/迁移数据）。"
    echo -e "  · 若当前系统中 ${GREEN}没有${NC}名为「${DB_NAME}」的数据库（或为空库），一般会直接导入，无需额外备份。"
    echo -e "  · 若「${DB_NAME}」${YELLOW}已存在${NC}且${RED}含业务数据表${NC}，请先 ${YELLOW}mysqldump / 宝塔备份${NC} 后再确认；贸然导入可能导致 ${RED}数据丢失或与现有结构冲突${NC}。"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    KAMI_EXISTS=0
    TABLE_COUNT=0
    SCHEMA_CNT=$(mysql -u"$DB_USER" -p"$DB_PASSWORD" -N -s -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='${DB_NAME}'" 2>/dev/null)
    SCHEMA_CNT=$(echo "$SCHEMA_CNT" | tr -dc '0-9')
    SCHEMA_CNT=${SCHEMA_CNT:-0}
    [ "$SCHEMA_CNT" -ge 1 ] 2>/dev/null && KAMI_EXISTS=1

    if [ "$KAMI_EXISTS" -eq 1 ]; then
        TABLE_COUNT=$(mysql -u"$DB_USER" -p"$DB_PASSWORD" -N -s -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='${DB_NAME}' AND TABLE_TYPE='BASE TABLE'" 2>/dev/null)
        TABLE_COUNT=$(echo "$TABLE_COUNT" | tr -dc '0-9')
        TABLE_COUNT=${TABLE_COUNT:-0}
    fi

    if [ "$KAMI_EXISTS" -eq 0 ]; then
        echo -e "${GREEN}检测结果：未发现「${DB_NAME}」数据库，将新建该库后继续导入初始化数据。${NC}"
    elif [ "${TABLE_COUNT:-0}" -eq 0 ]; then
        echo -e "${YELLOW}检测结果：数据库「${DB_NAME}」已存在，但未检测到业务表；将在该库内执行导入（通常为初始化表结构）。${NC}"
    else
        echo -e "${YELLOW}检测结果：数据库「${DB_NAME}」已存在，且检测到 ${TABLE_COUNT} 张数据表（可能已有业务数据）。${NC}"
    fi

    if [ "$IS_UPDATE_MODE" == "true" ]; then
        if [ "$KAMI_EXISTS" -eq 1 ] && [ "${TABLE_COUNT:-0}" -gt 0 ]; then
            echo -e "${RED}当前将进行「数据库智能更新」（合并临时库到 ${DB_NAME}），可能影响现有表与数据。${NC}"
            read -r -p "请先完成备份后再选择。确认继续？[y/N]: " CONFIRM_DB_UPDATE
            if [[ ! "$CONFIRM_DB_UPDATE" =~ ^[Yy]$ ]]; then
                SKIP_SQL_IMPORT=true
                echo -e "${YELLOW}已跳过数据库智能更新步骤。${NC}"
            fi
        elif [ "$KAMI_EXISTS" -eq 0 ]; then
            echo -e "${GREEN}未发现「${DB_NAME}」，将先创建数据库再执行初始化/更新流程。${NC}"
        fi
        if [ "$SKIP_SQL_IMPORT" = false ]; then
        echo -e "${YELLOW}正在执行数据库智能更新...${NC}"
        TEMP_DB="kami_update_temp_$(date +%s)"
        
        mysql -u$DB_USER -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;" 2>/dev/null
        
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
        fi
        
    else
        if [ "$KAMI_EXISTS" -eq 1 ] && [ "${TABLE_COUNT:-0}" -gt 0 ]; then
            echo ""
            echo -e "${RED}警告：数据库「${DB_NAME}」中已存在数据表，再继续将执行 SQL 脚本导入（可能覆盖或破坏现有业务数据）。${NC}"
            read -r -p "请先备份数据库。是否确认覆盖式导入？[y/N]: " CONFIRM_SQL_OVERWRITE
            if [[ ! "$CONFIRM_SQL_OVERWRITE" =~ ^[Yy]$ ]]; then
                SKIP_SQL_IMPORT=true
                echo -e "${YELLOW}已跳过导入。请备份后按需手动导入，或使用「更新」模式再做合并。应用需连接已有「${DB_NAME}」时请确保数据完整。${NC}"
            fi
        fi

        if [ "$SKIP_SQL_IMPORT" = false ]; then
            echo -e "${GREEN}正在导入数据库（${SQL_FILE}）→ ${DB_NAME} …${NC}"
            mysql -u$DB_USER -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;"
            mysql -u$DB_USER -p"$DB_PASSWORD" $DB_NAME < "$SQL_FILE"
        fi
    fi
else
    echo -e "${RED}错误：找不到数据库文件 $SQL_FILE${NC}"
fi

_xxgkami_write_db_env_for_systemd
echo -e "${GREEN}已写入 /etc/xxgkami/backend-datasource.env（仅 systemctl 启动时读取；宝塔「Java项目」独立启动时请依赖即将打入 JAR 的 application.properties）${NC}"

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

echo -e "${YELLOW}[5/8-1] 正在将安装时录入的 MySQL 账号写入 application.properties（随 mvn 打入 JAR，供宝塔等非 systemd 场景使用）…${NC}"
_xxgkami_bake_backend_datasource_props "$PWD/src/main/resources/application.properties" "$DB_PASSWORD" || exit 1
echo -e "${GREEN}已设置 spring.datasource.username=root，密码已写入（不在终端回显）。${NC}"
echo -e "${YELLOW}[5/8-2] Maven 打包（mvn clean package）…${NC}"

_xxgkami_ensure_java_home || exit 1
mvn clean package -DskipTests

# 将可运行 fat JAR 固定复制到项目部署根目录（供 systemd 与宝塔任务引用）
mkdir -p "$XXGKAMI_DEPLOY_ROOT"
JAR_FILE=$(find target -maxdepth 1 -type f -name "backend-*.jar" ! -name "*-plain.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" 2>/dev/null | head -n 1)
if [ -z "$JAR_FILE" ]; then
    JAR_FILE=$(find target -maxdepth 1 -type f -name "backend-*.jar" ! -name "*-sources.jar" 2>/dev/null | head -n 1)
fi
if [ -z "$JAR_FILE" ]; then
    echo -e "${RED}未在 backend/target 下找到 backend-*.jar，Maven 构建可能失败${NC}"
    exit 1
fi
JAR_BASENAME=$(basename "$JAR_FILE")
ABS_JAR_PATH="$XXGKAMI_DEPLOY_ROOT/$JAR_BASENAME"
cp -f "$INSTALL_DIR/backend/$JAR_FILE" "$ABS_JAR_PATH"
chmod 664 "$ABS_JAR_PATH" 2>/dev/null || true
echo -e "${GREEN}后端 JAR 已复制到: $ABS_JAR_PATH${NC}"
if [ -d "/www/server/panel" ]; then
    echo -e "${YELLOW}宝塔「Java项目」若指向旧 JAR，请在面板中改用上述路径的文件并重启；不要与「systemctl xxgkami」同时启动两套后端（端口 8080 会冲突）。${NC}"
fi

# 创建系统服务 (支持开机自启)
SERVICE_FILE="/etc/systemd/system/xxgkami.service"

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
After=syslog.target network.target mysql.service mysqld.service mariadb.service

[Service]
User=root
EnvironmentFile=/etc/xxgkami/backend-datasource.env
# JVM 参数必须在 -jar 之前，否则 Java 会把 -D/-X 当成 JAR 路径而立刻失败（导致 Nginx 502）
ExecStart=$JAVA_PATH $JAVA_OPTS -jar $ABS_JAR_PATH
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
_ru=$(systemctl show xxgkami -p User --value 2>/dev/null | tr -d '\r\n')
[ -z "$_ru" ] && _ru=root
if [ "$_ru" = "root" ]; then
    echo -e "${YELLOW}检测：后端 systemd 运行用户为 root；输入命令「xxgkami」可在菜单中再次查看。${NC}"
else
    echo -e "${GREEN}检测：后端 systemd 运行用户为 ${_ru}${NC}"
fi
unset _ru

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
    echo -e "${YELLOW}使用 npmmirror 镜像...${NC}"
    npm config set registry https://registry.npmmirror.com/
    npm install
else
    echo -e "${YELLOW}使用官方 npm 源...${NC}"
    npm config set registry https://registry.npmjs.org/
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

# 部署到 Nginx Web 目录（与环境变量 XXGKAMI_WEB_ROOT 一致）
NGINX_WEB_ROOT="$XXGKAMI_WEB_ROOT"

if ! _xxgkami_sync_frontend_to_webroot "$INSTALL_DIR" "$NGINX_WEB_ROOT"; then
    echo -e "${RED}前端部署失败，请检查 npm run build 日志与目录结构。${NC}"
    exit 1
fi

# [修复] 目录 775 / 文件 664（组可写常见于 www 与同组运维；可被面板或 umask 再调整）
echo -e "${YELLOW}正在修复前端文件权限 (${NGINX_WEB_ROOT}) ...${NC}"
find "$NGINX_WEB_ROOT" -type d -exec chmod 775 {} +
find "$NGINX_WEB_ROOT" -type f -exec chmod 664 {} +
chmod 775 "$NGINX_WEB_ROOT"

# 自动检测 Nginx 用户（宝塔常见 www）
NGINX_USER="root"
if id "www" &>/dev/null; then
    NGINX_USER="www"
elif id "www-data" &>/dev/null; then
    NGINX_USER="www-data"
elif id "nginx" &>/dev/null; then
    NGINX_USER="nginx"
fi
echo -e "${GREEN}检测到 Nginx 用户: ${NGINX_USER}${NC}"
chown -R "${NGINX_USER}:${NGINX_USER}" "$NGINX_WEB_ROOT"

# 尝试修复 SELinux 上下文 (如果存在 restorecon 命令)
if command -v restorecon &>/dev/null; then
    echo -e "${YELLOW}尝试修复 SELinux 上下文...${NC}"
    restorecon -R "$NGINX_WEB_ROOT"
fi

echo -e "${GREEN}前端静态文件已部署到 $NGINX_WEB_ROOT${NC}"

if [ -d "/www/server/panel" ]; then
    echo -e "${YELLOW}宝塔面板：请将站点配置中的 root 指向上述 dist 路径（末尾为 …/xxgkami/dist），与 SPA 入口 index.html 一致；/api 反代保持不变。${NC}"
fi

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

# 检测所有可能的 Nginx 配置目录
CONF_DIRS=()
# 1. 系统默认
if [ -d "/etc/nginx/conf.d" ]; then
    CONF_DIRS+=("/etc/nginx/conf.d")
fi
# 2. 宝塔面板
if [ -d "/www/server/panel/vhost/nginx" ]; then
    CONF_DIRS+=("/www/server/panel/vhost/nginx")
    echo -e "${YELLOW}检测到宝塔面板环境${NC}"
    IS_BAOTA=true
else
    IS_BAOTA=false
fi

# 如果没有检测到任何目录，尝试创建系统默认目录
if [ ${#CONF_DIRS[@]} -eq 0 ]; then
    mkdir -p /etc/nginx/conf.d
    CONF_DIRS+=("/etc/nginx/conf.d")
fi

# 绑定域名时写入的路径（独立于各 vhost 目录下的分发逻辑）
NGINX_CONF="/etc/nginx/conf.d/xxgkami-domain.conf"

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
    
    # 重载 Nginx
    if [ "$IS_BAOTA" = true ]; then
        echo -e "${YELLOW}正在重载宝塔 Nginx...${NC}"
        /etc/init.d/nginx reload
        if [ $? -ne 0 ]; then
             echo -e "${YELLOW}尝试使用 systemctl reload nginx...${NC}"
             systemctl reload nginx
        fi
    else
        nginx -t && systemctl restart nginx
    fi
    
    # 4. 询问是否申请 HTTPS
    read -p "是否申请免费 HTTPS 证书 (Let's Encrypt)? (y/n): " HTTPS_CHOICE
    if [ "$HTTPS_CHOICE" == "y" ] || [ "$HTTPS_CHOICE" == "Y" ]; then
        echo -e "${YELLOW}正在安装 Certbot...${NC}"
        if [ -f /etc/debian_version ]; then
            apt-get update
            apt-get install -y certbot python3-certbot-nginx cron
        elif [ -f /etc/redhat-release ]; then
            _xxgkami_ensure_epel_rhel_optional
            if command -v dnf >/dev/null 2>&1; then
                dnf install -y certbot python3-certbot-nginx cronie \
                    || { yum install -y certbot python3-certbot-nginx cronie; }
            else
                yum install -y certbot python3-certbot-nginx cronie
            fi
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
    # 不绑定域名，默认使用服务器 IPv4 地址
    echo -e "${YELLOW}未绑定域名，正在配置默认 IP 访问...${NC}"
    
    # 1. 获取服务器公网 IP (优先 IPv4)
    PUBLIC_IP=$(curl -s -4 ifconfig.me)
    if [ -z "$PUBLIC_IP" ]; then
        PUBLIC_IP=$(curl -s ifconfig.me)
    fi
    
    if [ -z "$PUBLIC_IP" ]; then
        SERVER_NAME="_"
        echo -e "${YELLOW}无法获取公网 IP，使用默认通配符 '_'${NC}"
    else
        SERVER_NAME="$PUBLIC_IP"
        echo -e "${GREEN}将使用服务器 IP: ${SERVER_NAME} 进行配置${NC}"
    fi

    # 生成配置内容到临时变量
    NGINX_CONFIG_CONTENT=$(cat <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name $SERVER_NAME;

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
)

    # 遍历所有配置目录进行写入和清理（宝塔 vhost 由面板管理，不向该目录写入以免与现有站点/default_server 冲突）
    for CONF_DIR in "${CONF_DIRS[@]}"; do
        if [ "$IS_BAOTA" = true ] && [ "$CONF_DIR" = "/www/server/panel/vhost/nginx" ]; then
            echo -e "${YELLOW}跳过宝塔 vhost 目录（使用面板站点 + 已由脚本部署静态文件到 ${NGINX_WEB_ROOT}）: $CONF_DIR${NC}"
            continue
        fi
        TARGET_CONF="$CONF_DIR/xxgkami.conf"
        
        # 备份原有配置
        if [ -f "$TARGET_CONF" ]; then
            cp "$TARGET_CONF" "${TARGET_CONF}.bak_$(date +%Y%m%d%H%M%S)"
        fi

        # 禁用默认配置
        if [ -f "$CONF_DIR/0.default.conf" ]; then
            mv "$CONF_DIR/0.default.conf" "$CONF_DIR/0.default.conf.bak"
            echo -e "${YELLOW}已禁用默认配置: $CONF_DIR/0.default.conf${NC}"
        fi
        if [ -f "$CONF_DIR/default.conf" ]; then
            mv "$CONF_DIR/default.conf" "$CONF_DIR/default.conf.bak"
            echo -e "${YELLOW}已禁用默认配置: $CONF_DIR/default.conf${NC}"
        fi
        
        # 写入新配置
        echo "$NGINX_CONFIG_CONTENT" > "$TARGET_CONF"
        echo -e "${GREEN}Nginx 配置已写入: $TARGET_CONF${NC}"
    done

    # 额外清理 sites-enabled/default
    if [ -f /etc/nginx/sites-enabled/default ]; then
        rm -f /etc/nginx/sites-enabled/default
        echo -e "${YELLOW}已移除 /etc/nginx/sites-enabled/default${NC}"
    fi

    # 检查 Nginx 配置并重启
    nginx -t
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}正在尝试重载 Nginx 服务...${NC}"
        
        # 尝试重载宝塔 Nginx
        if [ -f "/etc/init.d/nginx" ]; then
             /etc/init.d/nginx reload
        fi
        
        # 尝试重载系统 Nginx
        if command -v systemctl >/dev/null 2>&1; then
             systemctl reload nginx 2>/dev/null || systemctl restart nginx
        fi
        
        echo -e "${GREEN}Nginx 服务已尝试重载/重启${NC}"
    else
        echo -e "${RED}Nginx 配置语法有误，请检查配置文件${NC}"
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
WEB_ROOT="$XXGKAMI_WEB_ROOT"
DEPLOY_ROOT="$XXGKAMI_DEPLOY_ROOT"

# 与一键安装对齐：写入 application.properties 整行（供 mvn 打入 JAR）
_xxgkami_embed_set_application_property_line() {
    local _pf="\$1" _pk="\$2" _pv="\$3"
    local _pt="\${_pf}.xxgkembed.\$\$"
    local _afs="/usr/local/lib/xxgkami/application-property-line.awk"
    [ -f "\${_pf}" ] || return 1
    [ -f "\${_afs}" ] || { echo -e "\${YELLOW}缺少 \${_afs}，请重新运行 install.sh 安装/覆盖管理脚本以写入库文件\${NC}"; return 1; }
    awk -v k="\${_pk}" -v v="\${_pv}" -f "\${_afs}" "\${_pf}" > "\${_pt}" && mv "\${_pt}" "\${_pf}"
}
_xxgkami_embed_bake_jdbc_before_mvn() {
    local _pf="\$INSTALL_DIR/backend/src/main/resources/application.properties"
    local _pu="\$1" _pp="\$2"
    [ -f "\${_pf}" ] || { echo -e "\${RED}缺少 \${_pf}\${NC}"; return 1; }
    sed -i 's/\r$//' "\${_pf}" 2>/dev/null || true
    _xxgkami_embed_set_application_property_line "\${_pf}" "spring.datasource.username" "\${_pu}"
    _xxgkami_embed_set_application_property_line "\${_pf}" "spring.datasource.password" "\${_pp}"
}

_xxgkami_embed_ensure_java_home() {
    export JAVA_HOME
    if [ -n "\${JAVA_HOME:-}" ] && [ -x "\${JAVA_HOME}/bin/java" ] && [ -x "\${JAVA_HOME}/bin/javac" ]; then
        export PATH="\${JAVA_HOME}/bin:\${PATH}"
        return 0
    fi
    unset JAVA_HOME
    if ! command -v java >/dev/null 2>&1; then
        echo -e "\${RED}[Java] PATH 无 java\${NC}"
        return 1
    fi
    local jb
    jb="\$(command -v java)"
    jb="\$(readlink -f "\$jb")"
    JAVA_HOME="\$(dirname "\$(dirname "\$jb")")"
    export JAVA_HOME
    export PATH="\${JAVA_HOME}/bin:\${PATH}"
    if [ ! -x "\${JAVA_HOME}/bin/javac" ]; then
        local _jd
        for _jd in /usr/lib/jvm/*; do
            [ -x "\${_jd}/bin/javac" ] || continue
            JAVA_HOME="\${_jd}"
            export JAVA_HOME PATH="\${JAVA_HOME}/bin:\${PATH}"
            break
        done
    fi
    if [ ! -x "\${JAVA_HOME}/bin/javac" ]; then
        echo -e "\${RED}[Java] 未找到 JDK（需 javac）；Maven 无法编译\${NC}"
        return 1
    fi
    echo -e "\${BLUE}[Java] JAVA_HOME=\${JAVA_HOME}\${NC}"
    return 0
}

_xxgkami_embed_refresh_backend_datasource_env() {
    local _du="\$1" _dp="\$2"
    mkdir -p /etc/xxgkami
    chmod 700 /etc/xxgkami 2>/dev/null || true
    printf \$'SPRING_DATASOURCE_USERNAME=%s\n' "\${_du}" > /etc/xxgkami/backend-datasource.env
    printf \$'SPRING_DATASOURCE_PASSWORD=%s\n' "\${_dp}" >> /etc/xxgkami/backend-datasource.env
    chmod 600 /etc/xxgkami/backend-datasource.env
}

_xxgkami_embed_find_frontend_dist_dir() {
    local base="\${1%/}" cand=""
    [ -n "\$base" ] && [ -d "\$base" ] || return 1
    for cand in "\$base/dist" "\$base/frontend/dist" "\$base/vue/dist" "\$base/web/dist" "\$base/admin/dist" "\$base/xxgkami-vue/dist"; do
        if [ -f "\$cand/index.html" ]; then
            printf \$'%s\n' "\${cand%/}"
            return 0
        fi
    done
    return 1
}

_xxgkami_embed_sync_frontend_to_webroot() {
    local install_dir="\${1%/}" web_root="\${2%/}" src=""
    src=\$(_xxgkami_embed_find_frontend_dist_dir "\$install_dir") || true
    if [ -z "\$src" ]; then
        echo -e "\${RED}未找到前端构建产物（需存在 …/dist/index.html）。请确认 npm run build 已成功。\${NC}"
        echo -e "\${YELLOW}已检查: \${install_dir}/dist、(frontend|vue|web|admin|xxgkami-vue)/dist\${NC}"
        return 1
    fi
    echo -e "\${GREEN}前端构建目录: \${src}\${NC}"
    if [ "\$src" = "\$web_root" ]; then
        echo -e "\${GREEN}站点根与构建输出为同一路径，跳过清空/拷贝。\${NC}"
        mkdir -p "\$web_root"
        return 0
    fi
    if [ "\$web_root" = "/usr/share/nginx/html" ] && [ -d "\$web_root" ] && [ -n "\$( ls -A "\$web_root" 2>/dev/null )" ]; then
        mv "\$web_root" "\${web_root}_backup_\$( date +%s )"
    fi
    mkdir -p "\$web_root"
    chmod 775 "\$( dirname "\$web_root" )" 2>/dev/null || true
    rm -rf "\${web_root:?}"/* 2>/dev/null || true
    cp -a "\${src}/." "\$web_root/"
    return 0
}

_xxgkami_embed_configure_maven_china_mirror() {
    if [ "\$IS_CHINA" != true ]; then
        return 0
    fi
    echo -e "\${YELLOW}配置 Maven 阿里云镜像...\${NC}"
    mkdir -p ~/.m2
    cat > ~/.m2/settings.xml <<'SETTINGSXML'
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
SETTINGSXML
}

# 一键安装记录 (.xxgkami-install-record) 优先；否则 env / props；再没有则交互输入
_xxgkami_embed_resolve_db_credentials_for_update() {
    local rf="\${DEPLOY_ROOT%/}/.xxgkami-install-record"
    ENV_DB=/etc/xxgkami/backend-datasource.env
    APP_PROP="\$INSTALL_DIR/backend/src/main/resources/application.properties"
    DB_USER=""
    DB_PWD=""
    local line from_record=false
    
    if [ -f "\$rf" ]; then
        while IFS= read -r line || [ -n "\$line" ]; do
            case "\$line" in
                ''|'#'*) continue ;;
                XXGKAMI_DB_USER=*) DB_USER="\${line#XXGKAMI_DB_USER=}" ;;
                XXGKAMI_DB_PASSWORD=*) DB_PWD="\${line#XXGKAMI_DB_PASSWORD=}" ;;
                *) ;;
            esac
        done < "\$rf"
        if [ -n "\$DB_USER" ] && [ -n "\$DB_PWD" ]; then
            from_record=true
        fi
    fi
    if [ -z "\$DB_USER" ] && [ -f "\$ENV_DB" ]; then
        DB_USER=\$(grep -m1 '^SPRING_DATASOURCE_USERNAME=' "\$ENV_DB" | cut -d= -f2- | tr -d '\r')
    fi
    if [ -z "\$DB_PWD" ] && [ -f "\$ENV_DB" ]; then
        DB_PWD=\$(grep -m1 '^SPRING_DATASOURCE_PASSWORD=' "\$ENV_DB" | cut -d= -f2- | tr -d '\r')
    fi
    if [ -z "\$DB_USER" ] && [ -f "\$APP_PROP" ]; then
        DB_USER=\$(grep -m1 'spring.datasource.username' "\$APP_PROP" | cut -d= -f2- | tr -d '\r')
    fi
    if [ -z "\$DB_PWD" ] && [ -f "\$APP_PROP" ]; then
        DB_PWD=\$(grep -m1 'spring.datasource.password' "\$APP_PROP" | cut -d= -f2- | tr -d '\r')
    fi
    DB_USER=\$(echo "\$DB_USER" | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//')
    DB_PWD=\$(echo "\$DB_PWD" | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//')
    
    if [ -n "\$DB_USER" ] && [ -n "\$DB_PWD" ]; then
        if [ "\$from_record" = true ]; then
            echo -e "\${GREEN}[更新] 已从一键安装备忘文件载入数据库账号: \$rf\${NC}"
        fi
        return 0
    fi
    echo -e "\${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
    echo -e "\${YELLOW}[更新] 未找到或未完整读取安装备忘 \$rf 。\${NC}"
    echo -e "\${YELLOW}[更新] 当前系统很可能不是使用本脚本「一键安装」部署（或备忘录已删除）；且未能从 systemd 环境文件/application.properties 补全。\${NC}"
    echo -e "\${YELLOW}[更新] 请手动输入数据库账号和密码以继续增量更新（密码输入不回显）。\${NC}"
    echo -e "\${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
    local _in_u _in_p=""
    read -r -p "MySQL 用户名 [root]: " _in_u
    [ -z "\$_in_u" ] && _in_u=root
    read -r -s -p "MySQL 密码: " _in_p
    echo ""
    DB_USER="\$(echo "\$_in_u" | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//')"
    DB_PWD="\$(echo "\$_in_p" | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//')"
}

# 根据安装备忘 XXGKAMI_SQL_SERIES（56= kami_mysql56.sql，其它= kami.sql）选取增量合并脚本路径
_xxgkami_embed_pick_seed_sql_path_for_update() {
    local base="\${INSTALL_DIR%/}" rf="\${DEPLOY_ROOT%/}/.xxgkami-install-record" ser="" line="" p=""
    if [ -f "\$rf" ]; then
        while IFS= read -r line || [ -n "\$line" ]; do
            case "\$line" in
                ''|'#'*) continue ;;
                XXGKAMI_SQL_SERIES=*) ser="\${line#XXGKAMI_SQL_SERIES=}" ;;
            esac
        done < "\$rf"
    fi
    ser=\$(echo "\$ser" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//')
    if [ "\$ser" = "56" ]; then
        for p in "\$base/databaes/kami_mysql56.sql" "\$base/database/kami_mysql56.sql"; do
            [ -f "\$p" ] && { echo "\$p"; return 0; }
        done
        for p in "\$base/databaes/kami.sql" "\$base/database/kami.sql"; do
            [ -f "\$p" ] && { echo "\$p"; return 0; }
        done
        echo "\$base/databaes/kami_mysql56.sql"
        return 0
    fi
    for p in "\$base/databaes/kami.sql" "\$base/database/kami.sql"; do
        [ -f "\$p" ] && { echo "\$p"; return 0; }
    done
    echo "\$base/databaes/kami.sql"
    return 0
}

while true; do
    clear
    if systemctl is-active --quiet xxgkami 2>/dev/null; then
        _ST_BE="\${GREEN}运行中\${NC}"
    else
        _ST_BE="\${RED}未运行\${NC}"
    fi
    _ST_NG="\${RED}未运行\${NC}"
    if systemctl is-active --quiet nginx 2>/dev/null || systemctl is-active --quiet openresty 2>/dev/null; then
        _ST_NG="\${GREEN}运行中\${NC}"
    elif command -v pgrep >/dev/null 2>&1 && pgrep -x nginx >/dev/null 2>&1; then
        _ST_NG="\${YELLOW}运行中（nginx 进程在，未见 systemd active）\${NC}"
    fi
    if [ -f "\${WEB_ROOT}/index.html" ]; then
        _ST_FE="\${GREEN}已就绪\${NC} — \${WEB_ROOT}"
    else
        _ST_FE="\${YELLOW}未检测到 index.html\${NC} — \${WEB_ROOT}"
    fi
    echo -e "\${BLUE}━━━━━━━━ 当前运行概况 ━━━━━━━━\${NC}"
    if [ -f /etc/systemd/system/xxgkami.service ]; then
        _RU=\$(systemctl show xxgkami -p User --value 2>/dev/null | tr -d '\r\n')
        [ -z "\$_RU" ] && _RU=root
        if [ "\$_RU" = "root" ]; then
            echo -e "  后端 systemd User（运行身份）             : \${RED}root\${NC} \${YELLOW}[检测：以超级用户运行]\${NC}"
        else
            echo -e "  后端 systemd User（运行身份）             : \${GREEN}\${_RU}\${NC}"
        fi
    else
        echo -e "  后端 systemd User（运行身份）             : \${YELLOW}未检测到 /etc/systemd/system/xxgkami.service\${NC}"
    fi
    echo -e "  后端服务状态 (≈8080/api)                  : \${_ST_BE}"
    echo -e "  Nginx（前端静态 · /api 反代）               : \${_ST_NG}"
    echo -e "  前端（站点 root）                           : \${_ST_FE}"
    echo -e "\${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
    echo ""
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
            echo -e "\${YELLOW}[更新] git pull...\${NC}"
            cd "\$INSTALL_DIR" || { echo -e "\${RED}安装目录不存在: \$INSTALL_DIR\${NC}"; continue; }
            git pull || true
            
            DB_NAME="kami"

            echo -e "\${BLUE}[数据库] 增量合并说明：将把仓库自带全量脚本导入【临时数据库】，再向您已有「\$DB_NAME」库补建新表、mysqldump --insert-ignore 补缺失数据行；不会在「\$DB_NAME」上 DROP/整库替换。\${NC}"

            _xxgkami_embed_resolve_db_credentials_for_update

            if [ -z "\$DB_USER" ] || [ -z "\$DB_PWD" ]; then
                echo -e "\${RED}[更新] 数据库用户名或密码仍为空，已中止。\${NC}"
                continue
            fi

            SQL_FILE="\$(_xxgkami_embed_pick_seed_sql_path_for_update)"
            
            echo -e "\${YELLOW}[数据库] 确保业务库 \$DB_NAME 存在...\${NC}"
            mysql -u"\$DB_USER" -p"\$DB_PWD" -e "CREATE DATABASE IF NOT EXISTS \$DB_NAME DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;" || {
                echo -e "\${RED}[数据库] 无法连接或权限不足（CREATE DATABASE）；请检查账号密码。\${NC}"
                continue
            }
            
            if [ -f "\$SQL_FILE" ]; then
                echo -e "\${YELLOW}[数据库] 正在执行增量合并...\${NC}"
                TEMP_DB="kami_update_temp_\$(date +%s)"
                echo -e "\${BLUE}[数据库] 创建临时库 \$TEMP_DB...\${NC}"
                mysql -u"\$DB_USER" -p"\$DB_PWD" -e "CREATE DATABASE \$TEMP_DB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;" || {
                    echo -e "\${RED}[数据库] 创建临时库失败，跳过库合并。\${NC}"
                    TEMP_DB=""
                }
                if [ -n "\$TEMP_DB" ]; then
                    echo -e "\${BLUE}[数据库] 向临时库导入仓库脚本...\${NC}"
                    if mysql -u"\$DB_USER" -p"\$DB_PWD" "\$TEMP_DB" < "\$SQL_FILE"; then
                        echo -e "\${BLUE}[数据库] 对比表并按需补齐...\${NC}"
                        TEMP_TABLES=\$(mysql -u"\$DB_USER" -p"\$DB_PWD" -N -B -e "SHOW TABLES FROM \$TEMP_DB")
                        for TABLE in \$TEMP_TABLES; do
                            TABLE_EXISTS=\$(mysql -u"\$DB_USER" -p"\$DB_PWD" -N -B -e "SELECT count(*) FROM information_schema.tables WHERE table_schema = '\$DB_NAME' AND table_name = '\$TABLE';")
                            if [ "\$TABLE_EXISTS" -eq 0 ]; then
                                echo -e "\${GREEN}[数据库] 新增表 \$TABLE ，正在写入...\${NC}"
                                mysqldump -u"\$DB_USER" -p"\$DB_PWD" "\$TEMP_DB" "\$TABLE" | mysql -u"\$DB_USER" -p"\$DB_PWD" "\$DB_NAME"
                            else
                                mysqldump -u"\$DB_USER" -p"\$DB_PWD" --no-create-info --insert-ignore --complete-insert "\$TEMP_DB" "\$TABLE" | mysql -u"\$DB_USER" -p"\$DB_PWD" "\$DB_NAME"
                            fi
                        done
                        echo -e "\${GREEN}[数据库] 增量合并完成。\${NC}"
                    else
                        echo -e "\${RED}[数据库] 脚本导入临时库失败，已跳过合并（\$SQL_FILE）。\${NC}"
                    fi
                    echo -e "\${BLUE}[数据库] 删除临时库 \$TEMP_DB...\${NC}"
                    mysql -u"\$DB_USER" -p"\$DB_PWD" -e "DROP DATABASE \$TEMP_DB;" 2>/dev/null || true
                fi
            else
                echo -e "\${YELLOW}[数据库] 未找到 \$SQL_FILE ，跳过合并（后端仍将按 JDBC 编译）。\${NC}"
            fi
            
            _xxgkami_embed_refresh_backend_datasource_env "\$DB_USER" "\$DB_PWD"
            echo -e "\${GREEN}已刷新 /etc/xxgkami/backend-datasource.env\${NC}"
            
            echo -e "\${YELLOW}[后端] 与安装对齐：Maven 阿里云镜像、bake JDBC、mvn package、fat JAR 复制到 \$DEPLOY_ROOT...\${NC}"
            _xxgkami_embed_configure_maven_china_mirror
            cd "\$INSTALL_DIR/backend" || { echo -e "\${RED}后端目录不存在\${NC}"; continue; }
            _xxgkami_embed_bake_jdbc_before_mvn "\$DB_USER" "\$DB_PWD" || { echo -e "\${RED}bake JDBC 写入 application.properties 失败\${NC}"; continue; }
            _xxgkami_embed_ensure_java_home || { echo -e "\${RED}[Java] JAVA_HOME/Maven 需要完整 JDK ，请排查后重试更新\${NC}"; continue; }
            mvn clean package -DskipTests
            _J=\$(find target -maxdepth 1 -type f -name "backend-*.jar" ! -name "*-plain.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" 2>/dev/null | head -n 1)
            [ -z "\$_J" ] && _J=\$(find target -maxdepth 1 -type f -name "backend-*.jar" ! -name "*-sources.jar" 2>/dev/null | head -n 1)
            if [ -z "\$_J" ]; then
                echo -e "\${RED}未在 backend/target 找到 backend-*.jar ，Maven 可能失败。\${NC}"
                continue
            fi
            mkdir -p "\$DEPLOY_ROOT"
            ABS_J="\$DEPLOY_ROOT/\$(basename "\$_J")"
            cp -f "\$INSTALL_DIR/backend/\$_J" "\$ABS_J"
            chmod 664 "\$ABS_J" 2>/dev/null || true
            echo -e "\${GREEN}后端 JAR 已复制到: \$ABS_J\${NC}"
            systemctl restart xxgkami
            
            DEPLOY_ENV=prod
            if [ -f /etc/systemd/system/xxgkami.service ]; then
                _de=\$(grep -Eo -- '-Dspring\\.profiles\\.active=[^[:space:]"]+' /etc/systemd/system/xxgkami.service | head -n1 | sed 's/.*=//')
                [ -n "\$_de" ] && DEPLOY_ENV="\$_de"
            fi
            
            echo -e "\${YELLOW}[前端] 与安装对齐：npm 源、\$DEPLOY_ENV 构建 (\$DEPLOY_ENV=dev 时优先 build:dev)、同步到 \$WEB_ROOT...\${NC}"
            cd "\$INSTALL_DIR" || { echo -e "\${RED}项目根目录不存在\${NC}"; continue; }
            if [ -f ".env.production" ]; then
                sed -i 's|VITE_API_BASE_URL=.*|VITE_API_BASE_URL=/api|g' .env.production
            else
                echo "VITE_API_BASE_URL=/api" > .env.production
            fi
            if [ "\$IS_CHINA" = true ]; then
                npm config set registry https://registry.npmmirror.com/
                npm install
            else
                npm config set registry https://registry.npmjs.org/
                npm install
            fi
            if [ "\$DEPLOY_ENV" = "dev" ]; then
                if grep -q "build:dev" package.json; then
                    npm run build:dev
                else
                    npm run build
                fi
            else
                npm run build
            fi
            _xxgkami_embed_sync_frontend_to_webroot "\$INSTALL_DIR" "\$WEB_ROOT" || { echo -e "\${RED}前端同步失败\${NC}"; continue; }
            echo -e "\${YELLOW}正在修复前端文件权限 (\$WEB_ROOT) ...\${NC}"
            find "\$WEB_ROOT" -type d -exec chmod 775 {} +
            find "\$WEB_ROOT" -type f -exec chmod 664 {} +
            chmod 775 "\$WEB_ROOT" 2>/dev/null || true
            NGINX_USER=root
            if id "www" &>/dev/null; then NGINX_USER=www
            elif id "www-data" &>/dev/null; then NGINX_USER=www-data
            elif id "nginx" &>/dev/null; then NGINX_USER=nginx
            fi
            chown -R "\${NGINX_USER}:\${NGINX_USER}" "\$WEB_ROOT"
            if command -v restorecon &>/dev/null; then
                restorecon -R "\$WEB_ROOT"
            fi
            if [ -d "/www/server/panel" ]; then
                echo -e "\${YELLOW}宝塔：站点 root 请指向 \$WEB_ROOT ；后端 JAR 为 \$ABS_J ；无需双启。\${NC}"
            fi
            
            CURRENT_IP=\$(curl -s -4 --connect-timeout 3 ifconfig.me 2>/dev/null || curl -s --connect-timeout 3 ifconfig.me 2>/dev/null || hostname -I 2>/dev/null | awk '{print \$1}' || echo 127.0.0.1)
            SITE_URL="http://\$CURRENT_IP"
            echo -e "\${BLUE}================================================\${NC}"
            echo -e "\${GREEN}更新完成（与一键安装同源路径）：\${NC}"
            echo -e "管理端地址（示例）       : \$SITE_URL/#/admin"
            echo -e "用户入口（示例）         : \$SITE_URL"
            echo -e "\${GREEN}前端静态路径 (WEB_ROOT) : \$WEB_ROOT\${NC}"
            echo -e "\${GREEN}后端 JAR (DEPLOY_ROOT)  : \$ABS_J\${NC}"
            echo -e "\${BLUE}/api ≈ localhost:8080（由 Nginx 反代）；若已配置 HTTPS/域名请以实际站点为准。\${NC}"
            echo -e "\${BLUE}================================================\${NC}"
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
                rm -rf "\$WEB_ROOT"/*
                rm -f /etc/nginx/conf.d/xxgkami.conf /etc/nginx/conf.d/xxgkami-domain.conf
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
                
                # 删除脚本自身与管理脚本 awk 辅助库
                rm -rf /usr/local/lib/xxgkami
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
mkdir -p /usr/local/lib/xxgkami
cat > /usr/local/lib/xxgkami/application-property-line.awk <<'XXGKAMI_PROP_AWK'
{ sub(/\r$/, "") }
substr($0, 1, length(k) + 1) == k "=" { print k "=" v; next }
{ print }
XXGKAMI_PROP_AWK
chmod 644 /usr/local/lib/xxgkami/application-property-line.awk
echo -e "${GREEN}管理脚本已安装! 部署完成后输入 'xxgkami' 即可使用。${NC}"

# 9. 服务状态检查与自愈
echo -e "${YELLOW}[9/9] 检查服务运行状态...${NC}"

# 函数：检查并启动服务
check_and_start_service() {
    local service_name=$1
    local display_name=$2
    
    echo -e "${BLUE}[执行命令] systemctl is-active $service_name${NC}"
    # 捕获输出和退出码
    local status_output
    status_output=$(systemctl is-active $service_name 2>&1)
    local status_code=$?

    echo -e "${BLUE}[返回结果] $status_output (退出码: $status_code)${NC}"

    if [ $status_code -eq 0 ]; then
        echo -e "${GREEN}[成功] $display_name 已启动${NC}"
    else
        echo -e "${YELLOW}[警告] $display_name 未运行，正在尝试启动...${NC}"
        echo -e "${BLUE}[执行命令] systemctl start $service_name${NC}"
        
        systemctl start $service_name
        local start_code=$?
        
        if [ $start_code -eq 0 ]; then
             echo -e "${GREEN}[命令执行成功]${NC}"
        else
             echo -e "${RED}[命令执行失败] 退出码: $start_code${NC}"
        fi
        
        sleep 2
        
        echo -e "${BLUE}[复查命令] systemctl is-active $service_name${NC}"
        status_output=$(systemctl is-active $service_name 2>&1)
        status_code=$?
        echo -e "${BLUE}[复查结果] $status_output (退出码: $status_code)${NC}"
        
        if [ $status_code -eq 0 ]; then
            echo -e "${GREEN}[修复] $display_name 启动成功${NC}"
        else
            echo -e "${RED}[失败] $display_name 启动失败，请手动检查日志 (journalctl -u $service_name)${NC}"
        fi
    fi
}

# 检查 Nginx
check_and_start_service "nginx" "Nginx Web服务器"

# 检查 MySQL
if systemctl list-unit-files | grep -q mysqld.service; then
    check_and_start_service "mysqld" "MySQL 数据库"
else
    check_and_start_service "mysql" "MySQL 数据库"
fi

# 检查 Redis
if systemctl list-unit-files | grep -q redis.service; then
    check_and_start_service "redis" "Redis 缓存服务"
elif systemctl list-unit-files | grep -q redis-server.service; then
    check_and_start_service "redis-server" "Redis 缓存服务"
fi

# 检查后端服务
check_and_start_service "xxgkami" "XXG-KAMI 后端服务"

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

REC_SQL_SERIES=80
_xxgkami_should_use_kami_mysql56_sql && REC_SQL_SERIES=56
_xxgkami_write_install_record_bundle "$SITE_URL" "${SITE_URL}/#/admin" "$REC_SQL_SERIES"
echo -e "${GREEN}已写入安装备忘（数据库、首页/管理端地址、默认管理员）: ${XXGKAMI_DEPLOY_ROOT%/}/.xxgkami-install-record${NC}"

echo -e "用户端地址: ${SITE_URL}"
echo -e "管理端地址: ${SITE_URL}/#/admin"
echo -e "------------------------------------------------"
echo -e "${GREEN}前端静态文件路径: ${XXGKAMI_WEB_ROOT}${NC}"
echo -e "${GREEN}后端运行 JAR 路径: ${ABS_JAR_PATH}${NC}"
echo -e "${GREEN}项目源码目录: ${INSTALL_DIR}${NC}"
echo -e "------------------------------------------------"
echo -e "默认管理员账号: admin"
echo -e "默认管理员密码: 123456"
echo -e "------------------------------------------------"
echo -e "数据库账号: ${DB_USER}"
echo -e "数据库密码: ${DB_PASSWORD}"
echo -e "安装备忘文件: ${XXGKAMI_DEPLOY_ROOT%/}/.xxgkami-install-record（含数据库与访问地址、默认管理员）"
echo -e "------------------------------------------------"
echo -e "后端服务状态: systemctl status xxgkami"
echo -e "Nginx状态: systemctl status nginx"
