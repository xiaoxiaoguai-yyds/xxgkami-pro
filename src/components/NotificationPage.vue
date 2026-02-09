<template>
  <div class="notification-page">
    <div class="notification-header">
      <h2>通知管理</h2>
      <p>配置系统通知设置和邮箱服务</p>
    </div>

    <div class="notification-sections">
      <!-- 邮箱设置 -->
      <div class="notification-section">
        <div class="section-title">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
          <h3>邮箱设置</h3>
        </div>
        <div class="settings-grid">
          <div class="setting-item">
            <label>SMTP服务器</label>
            <input type="text" v-model="emailSettings.smtpServer" placeholder="请输入SMTP服务器地址" />
          </div>
          <div class="setting-item">
            <label>SMTP端口</label>
            <input type="number" v-model="emailSettings.smtpPort" placeholder="请输入端口号" />
          </div>
          <div class="setting-item">
            <label>发送邮箱</label>
            <input type="email" v-model="emailSettings.senderEmail" placeholder="请输入发送邮箱" />
          </div>
          <div class="setting-item">
            <label>邮箱密码</label>
            <input type="password" v-model="emailSettings.senderPassword" placeholder="请输入邮箱密码或授权码" />
          </div>
          <div class="setting-item">
            <label class="switch-label">
              <span>启用SSL加密</span>
              <label class="switch">
                <input type="checkbox" v-model="emailSettings.enableSSL" />
                <span class="slider"></span>
              </label>
            </label>
          </div>
          <div class="setting-item">
            <label>发送者名称</label>
            <input type="text" v-model="emailSettings.senderName" placeholder="请输入发送者显示名称" />
          </div>
        </div>
      </div>

      <!-- 通知类型设置 -->
      <div class="notification-section">
        <div class="section-title">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
          <h3>通知类型</h3>
        </div>
        <div class="settings-grid">
          <div class="setting-item">
            <label class="switch-label">
              <span>用户注册通知</span>
              <label class="switch">
                <input type="checkbox" v-model="notificationTypes.userRegistration" />
                <span class="slider"></span>
              </label>
            </label>
          </div>
          <div class="setting-item">
            <label class="switch-label">
              <span>订单创建通知</span>
              <label class="switch">
                <input type="checkbox" v-model="notificationTypes.orderCreated" />
                <span class="slider"></span>
              </label>
            </label>
          </div>
          <div class="setting-item">
            <label class="switch-label">
              <span>卡密使用通知</span>
              <label class="switch">
                <input type="checkbox" v-model="notificationTypes.keyUsed" />
                <span class="slider"></span>
              </label>
            </label>
          </div>
        </div>
      </div>

      <!-- 通知模板设置 -->
      <div class="notification-section">
        <div class="section-title">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
          <h3>邮件模板</h3>
        </div>
        <div class="template-grid">
          <div class="template-item">
            <label>用户注册模板</label>
            <textarea v-model="emailTemplates.userRegistration" rows="4" placeholder="请输入用户注册邮件模板"></textarea>
          </div>
          <div class="template-item">
            <label>订单通知模板</label>
            <textarea v-model="emailTemplates.orderNotification" rows="4" placeholder="请输入订单通知邮件模板"></textarea>
          </div>
          <div class="template-item">
            <label>系统维护模板</label>
            <textarea v-model="emailTemplates.systemMaintenance" rows="4" placeholder="请输入系统维护邮件模板"></textarea>
          </div>
        </div>
      </div>

      <!-- 测试邮件 -->
      <div class="notification-section">
        <div class="section-title">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
          <h3>测试邮件</h3>
        </div>
        <div class="test-email-section">
          <div class="setting-item">
            <label>测试邮箱</label>
            <input type="email" v-model="testEmail" placeholder="请输入测试邮箱地址" />
          </div>
          <button class="btn-primary" @click="sendTestEmail" :disabled="!testEmail">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
            发送测试邮件
          </button>
        </div>
      </div>
    </div>

    <!-- 操作按钮 -->
    <div class="notification-footer">
      <button class="btn-secondary" @click="resetSettings">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"></path></svg>
        重置设置
      </button>
      <button class="btn-primary" @click="saveSettings">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
        保存设置
      </button>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { settingsApi } from '../services/api'

// 邮箱设置
const emailSettings = reactive({
  smtpServer: 'smtp.qq.com',
  smtpPort: 587,
  senderEmail: 'admin@example.com',
  senderPassword: '',
  enableSSL: true,
  senderName: 'XXG卡密系统'
})

