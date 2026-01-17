<template>
  <div class="maintenance-admin">
    <div class="page-header">
      <h2 class="page-title">系统维护通知</h2>
      <p class="page-subtitle">设置系统维护状态，开启后用户端将显示维护提示</p>
    </div>

    <div class="maintenance-card">
      <div class="status-section">
        <div class="status-info">
          <h3>维护模式开关</h3>
          <p class="status-desc">开启后，用户端访问将被拦截并显示维护信息</p>
        </div>
        <label class="switch">
          <input type="checkbox" v-model="settings.enabled" @change="handleSwitchChange">
          <span class="slider round"></span>
        </label>
      </div>

      <div class="form-section">
        <div class="form-group">
          <label>维护内容提示</label>
          <textarea 
            v-model="settings.content" 
            rows="4" 
            placeholder="请输入维护通知内容，例如：系统正在进行升级维护，请稍后访问..."
          ></textarea>
        </div>

        <div class="form-group">
          <label>维护开始时间</label>
          <input 
            type="text" 
            v-model="settings.startTime" 
            placeholder="例如：2023-10-01 00:00"
          >
        </div>

        <div class="form-group">
          <label>预计维护时间/时长</label>
          <input 
            type="text" 
            v-model="settings.maintenanceTime" 
            placeholder="例如：2小时 或 2023-10-01 02:00"
          >
        </div>

        <div class="form-group">
          <label>邮件通知标题</label>
          <input type="text" v-model="settings.emailSubject" placeholder="系统维护通知" />
        </div>

        <div class="form-group">
          <label>邮件通知模板</label>
          <div class="template-help">
            可用变量: {username} (用户名), {time} (维护开始时间), {duration} (预计时长), {systemName} (系统名称)
          </div>
          <textarea v-model="settings.emailTemplate" rows="6" placeholder="系统将于 {time} 进行维护，预计持续 {duration}，请提前做好准备。"></textarea>
        </div>

        <div class="form-actions">
          <button class="save-btn" @click="saveSettings" :disabled="loading">
            <span v-if="loading">保存中...</span>
            <span v-else>保存设置</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { maintenanceApi } from '../services/api.js'

const loading = ref(false)
const settings = ref({
  id: 1,
  enabled: false,
  content: '系统正在维护中，请稍后访问。',
  maintenanceTime: '',
  startTime: '',
  emailSubject: '',
  emailTemplate: ''
})

const loadSettings = async () => {
  try {
    const res = await maintenanceApi.getStatus()
    if (res.success && res.data) {
      // 确保后端返回的数据类型正确
      settings.value = {
        id: res.data.id,
        enabled: Boolean(res.data.enabled), // 强制转换为布尔值
        content: res.data.content || '',
        maintenanceTime: res.data.maintenanceTime || '',
        startTime: res.data.startTime || '',
        emailSubject: res.data.emailSubject || '',
        emailTemplate: res.data.emailTemplate || ''
      }
    }
  } catch (error) {
    console.error('加载维护设置失败:', error)
  }
}

const handleSwitchChange = () => {
  // 可以在这里添加开关切换的即时保存逻辑，或者等待用户点击保存
  // 这里选择点击保存按钮才提交
}

const saveSettings = async () => {
  loading.value = true
  try {
    const res = await maintenanceApi.updateSettings(settings.value)
    if (res.success) {
      alert('设置保存成功')
      // 重新加载以确保同步
      loadSettings()
    } else {
      alert('保存失败: ' + res.message)
    }
  } catch (error) {
    console.error('保存失败:', error)
    alert('保存失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadSettings()
})
</script>

<style scoped>
.maintenance-admin {
  width: 100%;
}

.page-header {
  margin-bottom: 2rem;
}

.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #111827;
  margin-bottom: 0.5rem;
}

.page-subtitle {
  color: #6b7280;
  font-size: 0.9rem;
}

.maintenance-card {
  background: white;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  padding: 2rem;
  max-width: 800px;
}

.status-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 2rem;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 2rem;
}

.status-info h3 {
  font-size: 1.1rem;
  color: #111827;
  margin-bottom: 0.5rem;
}

.status-desc {
  color: #6b7280;
  font-size: 0.9rem;
}

/* Switch Toggle */
.switch {
  position: relative;
  display: inline-block;
  width: 60px;
  height: 34px;
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
  transition: .4s;
}

.slider:before {
  position: absolute;
  content: "";
  height: 26px;
  width: 26px;
  left: 4px;
  bottom: 4px;
  background-color: white;
  transition: .4s;
}

input:checked + .slider {
  background-color: #4f46e5;
}

input:focus + .slider {
  box-shadow: 0 0 1px #4f46e5;
}

input:checked + .slider:before {
  transform: translateX(26px);
}

.slider.round {
  border-radius: 34px;
}

.slider.round:before {
  border-radius: 50%;
}

/* Form Styles */
.form-section {
  transition: opacity 0.3s;
}

.form-section.disabled {
  opacity: 0.6;
  pointer-events: none;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.5rem;
}

.template-help {
  font-size: 0.85rem;
  color: #6b7280;
  margin-bottom: 0.5rem;
  background: #f9fafb;
  padding: 0.5rem;
  border-radius: 4px;
}

.form-group textarea,
.form-group input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 0.95rem;
  transition: border-color 0.2s;
  color: #111827; /* Ensure text is visible */
  background-color: #fff;
}

.form-group textarea:focus,
.form-group input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.form-actions {
  margin-top: 2rem;
  display: flex;
  justify-content: flex-end;
}

.save-btn {
  background: #4f46e5;
  color: white;
  border: none;
  padding: 0.75rem 2rem;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
}

.save-btn:hover {
  background: #4338ca;
}

.save-btn:disabled {
  background: #a5b4fc;
  cursor: not-allowed;
}
</style>
