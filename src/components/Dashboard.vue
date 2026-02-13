<template>
  <div class="dashboard">
    <!-- 导航栏组件 -->
    <NavigationBar 
      :user-info="userInfo"
      :active-tab="activeTab"
      @tab-change="handleTabChange"
      @logout="handleLogout"
    />

    <!-- 主要内容区域 -->
    <main class="dashboard-main">
      <!-- 概览页面 -->
      <OverviewPage 
        v-if="activeTab === 'overview'"
        :stats="stats"
        :carousel-data="carouselData"
        :features="features"
        @prev-slide="prevSlide"
        @next-slide="nextSlide"
        @slide-change="handleSlideChange"
      />

      <!-- 卡密管理页面 -->
      <KeysManagePage 
        v-if="activeTab === 'keys'"
        :keys="keys"
        @create-keys="handleCreateKeys"
        @delete-key="handleDeleteKey"
      />

      <!-- 定价管理页面 -->
      <PricingManagePage 
        v-if="activeTab === 'pricing'"
      />

      <!-- 订单管理页面 -->
      <OrdersManagePage 
        v-if="activeTab === 'orders'"
      />

      <!-- API管理页面 -->
      <ApiManagePage 
        v-if="activeTab === 'api'"
        :api-keys="apiKeys"
        @generate-api-key="handleGenerateApiKey"
        @delete-api-key="handleDeleteApiKey"
        @update-api-key="handleUpdateApiKey"
        @toggle-api-key="handleToggleApiKey"
      />

      <!-- 用户管理页面 -->
      <UserManagePage 
        v-if="activeTab === 'users'"
      />

      <!-- 通知管理页面 -->
      <NotificationPage 
        v-if="activeTab === 'notification'"
      />

      <!-- 系统设置页面 -->
      <SettingsPage 
        v-if="activeTab === 'settings'"
        :user-info="userInfo"
        @save-settings="handleSaveSettings"
        @clear-cache="handleClearCache"
        @optimize-database="handleOptimizeDatabase"
        @clear-logs="handleClearLogs"
        @create-backup="handleCreateBackup"
      />

      <!-- 系统维护页面 -->
      <MaintenanceAdmin 
        v-if="activeTab === 'maintenance'"
      />

      <!-- 系统信息页面 -->
      <SystemInfo 
        v-if="activeTab === 'system_info'"
      />
    </main>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { mockAdmins, mockUsers, mockCards, mockApiKeys, mockSettings, mockSlides, mockFeatures, mockDeleteKey } from '../data/mockData.js'
import { cardApi, statsApi } from '../services/api.js'
import NavigationBar from './NavigationBar.vue'
import OverviewPage from './OverviewPage.vue'
import KeysManagePage from './KeysManagePage.vue'
import PricingManagePage from './PricingManagePage.vue'
import OrdersManagePage from './OrdersManagePage.vue'
import ApiManagePage from './ApiManagePage.vue'
import UserManagePage from './UserManagePage.vue'
import SettingsPage from './SettingsPage.vue'
import NotificationPage from './NotificationPage.vue'
import MaintenanceAdmin from './MaintenanceAdmin.vue'
import SystemInfo from './SystemInfo.vue'

const props = defineProps({
  userInfo: Object
})

const emit = defineEmits(['logout'])

// 响应式数据
const activeTab = ref('overview')
const currentSlide = ref(0)

const stats = reactive({
  totalKeys: 0,
  usedKeys: 0,
  activeKeys: 0,
  totalUsers: 0
})

const carouselData = ref([])
const features = ref([])
const keys = ref([])
const apiKeys = ref([])

// 创建模拟数据对象
const mockData = {
  users: mockUsers,
  admins: mockAdmins,
  keys: mockCards,
  apiKeys: mockApiKeys,
  carouselData: mockSlides,
  features: mockFeatures
}

// 方法
const handleLogout = () => {
  emit('logout')
}

const handleTabChange = (tab, section) => {
  console.log('Dashboard: 接收到标签页切换事件:', tab, 'Section:', section)
  console.log('Dashboard: 当前activeTab:', activeTab.value)
  activeTab.value = tab
  
  if (section && tab === 'settings') {
    // Wait for DOM update then scroll
    setTimeout(() => {
      const element = document.getElementById('settings-' + section)
      if (element) {
        element.scrollIntoView({ behavior: 'smooth', block: 'start' })
      }
    }, 100)
  }
  
  console.log('Dashboard: 切换后activeTab:', activeTab.value)
}