// 通知类型设置
const notificationTypes = reactive({
  userRegistration: true,
  orderCreated: true,
  keyUsed: false,
  systemMaintenance: true,
  securityAlert: true
})

// 邮件模板
const emailTemplates = reactive({
  userRegistration: '欢迎注册XXG卡密系统！您的账户已成功创建。',
  orderNotification: '您的订单已创建成功，订单号：{orderNumber}，请及时查看。',
  systemMaintenance: '系统将于{time}进行维护，预计维护时间{duration}，请提前做好准备。'
})

// 测试邮箱
const testEmail = ref('')
const loading = ref(false)

// 显示提示消息
const showToast = (message, type = 'info') => {
  // 这里可以使用更高级的Toast组件，目前使用简单的alert
  // 实际项目中建议使用Element Plus或其他UI库的Message组件
  alert(`${type === 'success' ? '成功' : type === 'error' ? '错误' : '提示'}: ${message}`)
}

// 加载设置
const loadSettings = async () => {
  try {
    loading.value = true
    const res = await settingsApi.getAllSettings()
    
    if (res.success && res.data) {
      const settings = res.data

      // 映射邮箱设置
      if (settings.smtp_server) emailSettings.smtpServer = settings.smtp_server
      if (settings.smtp_port) emailSettings.smtpPort = parseInt(settings.smtp_port)
      if (settings.smtp_email) emailSettings.senderEmail = settings.smtp_email
      if (settings.smtp_password) emailSettings.senderPassword = settings.smtp_password
      if (settings.smtp_ssl) emailSettings.enableSSL = settings.smtp_ssl === 'true'
      if (settings.sender_name) emailSettings.senderName = settings.sender_name
  
      // 映射通知类型
      if (settings.notify_user_reg) notificationTypes.userRegistration = settings.notify_user_reg === 'true'
      if (settings.notify_order_create) notificationTypes.orderCreated = settings.notify_order_create === 'true'
      if (settings.notify_key_used) notificationTypes.keyUsed = settings.notify_key_used === 'true'
      if (settings.notify_sys_maint) notificationTypes.systemMaintenance = settings.notify_sys_maint === 'true'
      if (settings.notify_sec_alert) notificationTypes.securityAlert = settings.notify_sec_alert === 'true'
  
      // 映射邮件模板
      if (settings.tpl_user_reg) emailTemplates.userRegistration = settings.tpl_user_reg
      if (settings.tpl_order_notify) emailTemplates.orderNotification = settings.tpl_order_notify
      if (settings.tpl_sys_maint) emailTemplates.systemMaintenance = settings.tpl_sys_maint
    }
  } catch (error) {
    console.error('加载设置失败:', error)
    showToast('加载设置失败: ' + error.message, 'error')
  } finally {
    loading.value = false
  }
}

// 保存设置
const saveSettings = async () => {
  try {
    loading.value = true
    const settingsToSave = {
      // 邮箱设置
      smtp_server: emailSettings.smtpServer,
      smtp_port: emailSettings.smtpPort.toString(),
      smtp_email: emailSettings.senderEmail,
      smtp_password: emailSettings.senderPassword,
      smtp_ssl: emailSettings.enableSSL.toString(),
      sender_name: emailSettings.senderName,
      
      // 通知类型
      notify_user_reg: notificationTypes.userRegistration.toString(),
      notify_order_create: notificationTypes.orderCreated.toString(),
      notify_key_used: notificationTypes.keyUsed.toString(),
      notify_sys_maint: notificationTypes.systemMaintenance.toString(),
      notify_sec_alert: notificationTypes.securityAlert.toString(),
      
      // 邮件模板
      tpl_user_reg: emailTemplates.userRegistration,
      tpl_order_notify: emailTemplates.orderNotification,
      tpl_sys_maint: emailTemplates.systemMaintenance
    }

    const res = await settingsApi.saveSettings(settingsToSave)
    
    if (res.success) {
        showToast('通知设置已保存', 'success')
        // 延迟1秒后刷新页面
        setTimeout(() => {
          window.location.reload()
        }, 1000)
    } else {
        showToast(res.message || '保存失败', 'error')
    }
  } catch (error) {
    console.error('保存设置失败:', error)
    showToast('保存设置失败: ' + error.message, 'error')
  } finally {
    loading.value = false
  }
}

