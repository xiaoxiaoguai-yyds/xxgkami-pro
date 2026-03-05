<template>
  <div class="user-settings-page">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>系统设置</span>
        </div>
      </template>
      <div class="settings-content">
        <el-row :gutter="20">
          <el-col :span="24">
            <div class="setting-item">
              <div class="setting-info">
                <h3>绑定手机App</h3>
                <p>使用手机App扫描二维码进行绑定，随时随地管理您的账户。</p>
              </div>
              <el-button type="primary" @click="showBindQRCode">显示绑定二维码</el-button>
            </div>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <el-dialog v-model="qrDialogVisible" title="绑定手机App" width="360px" center destroy-on-close>
      <div class="qr-container">
        <div class="qr-code-wrapper">
          <img v-if="qrCodeUrl" :src="qrCodeUrl" alt="Bind QR Code" class="qr-image" />
          <div v-else class="qr-loading">
            <el-icon class="is-loading"><Loading /></el-icon>
          </div>
        </div>
        <p class="qr-tip">请使用手机App扫描上方二维码</p>
        <p class="qr-sub-tip">扫描后将自动配置服务器连接信息</p>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import CryptoJS from 'crypto-js'
import QRCode from 'qrcode'
import { ElMessage } from 'element-plus'
import { Loading } from '@element-plus/icons-vue'
import { authApi } from '../services/api'

const qrDialogVisible = ref(false)
const qrCodeUrl = ref('')

const showBindQRCode = async () => {
  try {
    qrDialogVisible.value = true
    qrCodeUrl.value = '' // Reset
    
    // 1. 获取绑定Token和服务器配置
    const res = await authApi.getBindToken()
    if (!res.success) {
      throw new Error(res.message || '获取绑定信息失败')
    }
    
    const { token, siteUrl } = res.data
    
    let hostname = window.location.hostname
    let port = window.location.port || (window.location.protocol === 'https:' ? '443' : '80')
    let protocol = window.location.protocol.replace(':', '')
    let baseUrl = window.location.origin

    // 如果后端配置了siteUrl，优先使用
    if (siteUrl && siteUrl.startsWith('http')) {
      try {
        const url = new URL(siteUrl)
        hostname = url.hostname
        port = url.port || (url.protocol === 'https:' ? '443' : '80')
        protocol = url.protocol.replace(':', '')
        baseUrl = siteUrl
      } catch (e) {
        console.warn('Invalid siteUrl format:', siteUrl)
      }
    }
    
    // 构造原始JSON数据
    // 包含 token 用于 App 扫码验证
    const data = {
      ip: hostname,
      port: port,
      protocol: protocol,
      baseUrl: baseUrl,
      token: token
    }
    
    const jsonString = JSON.stringify(data)
    console.log('Original JSON:', jsonString)
    
    // 2. AES加密
    // Key: xxgyyds-github-1
    // IV: xxgyyds-github-1
    // Mode: CBC
    // Padding: Pkcs7
    const key = CryptoJS.enc.Utf8.parse('xxgyyds-github-1')
    const iv = CryptoJS.enc.Utf8.parse('xxgyyds-github-1')
    
    const encrypted = CryptoJS.AES.encrypt(jsonString, key, {
      iv: iv,
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7
    })
    
    // 密文 (Base64格式)
    const encryptedString = encrypted.toString()
    console.log('Encrypted String:', encryptedString)
    
    // 3. 生成二维码
    qrCodeUrl.value = await QRCode.toDataURL(encryptedString, {
      errorCorrectionLevel: 'M',
      margin: 2,
      width: 240,
      color: {
        dark: '#000000',
        light: '#ffffff'
      }
    })
    
  } catch (error) {
    console.error('生成二维码失败:', error)
    ElMessage.error(error.message || '生成二维码失败，请重试')
    qrDialogVisible.value = false
  }
}
</script>

<style scoped>
.user-settings-page {
  padding: 20px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}
.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 0;
  border-bottom: 1px solid #ebeef5;
}
.setting-item:last-child {
  border-bottom: none;
}
.setting-info h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}
.setting-info p {
  margin: 0;
  font-size: 14px;
  color: #909399;
}
.qr-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 10px 0;
}
.qr-code-wrapper {
  width: 240px;
  height: 240px;
  display: flex;
  justify-content: center;
  align-items: center;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  margin-bottom: 16px;
  background-color: #f5f7fa;
}
.qr-image {
  width: 100%;
  height: 100%;
  border-radius: 8px;
}
.qr-tip {
  margin: 0;
  color: #303133;
  font-size: 16px;
  font-weight: 500;
}
.qr-sub-tip {
  margin: 8px 0 0 0;
  color: #909399;
  font-size: 13px;
}
.qr-loading {
  font-size: 24px;
  color: #909399;
}
</style>