const formatDate = (timestamp) => {
  return new Date(timestamp).toLocaleString('zh-CN')
}

const prevSlide = () => {
  currentSlide.value = currentSlide.value === 0 ? carouselData.value.length - 1 : currentSlide.value - 1
}

const nextSlide = () => {
  currentSlide.value = currentSlide.value === carouselData.value.length - 1 ? 0 : currentSlide.value + 1
}

const handleSlideChange = (index) => {
  currentSlide.value = index
}

const handleGenerateKeys = async (keyData) => {
  try {
    const result = await cardApi.createCards(keyData)
    if (result.success) {
      // 重新加载卡密数据
      await loadKeys()
      alert('卡密创建成功')
    }
  } catch (error) {
    console.error('生成卡密失败:', error)
    alert('生成卡密失败: ' + error.message)
  }
}

const handleCreateKeys = async (keyData) => {
  await handleGenerateKeys(keyData)
}

const handleDeleteKey = async (keyId) => {
  try {
    const result = await cardApi.deleteCard(keyId)
    if (result.success) {
      // 重新加载卡密数据
      await loadKeys()
      alert(result.message)
    } else {
      alert(result.message)
    }
  } catch (error) {
    console.error('删除卡密失败:', error)
    alert('删除卡密失败')
  }
}

// 加载统计数据
const loadDashboardStats = async () => {
  try {
    const result = await statsApi.getDashboardStats()
    if (result) {
      stats.totalKeys = result.totalKeys
      stats.usedKeys = result.usedKeys
      stats.activeKeys = result.activeKeys
      stats.totalUsers = result.totalUsers
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

// 加载卡密数据
const loadKeys = async () => {
  try {
    const result = await cardApi.getAllCards()
    if (result.success) {
      keys.value = result.data
    }
    // 加载统计数据
    await loadDashboardStats()
  } catch (error) {
    console.error('加载卡密数据失败:', error)
  }
}

const handleGenerateApiKey = () => {
  const apiKey = 'ak_' + Math.random().toString(36).substr(2, 32)
  apiKeys.value.push({
    id: Date.now(),
    name: `API密钥 ${apiKeys.value.length + 1}`,
    key: apiKey,
    createdAt: Date.now(),
    lastUsed: null,
    isActive: true,
    permissions: {
      read: true,
      write: false,
      delete: false
    }
  })
}

const handleDeleteApiKey = (keyId) => {
  apiKeys.value = apiKeys.value.filter(key => key.id !== keyId)
}

const handleUpdateApiKey = (updatedKey) => {
  const index = apiKeys.value.findIndex(key => key.id === updatedKey.id)
  if (index !== -1) {
    apiKeys.value[index] = { ...apiKeys.value[index], ...updatedKey }
  }
}

const handleToggleApiKey = (keyId) => {
  const key = apiKeys.value.find(key => key.id === keyId)
  if (key) {
    key.isActive = !key.isActive
  }
}

const handleSaveSettings = (settingsData) => {
  console.log('保存设置:', settingsData)
  // 这里可以添加保存设置的逻辑
}

const handleClearCache = () => {
  console.log('清理缓存')
  // 这里可以添加清理缓存的逻辑
}

const handleOptimizeDatabase = () => {
  console.log('优化数据库')
  // 这里可以添加优化数据库的逻辑
}

const handleClearLogs = () => {
  console.log('清理日志')
  // 这里可以添加清理日志的逻辑
}

const handleCreateBackup = () => {
  console.log('创建备份')
  // 这里可以添加创建备份的逻辑
}


// 初始化数据
onMounted(async () => {
  // 加载模拟数据
  carouselData.value = mockData.carouselData
  features.value = mockData.features
  apiKeys.value = mockData.apiKeys
  
  // 异步加载卡密数据
  await loadKeys()
  
  // 自动轮播
  setInterval(() => {
    nextSlide()
  }, 5000)
})
</script>

<style scoped>
.dashboard {
  min-height: 100vh;
  background: #f9fafb;
  width: 100%;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  padding-top: 64px;
}

.dashboard-main {
  padding: 2rem;
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
  box-sizing: border-box;
  flex: 1;
}

@media (max-width: 768px) {
  .dashboard-main {
    padding: 1rem;
    padding-top: 1rem; /* Adjust if header is fixed */
  }
}
</style>