<div align="center">

<img src="src/assets/icon.gif" alt="icon" width="120" />

# 🚀 小小怪卡密验证系统 Pro

### 🎯 全新一代卡密验证解决方案 - 正式发布！-完全免费-团队维护更新

[![Vue 3](https://img.shields.io/badge/Vue-3.5+-4FC08D?style=for-the-badge&logo=vue.js&logoColor=white)](https://vuejs.org/)
[![Vite](https://img.shields.io/badge/Vite-7.1+-646CFF?style=for-the-badge&logo=vite&logoColor=white)](https://vitejs.dev/)
[![Element Plus](https://img.shields.io/badge/Element%20Plus-2.11+-409EFF?style=for-the-badge&logo=element&logoColor=white)](https://element-plus.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**🔥 采用最新技术栈重构，性能提升300%，用户体验全面升级！**

[🌟 立即体验](https://xiaoxiaoguai-yyds.github.io/web.xxgkami.github.io) · [📖 查看文档](#使用文档) · [🐛 反馈问题](https://github.com/xiaoxiaoguai-yyds/xxgkami-pro/issues) · [💬 加入讨论](https://github.com/xiaoxiaoguai-yyds/xxgkami-pro/discussions)

</div>

---

## � 快速部署指南

本项目提供四种灵活的部署方式，满足不同场景的需求。

### 方式一：Linux 一键脚本安装（推荐 🔥）

适用于 CentOS 7+ / Debian 10+ / Ubuntu 20.04+ 系统，全自动环境配置。

**国内服务器（Gitee 源）：**
```bash
curl -O https://gitee.com/xiaoxiaoguai-yyds/xxgkami-pro/raw/master/install.sh && chmod +x install.sh && sudo ./install.sh
```

**海外服务器（GitHub 源）：**
```bash
curl -O https://raw.githubusercontent.com/xiaoxiaoguai-yyds/xxgkami-pro/refs/heads/master/install.sh && chmod +x install.sh && sudo ./install.sh
```

**脚本功能：**
- ✅ 自动检测网络环境（GitHub/Gitee 源自动切换）
- ✅ 自动安装 JDK 17, MySQL 8.0, Nginx, Node.js 环境
- ✅ 自动编译前后端代码并配置 Systemd 开机自启
- ✅ 自动配置 Nginx 反向代理与静态资源托管

---

### 方式二：Docker 容器化部署 (即将上线 🚧)

适用于熟悉 Docker 的用户，环境隔离，快速启动。

> ⚠️ **注意**：Docker 镜像构建流程正在优化中，敬请期待！

1. **安装 Docker & Docker Compose**
2. **下载 docker-compose.yml**
3. **启动服务**

```bash
# 即将支持
# docker-compose up -d
```

---

### 方式三：宝塔面板部署（编译版）

适用于已有宝塔面板的服务器，使用编译好的制品快速部署。

1. **下载编译制品**：从 [Releases](https://github.com/xiaoxiaoguai-yyds/xxgkami-pro/releases) 下载最新的 `backend.jar` 和 `dist.zip`。
2. **后端部署**：
   - 在宝塔“Java项目”中添加项目。
   - 上传 `backend.jar`，选择 JDK 17。
   - 配置端口 `8080`，并设置数据库连接信息（`application.properties`）。
3. **前端部署**：
   - 在宝塔“网站”中添加静态站点。
   - 上传并解压 `dist.zip` 到网站根目录。
   - 配置 Nginx 反向代理：
     ```nginx
     location /api {
         proxy_pass http://localhost:8080/api;
     }
     ```

---

### 方式四：手动编译部署

适用于开发者或需要深度定制的场景。

**前提条件：** JDK 17+, Maven 3.8+, Node.js 18+, MySQL 8.0+

1. **克隆代码**
   ```bash
   git clone https://github.com/xiaoxiaoguai-yyds/xxgkami-pro.git
   cd xxgkami-pro
   ```

2. **后端编译**
   ```bash
   cd backend
   # 修改 src/main/resources/application.properties 中的数据库配置
   mvn clean package -DskipTests
   java -jar target/backend-0.0.1-SNAPSHOT.jar
   ```

3. **前端编译**
   ```bash
   cd ../
   npm install
   npm run build
   # 构建产物位于 dist/ 目录，可使用 Nginx 进行托管
   ```

---

## 📊 功能模块

### 🎛️ **管理员后台**
- 📈 **数据概览** - 实时统计面板，掌控全局数据
- 🔑 **卡密管理** - 批量生成、导出、状态管理，支持多种卡密类型
- 📋 **订单管理** - 订单实时监控、状态跟踪、补单操作
- 🔌 **API管理** - 接口密钥生成、权限控制、WebHook回调配置
- ⚙️ **系统设置** - 网站信息配置、支付接口对接、邮件通知设置
- 🛡️ **安全中心** - IP黑白名单、访问日志审计

### 👤 **用户中心**
- 🏠 **个人面板** - 账户信息概览、近期活动记录
- 🛒 **购买中心** - 在线选购卡密、支持多种支付方式
- 📱 **卡密验证** - 快速验证卡密有效性、查看使用说明
- 💰 **钱包管理** - 余额充值、消费明细查询
- 🎫 **我的卡密** - 已购卡密历史记录、一键复制

### 🔌 **开发者接口**
- ✅ **卡密验证 API** - 标准化 RESTful 接口，轻松集成
- 📊 **状态查询 API** - 实时查询卡密状态和剩余次数/时间
- 🔔 **WebHook 回调** - 卡密核销实时推送通知
- 🛡️ **安全认证** - 支持 API Key 签名认证，保障数据安全

---

## 🎯 使用场景

### 💼 **软件授权**
- 🖥️ 桌面软件激活
- 📱 移动应用授权
- 🎮 游戏道具验证
- 🔧 插件功能解锁

### 🎓 **在线教育**
- 📚 课程访问控制
- 🎥 视频观看权限
- 📝 考试系统验证
- 🏆 证书颁发管理

### 💰 **电商平台**
- 🎁 优惠券系统
- 🎪 会员权益管理
- 🛍️ 限时抢购控制
- 💎 VIP服务激活

---

## 📈 性能对比

| 功能特性 | 旧版本 | 新版本 Pro | 提升幅度 |
|---------|--------|------------|----------|
| 🚀 页面加载速度 | 3.2s | 0.8s | **300%** ⬆️ |
| 💾 内存占用 | 120MB | 45MB | **62%** ⬇️ |
| 📊 数据处理能力 | 1000/s | 5000/s | **400%** ⬆️ |
| 🔄 并发支持 | 100 | 1000 | **900%** ⬆️ |
| 📱 移动端适配 | 60% | 100% | **40%** ⬆️ |

---

## 🛣️ 开发路线图

### 📅 更新日志

#### v1.0.2 (2026-02-09)
- 🐛 **注册修复**：修复用户注册时因邮件配置缺失导致的 500 错误，优化异常处理逻辑。
- 🔧 **工具升级**：升级 xxgkami 命令行工具，新增数据库智能增量更新功能，支持无损升级。
- 📦 **部署优化**：优化一键安装脚本，提升部署稳定性和兼容性。
- 🛠️ **体验改进**：修复部分已知的小问题，提升系统整体稳定性。

#### v1.0.1 (2026-01-30)
- 🔒 **安全性升级**：完善管理员账号密码加密逻辑，数据库存储由明文全面升级为 BCrypt 加密。
- ℹ️ **新增系统信息页**：管理员后台新增"系统信息"页面，支持查看版本号、开源协议、开发团队等信息。
- 🔄 **在线检查更新**：系统信息页支持一键检查新版本，并提供国内/海外一键更新脚本。
- 🎨 **UI 优化**：优化顶部导航栏布局，提升视觉体验。
- 🐛 **问题修复**：修复已知的小问题，提升系统稳定性。

### 🎯 **第一阶段 (当前)**
- [x] 核心功能重构
- [x] 现代化UI设计
- [x] 基础API接口
- [ ] 用户系统完善
- [ ] 支付系统集成

### 🚀 **第二阶段 (2025 Q1)**
- [ ] 移动端APP
- [ ] 微信小程序
- [ ] 高级数据分析
- [ ] 多语言支持
- [ ] 插件系统

### 🌟 **第三阶段 (2025 Q2)**
- [ ] AI智能推荐
- [ ] 区块链集成
- [ ] 云原生部署
- [ ] 企业级功能
- [ ] 开放平台

---

## 🤝 参与贡献

我们欢迎所有形式的贡献！

### 🎯 **如何参与**
1. 🍴 Fork 本仓库
2. 🌿 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 💾 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 📤 推送分支 (`git push origin feature/AmazingFeature`)
5. 🔄 创建 Pull Request

### 🏆 **贡献者排行榜**
感谢所有为项目做出贡献的开发者！

<a href="https://github.com/xiaoxiaoguai-yyds/xxgkami-pro/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=xiaoxiaoguai-yyds/xxgkami-pro" />
</a>

---

## 📞 联系我们

### 💬 **社区交流**
- 🐛 [问题反馈](https://github.com/xiaoxiaoguai-yyds/xxgkami-pro/issues)
- 💡 [功能建议](https://github.com/xiaoxiaoguai-yyds/xxgkami-pro/discussions)
- � **官方交流群**：`1050160397` (售后/技术支持)
- �📧 **联系邮箱**：`xxgyyds@vip.qq.com`

### 🌐 **开源地址**
- 🐙 **GitHub**: [https://github.com/xiaoxiaoguai-yyds/xxgkami-pro](https://github.com/xiaoxiaoguai-yyds/xxgkami-pro)
- 🔴 **Gitee**: [https://gitee.com/xiaoxiaoguai-yyds/xxgkami-pro](https://gitee.com/xiaoxiaoguai-yyds/xxgkami-pro)
- 🚀 **GitCode**: [https://atomgit.com/xiaoxiaoguai-yyds/xxgkami-pro](https://atomgit.com/xiaoxiaoguai-yyds/xxgkami-pro)

### 🌐 **官方链接**
- 🏠 [官方网站](https://xiaoxiaoguai-yyds.github.io/xxgkami.github.io/index.html)
- 📖 [在线文档](https://xiaoxiaoguai-yyds.github.io/xxgkami.github.io/)
- 🐱 [GitHub 仓库](https://github.com/xiaoxiaoguai-yyds/xxgkami-pro)
- 🔴 [Gitee 仓库](https://gitee.com/xiaoxiaoguai-yyds/xxgkami-pro)
- 🚀 [GitCode 仓库](https://atomgit.com/xiaoxiaoguai-yyds/xxgkami-pro)

---

## 📄 开源协议

本项目基于 [MIT License](LICENSE) 开源协议发布。

---

## ⭐ Star 历史

[![Star History Chart](https://api.star-history.com/svg?repos=xiaoxiaoguai-yyds/xxgkami-pro&type=Date)](https://star-history.com/#xiaoxiaoguai-yyds/xxgkami-pro&Date)

---

<div align="center">

### 🎉 感谢您的关注！

**如果这个项目对您有帮助，请不要忘记给我们一个 ⭐ Star！**

**让我们一起构建更好的卡密验证系统！** 🚀

---

*© 2025 小小怪卡密验证系统. All rights reserved.*

</div>
