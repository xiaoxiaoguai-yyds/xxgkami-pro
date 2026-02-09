<template>
  <div class="system-info-container">
    <div class="page-header">
      <h2>系统信息</h2>
      <p class="subtitle">查看系统版本、作者信息及开源协议</p>
    </div>

    <div class="info-content">
      <el-card class="info-card">
        <template #header>
          <div class="card-header">
            <span>基本信息</span>
          </div>
        </template>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="系统名称">XXG-KAMI-PRO 卡密验证系统</el-descriptions-item>
          <el-descriptions-item label="当前版本">
            <div class="version-row">
              <span>{{ currentVersion }}</span>
              <el-button type="primary" link size="small" @click="checkUpdate" :loading="checking">检查更新</el-button>
            </div>
          </el-descriptions-item>
          <el-descriptions-item label="发布时间">2026-01-17</el-descriptions-item>
          <el-descriptions-item label="开发语言">Vue 3 + Spring Boot 3</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card class="info-card">
        <template #header>
          <div class="card-header">
            <span>开发团队</span>
          </div>
        </template>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="作者">小小怪</el-descriptions-item>
const currentVersion = 'v1.0.0'          <el-descriptions-item label="联系邮箱">xxgyyds@vip.qq.com</el-descriptions-item>
          <el-descriptions-item label="QQ群组">
            <a href="https://qm.qq.com/cgi-bin/qm/qr?k=5q7h3tdOC-fXyszk3kGCJxIImDW_hVBP&jump_from=webapi&authKey=n7o2H5vcTCkRNpnTbOSU9BxI4jP3WKv9Qytmfk2I2Y+zP28lb614xqvd3+qETV8x" target="_blank" class="link">1050160397 (点击加入)</a>
          </el-descriptions-item>
          <el-descriptions-item label="Gitee">
            <a href="https://gitee.com/xiaoxiaoguai-yyds/xxgkami-pro" target="_blank" class="link">https://gitee.com/xiaoxiaoguai-yyds/xxgkami-pro</a>
          </el-descriptions-item>
          <el-descriptions-item label="GitHub">
            <a href="https://github.com/xiaoxiaoguai-yyds/xxgkami-pro" target="_blank" class="link">https://github.com/xiaoxiaoguai-yyds/xxgkami-pro</a>
          </el-descriptions-item>
          <el-descriptions-item label="AtomGit">
            <a href="https://atomgit.com/xiaoxiaoguai-yyds/xxgkami-pro" target="_blank" class="link">https://atomgit.com/xiaoxiaoguai-yyds/xxgkami-pro</a>
          </el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card class="info-card">
        <template #header>
          <div class="card-header">
            <span>开源协议</span>
          </div>
        </template>
        <div class="license-content">
          <p>本系统遵循 Apache-2.0 开源协议。</p>
          <p>您可以免费使用、修改和分发本软件，但必须保留原作者的版权声明。</p>
        </div>
      </el-card>
    </div>

    <!-- 更新时间轴 -->
    <div class="timeline-section">
      <el-card>
        <template #header>
          <div class="card-header">
            <span>版本历程</span>
          </div>
        </template>
        <el-timeline>
          <el-timeline-item timestamp="2026-02-09" placement="top" type="primary" size="large">
            <el-card>
              <h4>v1.0.2 版本更新</h4>
              <p>1. 修复用户注册时因邮件配置缺失导致的 500 错误，优化异常处理逻辑</p>
              <p>2. 升级 xxgkami 命令行工具，新增数据库智能增量更新功能</p>
              <p>3. 优化系统安装脚本，提升部署体验</p>
              <p>4. 修复部分已知的小问题</p>
            </el-card>
          </el-timeline-item>
          <el-timeline-item timestamp="2026-01-30" placement="top" size="large">
            <el-card>
              <h4>v1.0.1 版本更新</h4>
              <p>1. 完善管理员账号密码加密逻辑，数据库存储由明文全面升级为 BCrypt 加密</p>
              <p>2. 新增系统信息页面，支持查看版本信息、开源协议及开发团队</p>
              <p>3. 新增在线检查更新功能，提供国内/海外一键更新脚本</p>
              <p>4. 优化前端导航栏布局，提升用户体验</p>
            </el-card>
          </el-timeline-item>
          <el-timeline-item timestamp="2026-01-17" placement="top">
            <el-card>
              <h4>v1.0.0 正式发布</h4>
              <p>小小怪卡密验证系统 1.0 正式发布</p>
            </el-card>
          </el-timeline-item>
        </el-timeline>
      </el-card>
    </div>

    <!-- 更新提示弹窗 -->
    <el-dialog v-model="showUpdateDialog" title="发现新版本" width="500px">
      <div v-if="updateInfo">
        <div class="new-version">最新版本: v{{ updateInfo.version }}</div>
        <div class="update-date">发布时间: {{ updateInfo.buildDate }}</div>
        <div class="changelog-title">更新内容:</div>
        <ul class="changelog-list">
          <li v-for="(item, index) in updateInfo.changelog" :key="index">{{ item }}</li>
        </ul>
        
        <div v-if="updateInfo.updateScripts" class="update-scripts">
          <div class="script-block">
            <div class="script-header">
              <span>国内更新脚本</span>
              <el-button type="primary" link size="small" @click="copyScript(updateInfo.updateScripts.cn)">复制</el-button>
            </div>
            <div class="script-content">{{ updateInfo.updateScripts.cn }}</div>
          </div>
          <div class="script-block">
            <div class="script-header">
              <span>海外更新脚本</span>
              <el-button type="primary" link size="small" @click="copyScript(updateInfo.updateScripts.global)">复制</el-button>
            </div>
            <div class="script-content">{{ updateInfo.updateScripts.global }}</div>
          </div>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showUpdateDialog = false">关闭</el-button>
          <el-button type="primary" @click="goToRepo">前往仓库</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

