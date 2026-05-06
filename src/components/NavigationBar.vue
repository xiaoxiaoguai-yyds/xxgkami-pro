<template>
  <aside class="sidebar" :class="{ 'sidebar-collapsed': isCollapsed }">
    <div class="sidebar-header">
      <div class="logo">
        <img src="../assets/icon.png" alt="XXG-KAMI-PRO" class="logo-img">
        <span v-if="!isCollapsed" class="logo-text">XXG-KAMI-PRO</span>
      </div>
      <button class="collapse-btn" @click="toggleCollapse">
        <svg v-if="!isCollapsed" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"></polyline></svg>
        <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"></polyline></svg>
      </button>
    </div>

    <nav class="sidebar-nav">
      <a href="javascript:void(0)" 
         :class="{ active: activeTab === 'overview' }" 
         @click="handleTabClick('overview')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
        <span v-if="!isCollapsed">概览</span>
      </a>
      <a href="javascript:void(0)" 
         :class="{ active: activeTab === 'keys' }" 
         @click="handleTabClick('keys')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"></path></svg>
        <span v-if="!isCollapsed">卡密管理</span>
      </a>
      <a href="javascript:void(0)" 
         :class="{ active: activeTab === 'pricing' }" 
         @click="handleTabClick('pricing')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
        <span v-if="!isCollapsed">定价管理</span>
      </a>
      <a href="javascript:void(0)" 
         :class="{ active: activeTab === 'orders' }" 
         @click="handleTabClick('orders')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
        <span v-if="!isCollapsed">订单管理</span>
      </a>
      <a href="javascript:void(0)" 
         :class="{ active: activeTab === 'api' }" 
         @click="handleTabClick('api')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg>
        <span v-if="!isCollapsed">API管理</span>
      </a>
      <a href="javascript:void(0)" 
         :class="{ active: activeTab === 'users' }" 
         @click="handleTabClick('users')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        <span v-if="!isCollapsed">用户管理</span>
      </a>
      <a href="javascript:void(0)" 
         :class="{ active: activeTab === 'notification' }" 
         @click="handleTabClick('notification')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
        <span v-if="!isCollapsed">通知管理</span>
      </a>
      <div class="nav-item-group">
        <a href="javascript:void(0)" 
           :class="{ active: activeTab === 'settings' }" 
           @click="toggleSettingsSub">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06A1.65 1.65 0 0 0 5 15.4a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06A1.65 1.65 0 0 0 9 4.6a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
          <span v-if="!isCollapsed">系统设置</span>
          <el-icon v-if="!isCollapsed" class="sub-arrow" :class="{ 'is-open': showSettingsSub }"><ArrowDown /></el-icon>
        </a>
        <div class="sub-menu" v-if="showSettingsSub && !isCollapsed">
          <div class="sub-menu-item" @click.stop="handleSubMenuClick('settings', 'basic')">基本设置</div>
          <div class="sub-menu-item" @click.stop="handleSubMenuClick('settings', 'database')">数据库设置</div>
          <div class="sub-menu-item" @click.stop="handleSubMenuClick('settings', 'payment')">支付设置</div>
          <div class="sub-menu-item" @click.stop="handleSubMenuClick('settings', 'login')">登录验证</div>
          <div class="sub-menu-item" @click.stop="handleSubMenuClick('settings', 'maintenance')">系统维护</div>
        </div>
      </div>
      <a href="javascript:void(0)" 
         :class="{ active: activeTab === 'maintenance' }" 
         @click="handleTabClick('maintenance')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
        <span v-if="!isCollapsed">系统维护</span>
      </a>
      <a href="javascript:void(0)" 
         :class="{ active: activeTab === 'system_info' }" 
         @click="handleTabClick('system_info')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
        <span v-if="!isCollapsed">系统信息</span>
      </a>
    </nav>

    <div class="sidebar-footer">
      <el-dropdown trigger="click" @command="handleCommand" placement="top-start">
        <div class="user-dropdown-trigger">
          <div class="user-avatar">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
          </div>
          <div v-if="!isCollapsed" class="user-details">
            <span class="username">{{ userInfo?.username || '用户' }}</span>
            <span class="user-type">{{ userInfo?.role === 'admin' ? '管理员' : '普通用户' }}</span>
          </div>
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="profile" v-if="userInfo?.role === 'admin'">
              <el-icon><User /></el-icon>账号设置
            </el-dropdown-item>
            <el-dropdown-item divided command="logout">
              <el-icon><SwitchButton /></el-icon>退出登录
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </aside>

  <el-dialog
    v-model="showAdminModal"
    title="管理员账号设置"
    width="400px"
    :close-on-click-modal="false"
    append-to-body
  >
    <el-form :model="adminForm" label-width="80px">
      <el-form-item label="用户名">
        <el-input v-model="adminForm.username" placeholder="请输入新用户名" />
      </el-form-item>
      <el-form-item label="邮箱">
        <el-input v-model="adminForm.email" placeholder="请输入管理员邮箱" />
      </el-form-item>
      <el-form-item label="新密码">
        <el-input v-model="adminForm.password" type="password" placeholder="留空则不修改" show-password />
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="showAdminModal = false">取消</el-button>
        <el-button type="primary" @click="updateAdminProfile" :loading="updating">
          保存
        </el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { authApi } from '../services/api.js'
