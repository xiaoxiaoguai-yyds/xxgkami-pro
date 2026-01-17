# 部署指南

## 1. 前端构建
在本地项目根目录运行：
```bash
npm run build
```
这会生成 `dist` 文件夹。将此文件夹上传到服务器（例如 `/www/wwwroot/kami.xxg-yyds.com/dist`）。

## 2. 后端构建
在 `backend` 目录运行：
```bash
mvn clean package -DskipTests
```
这会在 `backend/target` 目录生成 jar 包（例如 `backend-0.0.1-SNAPSHOT.jar`）。将 jar 包上传到服务器。

## 3. Nginx 配置 (解决 404 关键)
你的后端配置了 `server.servlet.context-path=/api`，这意味着后端只处理以 `/api` 开头的请求。

在 Nginx 配置中，`location /api` 的 `proxy_pass` **绝对不能**在末尾加 `/`。

**错误写法：**
```nginx
proxy_pass http://localhost:8080/;  # 会去掉 /api，导致后端接收到 /auth... 从而报 404
```

**正确写法：**
```nginx
proxy_pass http://localhost:8080;   # 保留 /api，后端接收到 /api/auth... 正常处理
```

请参考同目录下的 `nginx.conf` 文件进行配置。

## 4. 启动后端
在服务器上运行：
```bash
nohup java -jar backend-0.0.1-SNAPSHOT.jar > output.log 2>&1 &
```

## 5. 验证
访问 `http://kami.xxg-yyds.com/api/auth/user/login` (POST) 应该能收到后端的响应（可能是 405 Method Not Allowed 如果直接浏览器访问，或者是 JSON 响应）。
如果 Nginx 配置正确，不应该出现 404。