// 重置设置
const resetSettings = () => {
  if (confirm('确定要重置所有通知设置吗？这将恢复到默认配置。')) {
    // 重置邮箱设置
    Object.assign(emailSettings, {
      smtpServer: 'smtp.qq.com',
      smtpPort: 587,
      senderEmail: 'admin@example.com',
      senderPassword: '',
      enableSSL: true,
      senderName: 'XXG卡密系统'
    })
    
    // 重置通知类型
    Object.assign(notificationTypes, {
      userRegistration: true,
      orderCreated: true,
      keyUsed: false,
      systemMaintenance: true,
      securityAlert: true
    })
    
    // 重置邮件模板
    Object.assign(emailTemplates, {
      userRegistration: '欢迎注册XXG卡密系统！您的账户已成功创建。',
      orderNotification: '您的订单已创建成功，订单号：{orderNumber}，请及时查看。',
      systemMaintenance: '系统将于{time}进行维护，预计维护时间{duration}，请提前做好准备。'
    })
    
    testEmail.value = ''
    showToast('通知设置已重置，请记得保存', 'info')
  }
}

// 发送测试邮件
const sendTestEmail = async () => {
  if (!testEmail.value) {
    showToast('请输入测试邮箱地址', 'warning')
    return
  }
  
  try {
    loading.value = true
    
    // 提取当前设置用于测试
    const currentSettings = {
      smtp_server: emailSettings.smtpServer,
      smtp_port: emailSettings.smtpPort.toString(),
      smtp_email: emailSettings.senderEmail,
      smtp_password: emailSettings.senderPassword,
      smtp_ssl: emailSettings.enableSSL.toString(),
      sender_name: emailSettings.senderName
    }

    await settingsApi.sendTestEmail(testEmail.value, currentSettings)
    showToast(`测试邮件已发送到 ${testEmail.value}`, 'success')
  } catch (error) {
    console.error('发送测试邮件失败:', error)
    showToast('发送测试邮件失败: ' + error.message, 'error')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadSettings()
})
</script>

<style scoped>
.notification-page {
  padding: 0;
  width: 100%;
  box-sizing: border-box;
  overflow-x: auto;
}

.notification-header {
  text-align: center;
  margin-bottom: 2rem;
  color: #333;
}

.notification-header h2 {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
  font-weight: bold;
  color: #333;
}

.notification-header p {
  font-size: 1rem;
  color: #666;
}

.notification-sections {
  max-width: 1200px;
  margin: 0 auto;
}

.notification-section {
  background: white;
  border-radius: 6px;
  padding: 2rem;
  margin-bottom: 2rem;
  border: 1px solid #eee;
}

.section-title {
  display: flex;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid #f8f9fa;
}

.section-title svg {
  color: #667eea;
  margin-right: 0.75rem;
}

.section-title h3 {
  font-size: 1.5rem;
  color: #2c3e50;
  margin: 0;
  font-weight: 600;
}

.section-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid #f0f0f0;
}

.small-btn {
  padding: 0.5rem 1rem;
  font-size: 0.9rem;
}

.settings-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.template-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 1.5rem;
}

.setting-item, .template-item {
  display: flex;
  flex-direction: column;
}

.setting-item label, .template-item label {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
}

.setting-item input, .setting-item select, .template-item textarea {
  padding: 0.75rem;
  border: 1px solid #dcdfe6;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.setting-item input:focus, .setting-item select:focus, .template-item textarea:focus {
  outline: none;
  border-color: #667eea;
}

.switch-label {
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
}

.switch {
  position: relative;
  display: inline-block;
  width: 44px;
  height: 22px;
}

.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: 0.3s;
  border-radius: 22px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 16px;
  width: 16px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: 0.3s;
  border-radius: 50%;
}

input:checked + .slider {
  background-color: #667eea;
}

input:checked + .slider:before {
  transform: translateX(22px);
}

.test-email-section {
  display: flex;
  gap: 1rem;
  align-items: end;
}

.test-email-section .setting-item {
  flex: 1;
}

.btn-primary, .btn-secondary {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-primary {
  background: #667eea;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #5a6fd6;
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background: #f0f2f5;
  color: #606266;
}

.btn-secondary:hover {
  background: #e6e8eb;
}

.notification-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 2px solid #f8f9fa;
}

@media (max-width: 768px) {
  .settings-grid, .template-grid {
    grid-template-columns: 1fr;
  }
  
  .test-email-section {
    flex-direction: column;
    align-items: stretch;
  }
  
  .notification-footer {
    flex-direction: column;
  }
}
</style>