import { ElMessage } from 'element-plus'

const props = defineProps({
  userInfo: Object,
  activeTab: String
})

const emit = defineEmits(['logout', 'tab-change', 'collapse-change'])

const showSettingsSub = ref(false)
const isCollapsed = ref(false)

const showAdminModal = ref(false)
const updating = ref(false)
const adminForm = reactive({
  username: '',
  email: '',
  password: ''
})

const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value
  emit('collapse-change', isCollapsed.value)
}

const toggleSettingsSub = () => {
  if (isCollapsed.value) {
    emit('tab-change', 'settings')
  } else {
    showSettingsSub.value = !showSettingsSub.value
  }
}

const handleCommand = (command) => {
  if (command === 'logout') {
    emit('logout')
  } else if (command === 'profile') {
    openAdminModal()
  }
}

const openAdminModal = () => {
  adminForm.username = props.userInfo.username
  adminForm.password = ''
  showAdminModal.value = true
}

const updateAdminProfile = async () => {
  if (!adminForm.username) {
    ElMessage.warning('用户名不能为空')
    return
  }
  
  try {
    updating.value = true
    const res = await authApi.updateAdmin({
      id: props.userInfo.id,
      username: adminForm.username,
      email: adminForm.email,
      password: adminForm.password
    })
    
    if (res.success) {
      ElMessage.success('更新成功，请重新登录')
      showAdminModal.value = false
      emit('logout')
    } else {
      ElMessage.error(res.message || '更新失败')
    }
  } catch (error) {
    ElMessage.error('更新失败: ' + error.message)
  } finally {
    updating.value = false
  }
}

const handleTabClick = (tab) => {
  emit('tab-change', tab)
}

const handleSubMenuClick = (tab, section) => {
  emit('tab-change', tab, section)
  showSettingsSub.value = false
}
</script>

<style scoped>
.sidebar {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: 220px;
  background: #ffffff;
  border-right: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  z-index: 100;
  transition: width 0.3s ease;
  overflow: hidden;
}

.sidebar-collapsed {
  width: 64px;
}

.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem;
  border-bottom: 1px solid #f3f4f6;
  height: 64px;
  box-sizing: border-box;
  flex-shrink: 0;
}

.logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  overflow: hidden;
}

.logo-img {
  width: 28px;
  height: 28px;
  object-fit: contain;
  flex-shrink: 0;
}

.logo-text {
  font-size: 1rem;
  font-weight: 700;
  color: #111827;
  white-space: nowrap;
}

.collapse-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  color: #6b7280;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.collapse-btn:hover {
  background: #f3f4f6;
  color: #111827;
}

.collapse-btn svg {
  width: 18px;
  height: 18px;
}

.sidebar-nav {
  flex: 1;
  overflow-y: auto;
  padding: 0.5rem;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.sidebar-nav a {
  text-decoration: none;
  color: #6b7280;
  padding: 0.6rem 0.75rem;
  border-radius: 6px;
  transition: all 0.2s ease;
  font-weight: 500;
  font-size: 0.875rem;
  white-space: nowrap;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  overflow: hidden;
}

.sidebar-nav a svg {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
  opacity: 0.7;
}

.sidebar-nav a:hover {
  background: #f3f4f6;
  color: #111827;
}

.sidebar-nav a.active {
  background: #111827;
  color: white;
}

.sidebar-nav a.active svg {
  opacity: 1;
}

.nav-item-group {
  display: flex;
  flex-direction: column;
}

.sub-arrow {
  font-size: 12px;
  margin-left: auto;
  opacity: 0.7;
  transition: transform 0.2s;
}

.sub-arrow.is-open {
  transform: rotate(180deg);
}

.sub-menu {
  padding-left: 2.5rem;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.sub-menu-item {
  padding: 0.4rem 0.75rem;
  color: #6b7280;
  font-size: 0.825rem;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.2s;
  white-space: nowrap;
}

.sub-menu-item:hover {
  background: #f3f4f6;
  color: #111827;
}

.sidebar-footer {
  border-top: 1px solid #f3f4f6;
  padding: 0.75rem;
  flex-shrink: 0;
}

.user-dropdown-trigger {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 6px;
  transition: background-color 0.2s;
  overflow: hidden;
}

.user-dropdown-trigger:hover {
  background-color: #f3f4f6;
}

.user-avatar {
  width: 32px;
  height: 32px;
  background: #f3f4f6;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #4b5563;
  border: 1px solid #e5e7eb;
  flex-shrink: 0;
}

.user-avatar svg {
  width: 18px;
  height: 18px;
}

.user-details {
  display: flex;
  flex-direction: column;
  gap: 2px;
  overflow: hidden;
}

.username {
  font-weight: 600;
  color: #111827;
  font-size: 0.85rem;
  line-height: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-type {
  font-size: 0.7rem;
  color: #6b7280;
  line-height: 1;
}

@media (max-width: 768px) {
  .sidebar {
    width: 64px;
  }

  .logo-text,
  .sidebar-nav a span,
  .user-details,
  .sub-menu,
  .sub-arrow {
    display: none;
  }

  .sidebar-header {
    justify-content: center;
  }

  .collapse-btn {
    display: none;
  }
}
</style>
