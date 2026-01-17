<template>
  <header class="dashboard-header">
     <div class="header-left">
      <div class="logo">
        <img src="../assets/icon.png" alt="XXG-KAMI-PRO" class="logo-img">
        <span class="logo-text">XXG-KAMI-PRO</span>
      </div>
      <nav class="nav-menu">
        <a href="#" 
           :class="{ active: activeTab === 'overview' }" 
           @click.prevent="handleTabClick('overview')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
          概览
        </a>
        <a href="#" 
           :class="{ active: activeTab === 'keys' }" 
           @click.prevent="handleTabClick('keys')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"></path></svg>
          卡密管理
        </a>
        <a href="#" 
           :class="{ active: activeTab === 'pricing' }" 
           @click.prevent="handleTabClick('pricing')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
          定价管理
        </a>
        <a href="#" 
           :class="{ active: activeTab === 'orders' }" 
           @click.prevent="handleTabClick('orders')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
          订单管理
        </a>
        <a href="#" 
           :class="{ active: activeTab === 'api' }" 
           @click.prevent="handleTabClick('api')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg>
          API管理
        </a>
        <a href="#" 
           :class="{ active: activeTab === 'notification' }" 
           @click.prevent="handleTabClick('notification')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
          通知管理
        </a>
        <a href="#" 
           :class="{ active: activeTab === 'settings' }" 
           @click.prevent="handleTabClick('settings')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
          系统设置
        </a>
        <a href="#" 
           :class="{ active: activeTab === 'maintenance' }" 
           @click.prevent="handleTabClick('maintenance')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
          系统维护
        </a>
      </nav>
    </div>
    <div class="header-right">
      <div class="message-center-container" ref="messageContainer">
        <div class="message-icon-btn" @click="toggleMessages" :class="{ active: showMessages }">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
          <span class="badge" v-if="unreadCount > 0">{{ unreadCount }}</span>
        </div>
        
        <div class="message-dropdown" v-if="showMessages">
          <div class="dropdown-header">
            <h3>消息通知</h3>
            <button class="mark-read-btn" v-if="unreadCount > 0">全部已读</button>
          </div>
          <div class="dropdown-content">
            <div class="empty-state">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
              <p>暂无新消息</p>
            </div>
          </div>
        </div>
      </div>

      <div class="user-info">
        <div class="user-avatar">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
        </div>
        <div class="user-details">
          <span class="username">{{ userInfo?.username || '用户' }}</span>
          <span class="user-type">{{ userInfo?.role === 'admin' ? '管理员' : '普通用户' }}</span>
        </div>
        <button class="logout-btn" @click="$emit('logout')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
          登出
        </button>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

defineProps({
  userInfo: Object,
  activeTab: String
})

const emit = defineEmits(['logout', 'tab-change'])

const showMessages = ref(false)
const unreadCount = ref(0)
const messageContainer = ref(null)

const handleTabClick = (tab) => {
  console.log('NavigationBar: 点击了标签页:', tab)
  emit('tab-change', tab)
}

const toggleMessages = () => {
  showMessages.value = !showMessages.value
}

