<template>
  <div class="overview-page">
    <!-- 统计卡片 -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon icon-blue">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="7.5" cy="15.5" r="5.5"/><path d="m21 2-9.6 9.6"/><path d="m15.5 7.5 3 3L22 7l-3-3"/></svg>
        </div>
        <div class="stat-info">
          <h3>{{ stats.totalKeys }}</h3>
          <p>总卡密数量</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon icon-green">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/></svg>
        </div>
        <div class="stat-info">
          <h3>{{ stats.usedKeys }}</h3>
          <p>已使用卡密</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon icon-purple">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/><path d="m9 12 2 2 4-4"/></svg>
        </div>
        <div class="stat-info">
          <h3>{{ stats.activeKeys }}</h3>
          <p>有效卡密</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon icon-orange">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
        <div class="stat-info">
          <h3>{{ stats.totalUsers }}</h3>
          <p>用户总数</p>
        </div>
      </div>
    </div>

    <!-- 数据统计图表区域 -->
    <div class="charts-section">
      <div class="charts-grid">
        <!-- 卡密使用趋势图 -->
        <div class="chart-card">
          <div class="chart-header">
            <h3>卡密使用趋势</h3>
            <div class="chart-controls">
              <select v-model="chartPeriod" @change="updateChartData">
                <option value="7">最近7天</option>
                <option value="30">最近30天</option>
                <option value="90">最近90天</option>
              </select>
            </div>
          </div>
          <div class="chart-container">
            <canvas ref="usageChart" width="400" height="200"></canvas>
          </div>
        </div>

        <!-- 用户活跃度图表 -->
        <div class="chart-card">
          <div class="chart-header">
            <h3>用户活跃度</h3>
            <div class="chart-legend">
              <span class="legend-item">
                <span class="legend-color active"></span>
                活跃用户
              </span>
              <span class="legend-item">
                <span class="legend-color inactive"></span>
                非活跃用户
              </span>
            </div>
          </div>
          <div class="chart-container">
            <canvas ref="activityChart" width="400" height="200"></canvas>
          </div>
        </div>
      </div>
    </div>

    <!-- 服务器状态监控面板 -->
    <div class="server-status-section">
      <h2>服务器状态监控</h2>
      <div class="status-grid">
        <!-- 系统资源监控 -->
        <div class="status-card">
          <div class="status-header">
            <h3>系统资源</h3>
            <div class="status-indicator" :class="systemStatus.status">
              <svg viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="6"></circle></svg>
            </div>
          </div>
          <div class="status-metrics">
            <div class="metric-item">
              <span class="metric-label">CPU使用率</span>
              <div class="metric-bar">
                <div class="metric-fill" :style="{ width: systemStatus.cpu + '%' }"></div>
              </div>
              <span class="metric-value">{{ systemStatus.cpu }}%</span>
            </div>
            <div class="metric-item">
              <span class="metric-label">内存使用率</span>
              <div class="metric-bar">
                <div class="metric-fill" :style="{ width: systemStatus.memory + '%' }"></div>
              </div>
              <span class="metric-value">{{ systemStatus.memory }}%</span>
            </div>
            <div class="metric-item">
              <span class="metric-label">磁盘使用率</span>
              <div class="metric-bar">
                <div class="metric-fill" :style="{ width: systemStatus.disk + '%' }"></div>
              </div>
              <span class="metric-value">{{ systemStatus.disk }}%</span>
            </div>
          </div>
        </div>

        <!-- 数据库状态 -->
        <div class="status-card">
          <div class="status-header">
            <h3>数据库状态</h3>
            <div class="status-indicator" :class="databaseStatus.status">
              <svg viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="6"></circle></svg>
            </div>
          </div>
          <div class="status-info">
            <div class="info-item">
              <span class="info-label">连接数</span>
              <span class="info-value">{{ databaseStatus.connections }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">查询/秒</span>
              <span class="info-value">{{ databaseStatus.qps }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">响应时间</span>
              <span class="info-value">{{ databaseStatus.responseTime }}ms</span>
            </div>
            <div class="info-item">
              <span class="info-label">数据库大小</span>
              <span class="info-value">{{ databaseStatus.size }}</span>
            </div>
          </div>
        </div>

        <!-- API服务状态 -->
        <div class="status-card">
          <div class="status-header">
            <h3>API服务</h3>
            <div class="status-indicator" :class="apiStatus.status">
              <svg viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="6"></circle></svg>
            </div>
          </div>
          <div class="status-info">
            <div class="info-item">
              <span class="info-label">请求总数</span>
              <span class="info-value">{{ apiStatus.totalRequests }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">成功率</span>
              <span class="info-value">{{ apiStatus.successRate }}%</span>
            </div>
            <div class="info-item">
              <span class="info-label">平均响应时间</span>
              <span class="info-value">{{ apiStatus.avgResponseTime }}ms</span>
            </div>
            <div class="info-item">
              <span class="info-label">错误数</span>
              <span class="info-value">{{ apiStatus.errorCount }}</span>
            </div>
          </div>
        </div>


      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { monitorApi, statsApi } from '../services/api.js'

const props = defineProps({
  stats: Object
})

// 图表相关数据
const chartPeriod = ref('7')
const usageChart = ref(null)
const activityChart = ref(null)

// 定时器变量
let statusInterval = null

// 服务器状态数据
const systemStatus = ref({
  status: 'loading',
  cpu: 0,
  memory: 0,
  disk: 0,
  loading: true
})

const databaseStatus = ref({
  status: 'loading',
  connections: 0,
  qps: 0,
  responseTime: 0,
  size: '检测中...',
  loading: true
})

const apiStatus = ref({
  status: 'loading',
  totalRequests: 0,
  successRate: 0,
  avgResponseTime: 0,
  errorCount: 0,
  loading: true
})



// 图表数据
const chartData = ref({
  usage: {
    labels: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
    data: [120, 190, 300, 500, 200, 300, 450]
  },
  activity: {
    active: 65,
    inactive: 35
  }
})

// 绘制使用趋势图
const drawUsageChart = () => {
  if (!usageChart.value) return
  
  const ctx = usageChart.value.getContext('2d')
  const canvas = usageChart.value
  const { width, height } = canvas
  
  // 清空画布
  ctx.clearRect(0, 0, width, height)
  
  // 设置样式
  ctx.strokeStyle = '#4f46e5'
  ctx.fillStyle = 'rgba(79, 70, 229, 0.05)'
  ctx.lineWidth = 3
  
  const data = chartData.value.usage.data
  const max = Math.max(...data)
  const padding = 40
  const chartWidth = width - padding * 2
  const chartHeight = height - padding * 2
  
  // 绘制网格线
  ctx.strokeStyle = '#e5e7eb'
  ctx.lineWidth = 1
  for (let i = 0; i <= 5; i++) {
    const y = padding + (chartHeight / 5) * i
    ctx.beginPath()
    ctx.moveTo(padding, y)
    ctx.lineTo(width - padding, y)
    ctx.stroke()
  }
  
  // 绘制数据线
  ctx.strokeStyle = '#4f46e5'
  ctx.lineWidth = 3
  ctx.beginPath()
  
  data.forEach((value, index) => {
    const x = padding + (chartWidth / (data.length - 1)) * index
    const y = padding + chartHeight - (value / max) * chartHeight
    
    if (index === 0) {
      ctx.moveTo(x, y)
    } else {
      ctx.lineTo(x, y)
    }
  })
  
  ctx.stroke()
  
  // 绘制数据点
  ctx.fillStyle = '#4f46e5'
  data.forEach((value, index) => {
    const x = padding + (chartWidth / (data.length - 1)) * index
    const y = padding + chartHeight - (value / max) * chartHeight
    
    ctx.beginPath()
    ctx.arc(x, y, 4, 0, Math.PI * 2)
    ctx.fill()
  })

  // 绘制X轴标签
  ctx.fillStyle = '#9ca3af'
  ctx.font = '12px Arial'
  ctx.textAlign = 'center'
  
  const labels = chartData.value.usage.labels || []
  if (labels.length > 0) {
    // 根据数据量决定显示间隔
    const step = Math.ceil(data.length / 7)
    
    data.forEach((_, index) => {
      // 显示第一个、最后一个，以及中间的间隔点
      if (index === 0 || index === data.length - 1 || index % step === 0) {
        const x = padding + (chartWidth / (data.length - 1)) * index
        const label = labels[index]
        // 格式化日期，只显示 MM-DD
        const shortLabel = label ? label.substring(5) : ''
        ctx.fillText(shortLabel, x, height - 10)
      }
    })
  }
}

// 绘制活跃度饼图
const drawActivityChart = () => {
  if (!activityChart.value) return
  
  const ctx = activityChart.value.getContext('2d')
  const canvas = activityChart.value
  const { width, height } = canvas
  
  // 清空画布
  ctx.clearRect(0, 0, width, height)
  
  const centerX = width / 2
  const centerY = height / 2
  const radius = Math.min(width, height) / 3
  
  const active = chartData.value.activity.active
  const inactive = chartData.value.activity.inactive
  const total = active + inactive
  
  // 绘制活跃用户部分
  const activeAngle = (active / total) * 2 * Math.PI
  ctx.fillStyle = '#10b981'
  ctx.beginPath()
  ctx.moveTo(centerX, centerY)
  ctx.arc(centerX, centerY, radius, 0, activeAngle)
  ctx.closePath()
  ctx.fill()
  
  // 绘制非活跃用户部分
  ctx.fillStyle = '#f3f4f6'
  ctx.beginPath()
  ctx.moveTo(centerX, centerY)
  ctx.arc(centerX, centerY, radius, activeAngle, 2 * Math.PI)
  ctx.closePath()
  ctx.fill()
  
  // 绘制中心圆
  ctx.fillStyle = '#ffffff'
  ctx.beginPath()
  ctx.arc(centerX, centerY, radius * 0.6, 0, 2 * Math.PI)
  ctx.fill()
  
  // 绘制百分比文字
  ctx.fillStyle = '#374151'
  ctx.font = 'bold 24px Arial'
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText(`${active}%`, centerX, centerY)
}

// 加载图表数据
const loadChartData = async () => {
  try {
    const [usageData, activityData] = await Promise.all([
      statsApi.getCardUsageTrends(chartPeriod.value),
      statsApi.getUserActivityStats(chartPeriod.value)
    ])
    
    if (usageData && usageData.dates && usageData.counts) {
      chartData.value.usage.labels = usageData.dates
      chartData.value.usage.data = usageData.counts
    }
    
    if (activityData) {
      chartData.value.activity.active = activityData.active || 0
      chartData.value.activity.inactive = activityData.inactive || 0
    }
  } catch (error) {
    console.error('加载图表数据失败:', error)
  }
}

// 更新图表数据
const updateChartData = async () => {
  await loadChartData()
  
  nextTick(() => {
    drawUsageChart()
  })
}

// 加载服务器状态
const loadServerStatus = async () => {
  try {
    const [systemData, databaseData, apiData] = await Promise.all([
      monitorApi.getSystemStatus(),
      monitorApi.getDatabaseStatus(),
      monitorApi.getApiStatus()
    ])

    // 更新系统状态
    systemStatus.value = {
      status: systemData.status || 'offline',
      cpu: systemData.cpuUsage || 0,
      memory: systemData.memoryUsage || 0,
      disk: systemData.diskUsage || 0,
      loading: false
    }

    // 更新数据库状态
    databaseStatus.value = {
      status: databaseData.status || 'offline',
      connections: databaseData.activeConnections || 0,
      qps: databaseData.qps || 0,
      responseTime: databaseData.responseTime || 0,
      size: databaseData.databaseSize || 'N/A',
      loading: false
    }

    // 更新API状态
    apiStatus.value = {
      status: apiData.status || 'offline',
      totalRequests: apiData.requestCount || 0,
      successRate: apiData.successRate || 0,
      avgResponseTime: apiData.avgResponseTime || 0,
      errorCount: apiData.errorCount || 0,
      loading: false
    }

  } catch (error) {
    console.error('加载服务器状态失败:', error)
    
    // 设置错误状态
    systemStatus.value.loading = false
    databaseStatus.value.loading = false
    apiStatus.value.loading = false
    
    systemStatus.value.status = 'offline'
    databaseStatus.value.status = 'offline'
    apiStatus.value.status = 'offline'
  }
}

// 格式化时间
const formatTime = (timeString) => {
  if (!timeString) return '未知'
  
  try {
    const time = new Date(timeString)
    const now = new Date()
    const diff = now - time
    
    const minutes = Math.floor(diff / (1000 * 60))
    const hours = Math.floor(diff / (1000 * 60 * 60))
    const days = Math.floor(diff / (1000 * 60 * 60 * 24))
    
    if (days > 0) return `${days}天前`
    if (hours > 0) return `${hours}小时前`
    if (minutes > 0) return `${minutes}分钟前`
    return '刚刚'
  } catch (error) {
    return '未知'
  }
}



onMounted(async () => {
  // 初始加载数据
  await Promise.all([
    loadChartData(),
    loadServerStatus()
  ])
  
  nextTick(() => {
    drawUsageChart()
    drawActivityChart()
  })
  
  // 每30秒更新一次服务器状态
  statusInterval = setInterval(loadServerStatus, 30000)
})

onUnmounted(() => {
  if (statusInterval) {
    clearInterval(statusInterval)
  }
})
</script>

<style scoped>
.overview-page {
  padding: 0;
  width: 100%;
  box-sizing: border-box;
  overflow-x: auto;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: white;
  border: 1px solid #e5e7eb;
  color: #111827;
  padding: 1.5rem;
  border-radius: 4px;
  display: flex;
  align-items: center;
  gap: 1.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  transition: all 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-icon svg {
  width: 24px;
  height: 24px;
}

.icon-blue {
  background: #3b82f6;
  color: white;
}

.icon-green {
  background: #10b981;
  color: white;
}

.icon-purple {
  background: #8b5cf6;
  color: white;
}

.icon-orange {
  background: #f59e0b;
  color: white;
}

.stat-info h3 {
  font-size: 1.8rem;
  margin: 0;
  font-weight: 700;
  color: #111827;
  line-height: 1.2;
}

.stat-info p {
  margin: 0;
  color: #6b7280;
  font-size: 0.875rem;
  font-weight: 500;
}

/* 图表区域样式 */
.charts-section {
  margin: 2rem 0;
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 2rem;
}

.chart-card {
  background: white;
  border-radius: 4px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  border: 1px solid #e5e7eb;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.chart-header h3 {
  color: #111827;
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.chart-controls select {
  padding: 0.4rem 0.8rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  background: white;
  color: #374151;
  font-size: 0.875rem;
  outline: none;
}

.chart-controls select:focus {
  border-color: #4f46e5;
}

.chart-legend {
  display: flex;
  gap: 1.5rem;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #4b5563;
}

.legend-color {
  width: 10px;
  height: 10px;
  border-radius: 2px;
}

.legend-color.active {
  background: #10b981;
}

.legend-color.inactive {
  background: #f3f4f6;
}

.chart-container {
  height: 240px;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
}

.chart-container canvas {
  max-width: 100%;
  max-height: 100%;
}

/* 服务器状态监控样式 */
.server-status-section {
  margin: 2rem 0;
}

.server-status-section h2 {
  color: #111827;
  margin-bottom: 1.5rem;
  font-size: 1.25rem;
  font-weight: 700;
}

.status-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.status-card {
  background: white;
  border-radius: 4px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  border: 1px solid #e5e7eb;
  transition: all 0.2s ease;
}

.status-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.status-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.25rem;
  border-bottom: 1px solid #f3f4f6;
  padding-bottom: 0.75rem;
}

.status-header h3 {
  color: #111827;
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
}

.status-indicator {
  width: 12px;
  height: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.status-indicator svg {
  width: 10px;
  height: 10px;
}

.status-indicator.online {
  color: #10b981;
}

.status-indicator.offline {
  color: #ef4444;
}

.status-indicator.warning {
  color: #f59e0b;
}

.refresh-btn {
  cursor: pointer;
  color: #6b7280;
  padding: 0.4rem;
  border-radius: 4px;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
}

.refresh-btn svg {
  width: 16px;
  height: 16px;
}

.refresh-btn:hover {
  background: #f3f4f6;
  color: #111827;
  transform: rotate(180deg);
}

/* 系统资源监控 */
.status-metrics {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.metric-item {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.metric-label {
  font-size: 0.875rem;
  color: #4b5563;
  min-width: 80px;
  font-weight: 500;
}

.metric-bar {
  flex: 1;
  height: 6px;
  background: #f3f4f6;
  border-radius: 2px;
  overflow: hidden;
}

.metric-fill {
  height: 100%;
  background: #4f46e5;
  border-radius: 2px;
  transition: width 0.3s ease;
}

.metric-value {
  font-size: 0.875rem;
  color: #111827;
  font-weight: 600;
  min-width: 45px;
  text-align: right;
  font-variant-numeric: tabular-nums;
}

/* 状态信息 */
.status-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-label {
  font-size: 0.75rem;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.info-value {
  font-size: 1.25rem;
  color: #111827;
  font-weight: 700;
}



@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .charts-grid {
    grid-template-columns: 1fr;
  }

  .status-grid {
    grid-template-columns: 1fr;
  }

  .status-info {
    grid-template-columns: 1fr;
  }

  .chart-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.75rem;
  }
}
</style>