const currentVersion = 'v1.0.2'
const checking = ref(false)
const showUpdateDialog = ref(false)
const updateInfo = ref(null)

const copyScript = async (text) => {
  try {
    await navigator.clipboard.writeText(text)
    ElMessage.success('脚本已复制到剪贴板')
  } catch (err) {
    ElMessage.error('复制失败，请手动复制')
  }
}

const checkUpdate = async () => {
  checking.value = true
  try {
    // 调用后端代理接口检查更新
    const res = await fetch('http://localhost:8080/api/monitor/check-update')
    if (!res.ok) throw new Error('检查更新失败')
    
    const data = await res.json()
    const remoteVersion = data.version
    
    // 简单的版本比较逻辑：如果不相等则提示更新
    // 实际项目中建议使用 semver 库进行版本号比较
    if (remoteVersion !== currentVersion.replace('v', '')) {
      updateInfo.value = data
      showUpdateDialog.value = true
    } else {
      ElMessage.success('当前已是最新版本')
    }
  } catch (error) {
    console.error(error)
    ElMessage.error('检查更新失败，请稍后重试')
  } finally {
    checking.value = false
  }
}

const goToRepo = () => {
  if (updateInfo.value && updateInfo.value.repoUrl) {
    window.open(updateInfo.value.repoUrl, '_blank')
    showUpdateDialog.value = false
  }
}
</script>

<style scoped>
.system-info-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h2 {
  font-size: 24px;
  color: #303133;
  margin-bottom: 8px;
}

.subtitle {
  color: #909399;
  font-size: 14px;
}

.info-content {
  display: grid;
  gap: 20px;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  margin-bottom: 24px;
}

.timeline-section {
  margin-top: 24px;
}

.timeline-section h4 {
  margin: 0 0 10px;
  color: #303133;
}

.timeline-section p {
  margin: 0 0 5px;
  color: #606266;
  font-size: 14px;
  line-height: 1.5;
}

.info-card {
  height: 100%;
}

.card-header {
  font-weight: bold;
}

.link {
  color: #409EFF;
  text-decoration: none;
}

.link:hover {
  text-decoration: underline;
}

.license-content {
  color: #606266;
  line-height: 1.6;
}

.version-row {
  display: flex;
  align-items: center;
  gap: 10px;
}

.new-version {
  font-size: 18px;
  font-weight: bold;
  color: #409EFF;
  margin-bottom: 8px;
}

.update-date {
  color: #909399;
  font-size: 14px;
  margin-bottom: 16px;
}

.changelog-title {
  font-weight: bold;
  margin-bottom: 8px;
}

.changelog-list {
  padding-left: 20px;
  margin-bottom: 16px;
  color: #606266;
}

.changelog-list li {
  margin-bottom: 4px;
}

.update-scripts {
  margin-top: 20px;
  border-top: 1px solid #eee;
  padding-top: 15px;
}

.script-block {
  margin-bottom: 15px;
  background-color: #f5f7fa;
  border-radius: 4px;
  padding: 10px;
}

.script-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 5px;
  font-size: 13px;
  color: #606266;
  font-weight: bold;
}

.script-content {
  font-family: monospace;
  background-color: #303133;
  color: #fff;
  padding: 8px;
  border-radius: 4px;
  font-size: 12px;
  word-break: break-all;
  white-space: pre-wrap;
}
</style>