// 点击外部关闭下拉菜单
const handleClickOutside = (event) => {
  if (messageContainer.value && !messageContainer.value.contains(event.target)) {
    showMessages.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
/* 消息中心样式 */
.message-center-container {
  position: relative;
  margin-right: 1rem;
}

.message-icon-btn {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #6b7280;
  border-radius: 4px;
  transition: all 0.2s;
  position: relative;
}

.message-icon-btn:hover, .message-icon-btn.active {
  background: #f3f4f6;
  color: #111827;
}

.message-icon-btn svg {
  width: 20px;
  height: 20px;
}

.badge {
  position: absolute;
  top: -2px;
  right: -2px;
  background: #ef4444;
  color: white;
  font-size: 10px;
  min-width: 14px;
  height: 14px;
  border-radius: 7px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 2px;
  border: 1px solid white;
}

.message-dropdown {
  position: absolute;
  top: 100%;
  right: -50px; /* 调整对齐 */
  margin-top: 10px;
  width: 300px;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  z-index: 1000;
  display: flex;
  flex-direction: column;
}

/* 箭头 */
.message-dropdown::before {
  content: '';
  position: absolute;
  top: -6px;
  right: 60px; /* 对应图标位置 */
  width: 10px;
  height: 10px;
  background: white;
  border-left: 1px solid #e5e7eb;
  border-top: 1px solid #e5e7eb;
  transform: rotate(45deg);
}

.dropdown-header {
  padding: 1rem;
  border-bottom: 1px solid #f3f4f6;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.dropdown-header h3 {
  margin: 0;
  font-size: 0.95rem;
  font-weight: 600;
  color: #111827;
}

.mark-read-btn {
  font-size: 0.8rem;
  color: #6b7280;
  background: none;
  border: none;
  cursor: pointer;
}

.mark-read-btn:hover {
  color: #3b82f6;
}

.dropdown-content {
  max-height: 300px;
  overflow-y: auto;
  min-height: 150px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.empty-state {
  text-align: center;
  color: #9ca3af;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.empty-state svg {
  width: 32px;
  height: 32px;
  opacity: 0.5;
}

.empty-state p {
  margin: 0;
  font-size: 0.85rem;
}



.dashboard-header {
  background: #ffffff;
  border-bottom: 1px solid #e5e7eb;
  padding: 0 1.5rem;
  height: 64px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  position: fixed;
  top: 0;
  left: 0;
  z-index: 100;
  box-sizing: border-box;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 3rem;
  flex: 1;
  min-width: 0;
  height: 100%;
}

.logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-shrink: 0;
}

.logo-img {
  width: 28px;
  height: 28px;
  object-fit: contain;
}

.logo-text {
  font-size: 1.1rem;
  font-weight: 700;
  color: #111827;
  white-space: nowrap;
  letter-spacing: -0.025em;
}

.nav-menu {
  display: flex;
  gap: 0.5rem;
  height: 100%;
  align-items: center;
}

.nav-menu a {
  text-decoration: none;
  color: #6b7280;
  padding: 0.5rem 0.75rem;
  border-radius: 4px;
  transition: all 0.2s ease;
  font-weight: 500;
  font-size: 0.9rem;
  white-space: nowrap;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.nav-menu a svg {
  width: 16px;
  height: 16px;
  opacity: 0.7;
}

.nav-menu a:hover {
  background: #f3f4f6;
  color: #111827;
}

.nav-menu a.active {
  background: #111827;
  color: white;
}

.nav-menu a.active svg {
  opacity: 1;
}

.header-right {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.user-avatar {
  width: 32px;
  height: 32px;
  background: #f3f4f6;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #4b5563;
  border: 1px solid #e5e7eb;
}

.user-avatar svg {
  width: 18px;
  height: 18px;
}

.user-details {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.username {
  font-weight: 600;
  color: #111827;
  font-size: 0.9rem;
  line-height: 1;
}

.user-type {
  font-size: 0.75rem;
  color: #6b7280;
  line-height: 1;
}

.logout-btn {
  background: white;
  color: #ef4444;
  border: 1px solid #e5e7eb;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.2s ease;
  font-size: 0.85rem;
  font-weight: 500;
}

.logout-btn:hover {
  background: #fef2f2;
  border-color: #fecaca;
}

.logout-btn svg {
  width: 14px;
  height: 14px;
}

@media (max-width: 1024px) {
  .header-left {
    gap: 1.5rem;
  }
}

@media (max-width: 768px) {
  .dashboard-header {
    flex-direction: column;
    height: auto;
    padding: 1rem;
    gap: 1rem;
    position: relative;
  }

  .header-left {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
    width: 100%;
  }

  .nav-menu {
    flex-wrap: wrap;
    width: 100%;
    gap: 0.5rem;
  }
  
  .nav-menu a {
    flex: 1;
    justify-content: center;
  }

  .header-right {
    width: 100%;
    justify-content: flex-end;
  }
}
</style>