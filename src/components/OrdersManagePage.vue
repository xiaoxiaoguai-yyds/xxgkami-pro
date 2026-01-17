<template>
  <div class="orders-manage-page">
    <div class="section-header">
      <h2>订单管理</h2>
      <p class="section-description">管理用户购买的卡密订单</p>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="search-filters-card">
      <div class="filter-row">
        <div class="filter-group">
          <label>订单号：</label>
          <input
            v-model="searchParams.orderId"
            type="text"
            placeholder="请输入订单号"
            class="filter-input"
          />
        </div>
        
        <div class="filter-group">
          <label>用户名：</label>
          <input
            v-model="searchParams.username"
            type="text"
            placeholder="请输入用户名"
            class="filter-input"
          />
        </div>
        
        <div class="filter-group">
          <label>订单状态：</label>
          <select v-model="searchParams.status" class="filter-select">
            <option value="all">全部</option>
            <option value="completed">已完成</option>
            <option value="pending">待处理</option>
            <option value="failed">已失败</option>
            <option value="refunded">已退款</option>
          </select>
        </div>
        
        <div class="filter-group">
          <label>卡密类型：</label>
          <select v-model="searchParams.cardType" class="filter-select">
            <option value="all">全部</option>
            <option value="time">时间卡</option>
            <option value="count">次数卡</option>
          </select>
        </div>
      </div>
      
      <div class="filter-row">
        <div class="filter-group">
          <label>购买时间：</label>
          <input
            v-model="dateRange.start"
            type="date"
            class="filter-input date-input"
            placeholder="开始日期"
          />
          <span class="date-separator">至</span>
          <input
            v-model="dateRange.end"
            type="date"
            class="filter-input date-input"
            placeholder="结束日期"
          />
        </div>
        
        <div class="filter-actions">
          <button class="btn-primary" @click="searchOrders" :disabled="loading">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            {{ loading ? '搜索中...' : '搜索' }}
          </button>
          <button class="btn-secondary" @click="resetSearch">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 4v6h-6"></path><path d="M1 20v-6h6"></path><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
            重置
          </button>
        </div>
      </div>
    </div>

    <!-- 统计信息 -->
    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
        </div>
        <div class="stat-info">
          <div class="stat-number">{{ stats.totalOrders }}</div>
          <div class="stat-label">总订单数</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon completed">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
        </div>
        <div class="stat-info">
          <div class="stat-number">{{ stats.completedOrders }}</div>
          <div class="stat-label">已完成订单</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon pending">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
        </div>
        <div class="stat-info">
          <div class="stat-number">{{ stats.pendingOrders }}</div>
          <div class="stat-label">待处理订单</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon revenue">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
        </div>
        <div class="stat-info">
          <div class="stat-number">¥{{ stats.totalRevenue }}</div>
          <div class="stat-label">总收入</div>
        </div>
      </div>
    </div>

    <!-- 订单列表 -->
    <div class="orders-list">
      <div v-if="loading" class="loading-state">
        <div class="loading-spinner">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="spin"><path d="M21 12a9 9 0 1 1-6.219-8.56"></path></svg>
        </div>
        <p>加载中...</p>
      </div>
      
      <div v-else-if="orders.length === 0" class="empty-state">
        <div class="empty-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 16 12 14 15 10 15 8 12 2 12"></polyline><path d="M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z"></path></svg>
        </div>
        <h3>暂无订单数据</h3>
        <p>当前筛选条件下没有找到订单</p>
      </div>
      
      <div v-else class="orders-grid">
        <div class="order-card" v-for="order in orders" :key="order.order_id">
          <div class="order-header">
            <div class="order-id">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
              <span>{{ order.order_id }}</span>
            </div>
            <div class="order-status" :class="getStatusClass(order.status)">
              {{ getStatusText(order.status) }}
            </div>
          </div>
          
          <div class="order-info">
            <div class="info-row">
              <div class="info-item">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                <span>{{ order.username }}</span>
              </div>
              <div class="info-item">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                <span>{{ order.purchase_time }}</span>
              </div>
            </div>
            
            <div class="info-row">
              <div class="info-item">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
                <span class="card-type" :class="order.card_type">
                  {{ order.card_type === 'time' ? '时间卡' : '次数卡' }}
                </span>
                <span class="card-spec">{{ order.card_spec }}</span>
              </div>
              <div class="info-item">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                <span>数量: {{ order.quantity }}</span>
              </div>
            </div>
            
            <div class="info-row">
              <div class="info-item">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                <span>单价: ¥{{ order.unit_price }}</span>
              </div>
              <div class="info-item total-price">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="2" width="16" height="20" rx="2" ry="2"></rect><line x1="12" y1="18" x2="12" y2="18"></line><line x1="8" y1="18" x2="8" y2="18"></line><line x1="16" y1="18" x2="16" y2="18"></line><line x1="12" y1="14" x2="12" y2="14"></line><line x1="8" y1="14" x2="8" y2="14"></line><line x1="16" y1="14" x2="16" y2="14"></line><line x1="12" y1="10" x2="12" y2="10"></line><line x1="8" y1="10" x2="8" y2="10"></line><line x1="16" y1="10" x2="16" y2="10"></line></svg>
                <span>总价: ¥{{ order.total_price }}</span>
              </div>
            </div>
            
            <div class="info-row">
              <div class="info-item">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
                <span>{{ order.payment_method }}</span>
              </div>
            </div>
          </div>
          
          <div class="order-actions">
            <button class="btn-secondary" @click="viewOrderDetail(order)">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
              查看详情
            </button>
            <button 
              v-if="order.status === 'pending'"
              class="btn-success" 
              @click="updateOrderStatus(order.order_id, 'completed')"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
              完成
            </button>
            <button 
              v-if="order.status === 'pending'"
              class="btn-danger" 
              @click="updateOrderStatus(order.order_id, 'failed')"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
              失败
            </button>
          </div>
        </div>
      </div>

      <!-- 分页 -->
      <div class="pagination" v-if="orders.length > 0">
        <div class="pagination-info">
          显示 {{ (pagination.page - 1) * pagination.pageSize + 1 }} - 
          {{ Math.min(pagination.page * pagination.pageSize, pagination.total) }} 
          条，共 {{ pagination.total }} 条
        </div>
        <div class="pagination-controls">
          <button 
            class="btn-secondary" 
            @click="handleCurrentChange(pagination.page - 1)"
            :disabled="pagination.page <= 1"
          >
            <i class="fas fa-chevron-left"></i>
            上一页
          </button>
          
          <div class="page-numbers">
            <button 
              v-for="page in getPageNumbers()" 
              :key="page"
              class="page-btn"
              :class="{ active: page === pagination.page }"
              @click="handleCurrentChange(page)"
            >
              {{ page }}
            </button>
          </div>
          
          <button 
            class="btn-secondary" 
            @click="handleCurrentChange(pagination.page + 1)"
            :disabled="pagination.page >= Math.ceil(pagination.total / pagination.pageSize)"
          >
            下一页
            <i class="fas fa-chevron-right"></i>
          </button>
        </div>
        
        <div class="page-size-selector">
          <label>每页显示：</label>
          <select v-model="pagination.pageSize" @change="handleSizeChange" class="filter-select">
            <option value="10">10</option>
            <option value="20">20</option>
            <option value="50">50</option>
            <option value="100">100</option>
          </select>
        </div>
      </div>
    </div>

    <!-- 订单详情模态框 -->
    <div v-if="detailDialogVisible" class="modal-overlay" @click="detailDialogVisible = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>订单详情</h3>
          <button class="close-btn" @click="detailDialogVisible = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body" v-if="selectedOrder">
          <div class="detail-section">
            <h4>基本信息</h4>
            <div class="detail-grid">
              <div class="detail-item">
                <label>订单号：</label>
                <span>{{ selectedOrder.order_id }}</span>
              </div>
              <div class="detail-item">
                <label>用户名：</label>
                <span>{{ selectedOrder.username }}</span>
              </div>
              <div class="detail-item">
                <label>购买时间：</label>
                <span>{{ selectedOrder.purchase_time }}</span>
              </div>
              <div class="detail-item">
                <label>订单状态：</label>
                <span class="status-badge" :class="getStatusClass(selectedOrder.status)">
                  {{ getStatusText(selectedOrder.status) }}
                </span>
              </div>
            </div>
          </div>

          <div class="detail-section">
            <h4>商品信息</h4>
            <div class="detail-grid">
              <div class="detail-item">
                <label>卡密类型：</label>
                <span class="card-type-badge" :class="selectedOrder.card_type">
                  {{ selectedOrder.card_type === 'time' ? '时间卡' : '次数卡' }}
                </span>
              </div>
              <div class="detail-item">
                <label>规格：</label>
                <span>{{ selectedOrder.card_spec }}</span>
              </div>
              <div class="detail-item">
                <label>数量：</label>
                <span>{{ selectedOrder.quantity }}</span>
              </div>
              <div class="detail-item">
                <label>单价：</label>
                <span>¥{{ selectedOrder.unit_price }}</span>
              </div>
              <div class="detail-item">
                <label>总价：</label>
                <span class="total-price">¥{{ selectedOrder.total_price }}</span>
              </div>
              <div class="detail-item">
                <label>支付方式：</label>
                <span>{{ selectedOrder.payment_method }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section" v-if="selectedOrder.card_keys && selectedOrder.card_keys.length > 0">
            <h4>卡密信息</h4>
            <div class="card-keys">
              <div v-for="(key, index) in selectedOrder.card_keys" :key="index" class="card-key-item">
                <span class="key-index">{{ index + 1 }}.</span>
                <code class="key-value">{{ key }}</code>
                <button class="copy-btn" @click="copyCardKey(key)">
                  <i class="fas fa-copy"></i>
                  复制
                </button>
              </div>
            </div>
          </div>

          <div class="detail-section" v-if="selectedOrder.remark">
            <h4>备注信息</h4>
            <p class="remark">{{ selectedOrder.remark }}</p>
          </div>
        </div>

        <div class="modal-actions">
          <button class="btn-secondary" @click="detailDialogVisible = false">关闭</button>
          <button 
            v-if="selectedOrder && selectedOrder.status === 'pending'"
            class="btn-primary" 
            @click="showStatusUpdateDialog"
          >
            更新状态
          </button>
        </div>
      </div>
    </div>

    <!-- 状态更新模态框 -->
    <div v-if="statusUpdateDialogVisible" class="modal-overlay" @click="statusUpdateDialogVisible = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>更新订单状态</h3>
          <button class="close-btn" @click="statusUpdateDialogVisible = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>新状态</label>
            <select v-model="statusUpdateForm.status" class="filter-select">
              <option value="">请选择新状态</option>
              <option value="completed">已完成</option>
              <option value="failed">已失败</option>
              <option value="refunded">已退款</option>
            </select>
          </div>
          <div class="form-group">
            <label>备注</label>
            <textarea
              v-model="statusUpdateForm.remark"
              rows="3"
              placeholder="请输入更新原因或备注"
              class="form-textarea"
            ></textarea>
          </div>
        </div>

        <div class="modal-actions">
          <button class="btn-secondary" @click="statusUpdateDialogVisible = false">取消</button>
          <button class="btn-primary" @click="confirmStatusUpdate" :disabled="updating">
            {{ updating ? '更新中...' : '确认更新' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { orderApi } from '../services/api'

// 响应式数据
const loading = ref(false)
const updating = ref(false)
const orders = ref([])
const allOrders = ref([])
const dateRange = reactive({
  start: '',
  end: ''
})
const detailDialogVisible = ref(false)
const statusUpdateDialogVisible = ref(false)
const selectedOrder = ref(null)

// 搜索参数
const searchParams = reactive({
  orderId: '',
  username: '',
  status: 'all',
  cardType: 'all'
})

// 分页参数
const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
})

// 状态更新表单
const statusUpdateForm = reactive({
  status: '',
  remark: ''
})

// 统计数据
const stats = computed(() => {
  const totalOrders = allOrders.value.length
  const completedOrders = allOrders.value.filter(order => order.status === 'completed').length
  const pendingOrders = allOrders.value.filter(order => order.status === 'pending').length
  const totalRevenue = allOrders.value
    .filter(order => order.status === 'completed')
    .reduce((sum, order) => sum + order.total_price, 0)
    .toFixed(2)

  return {
    totalOrders,
    completedOrders,
    pendingOrders,
    totalRevenue
  }
})

// 获取订单列表
const getOrders = async () => {
  loading.value = true
  try {
    const params = {
      orderId: searchParams.orderId,
      username: searchParams.username,
      status: searchParams.status === 'all' ? '' : searchParams.status,
      cardType: searchParams.cardType === 'all' ? '' : searchParams.cardType,
      startTime: dateRange.start,
      endTime: dateRange.end
    }
    
    const response = await orderApi.getAllOrders(params)
    if (response.success) {
      // 处理数据，添加 card_keys 数组转换
      const fetchedOrders = response.data.map(order => ({
        ...order,
        card_keys: order.card_keys ? order.card_keys.split(',') : []
      }))

      allOrders.value = fetchedOrders
      pagination.total = allOrders.value.length
      
      updatePagedOrders()
    }
  } catch (error) {
    console.error(error)
    showToast('获取订单列表失败', 'error')
  } finally {
    loading.value = false
  }
}

const updatePagedOrders = () => {
  const start = (pagination.page - 1) * pagination.pageSize
  const end = start + pagination.pageSize
  orders.value = allOrders.value.slice(start, end)
}

// 搜索订单
const searchOrders = () => {
  pagination.page = 1
  getOrders()
}

// 重置搜索
const resetSearch = () => {
  Object.assign(searchParams, {
    orderId: '',
    username: '',
    status: 'all',
    cardType: 'all'
  })
  dateRange.start = ''
  dateRange.end = ''
  pagination.page = 1
  getOrders()
}

// 处理页面大小变化
const handleSizeChange = () => {
  pagination.page = 1
  updatePagedOrders()
}

// 处理当前页变化
const handleCurrentChange = (page) => {
  if (page >= 1 && page <= Math.ceil(pagination.total / pagination.pageSize)) {
    pagination.page = page
    updatePagedOrders()
  }
}

// 获取页码数组
const getPageNumbers = () => {
  const totalPages = Math.ceil(pagination.total / pagination.pageSize)
  const current = pagination.page
  const pages = []
  
  if (totalPages <= 7) {
    for (let i = 1; i <= totalPages; i++) {
      pages.push(i)
    }
  } else {
    if (current <= 4) {
      for (let i = 1; i <= 5; i++) {
        pages.push(i)
      }
      pages.push('...')
      pages.push(totalPages)
    } else if (current >= totalPages - 3) {
      pages.push(1)
      pages.push('...')
      for (let i = totalPages - 4; i <= totalPages; i++) {
        pages.push(i)
      }
    } else {
      pages.push(1)
      pages.push('...')
      for (let i = current - 1; i <= current + 1; i++) {
        pages.push(i)
      }
      pages.push('...')
      pages.push(totalPages)
    }
  }
  
  return pages
}

// 获取状态类名
const getStatusClass = (status) => {
  const statusMap = {
    completed: 'status-completed',
    pending: 'status-pending',
    failed: 'status-failed',
    refunded: 'status-refunded'
  }
  return statusMap[status] || 'status-unknown'
}

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    completed: '已完成',
    pending: '待处理',
    failed: '已失败',
    refunded: '已退款'
  }
  return statusMap[status] || '未知'
}

// 查看订单详情
const viewOrderDetail = (order) => {
  selectedOrder.value = order
  detailDialogVisible.value = true
}

// 复制卡密
const copyCardKey = async (key) => {
  try {
    await navigator.clipboard.writeText(key)
    showToast('卡密已复制到剪贴板', 'success')
  } catch (error) {
    showToast('复制失败', 'error')
  }
}

// 显示状态更新对话框
const showStatusUpdateDialog = () => {
  statusUpdateForm.status = ''
  statusUpdateForm.remark = ''
  statusUpdateDialogVisible.value = true
}

// 更新订单状态
const updateOrderStatus = async (orderId, status, remark = '') => {
  if (!confirm(`确定要将订单状态更新为"${getStatusText(status)}"吗？`)) {
    return
  }
  
  try {
    updating.value = true
    const response = await orderApi.updateOrderStatus(orderId, status)
    if (response.success) {
      showToast(response.message, 'success')
      getOrders() // 刷新列表
      detailDialogVisible.value = false
      statusUpdateDialogVisible.value = false
    } else {
      showToast(response.message, 'error')
    }
  } catch (error) {
    showToast('更新订单状态失败', 'error')
  } finally {
    updating.value = false
  }
}

// 确认状态更新
const confirmStatusUpdate = () => {
  if (!statusUpdateForm.status) {
    showToast('请选择新状态', 'warning')
    return
  }
  
  updateOrderStatus(
    selectedOrder.value.order_id,
    statusUpdateForm.status,
    statusUpdateForm.remark
  )
}

// 显示提示消息
const showToast = (message, type = 'info') => {
  const toast = document.createElement('div')
  toast.textContent = message
  toast.className = `toast toast-${type}`
  toast.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 12px 20px;
    border-radius: 8px;
    color: white;
    z-index: 10000;
    animation: slideInRight 0.3s ease;
    font-size: 14px;
    font-weight: 500;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  `
  
  const colors = {
    success: '#28a745',
    error: '#dc3545',
    warning: '#ffc107',
    info: '#17a2b8'
  }
  
  toast.style.background = colors[type] || colors.info
  document.body.appendChild(toast)
  
  setTimeout(() => {
    toast.remove()
  }, 3000)
}

// 组件挂载时获取数据
onMounted(() => {
  getOrders()
})
</script>

<style scoped>
.orders-manage-page {
  padding: 0;
  width: 100%;
  box-sizing: border-box;
  overflow-x: auto;
}

.section-header {
  margin-bottom: 2rem;
}

.section-header h2 {
  color: #333;
  margin: 0 0 5px 0;
  font-size: 1.5rem;
  font-weight: bold;
}

.section-description {
  margin: 0;
  color: #666;
  font-size: 0.9rem;
}

.search-filters-card {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(102, 126, 234, 0.1);
}

.filter-row {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  margin-bottom: 1rem;
  flex-wrap: wrap;
}

.filter-row:last-child {
  margin-bottom: 0;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.filter-group label {
  font-size: 0.9rem;
  color: #333;
  white-space: nowrap;
  font-weight: 500;
}

.filter-input,
.filter-select {
  padding: 0.5rem 0.75rem;
  border: 2px solid #e9ecef;
  border-radius: 6px;
  font-size: 0.85rem;
  transition: all 0.3s ease;
  min-width: 150px;
}

.filter-input:focus,
.filter-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.date-input {
  min-width: 130px;
}

.date-separator {
  color: #666;
  margin: 0 0.5rem;
}

.filter-actions {
  margin-left: auto;
  display: flex;
  gap: 0.75rem;
}

.btn-primary,
.btn-secondary,
.btn-danger,
.btn-warning,
.btn-success {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  font-size: 0.85rem;
  font-weight: 500;
  text-decoration: none;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: linear-gradient(135deg, #5a6fd8 0%, #6a4190 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-secondary:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-1px);
}

.btn-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  color: white;
}

.btn-success:hover:not(:disabled) {
  background: linear-gradient(135deg, #218838 0%, #1abc9c 100%);
  transform: translateY(-1px);
}

.btn-warning {
  background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
  color: #212529;
}

.btn-warning:hover:not(:disabled) {
  background: linear-gradient(135deg, #ffb300 0%, #f57c00 100%);
  transform: translateY(-1px);
}

.btn-danger {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background: linear-gradient(135deg, #ff5252 0%, #e53e3e 100%);
  transform: translateY(-1px);
}

.btn-primary:disabled,
.btn-secondary:disabled,
.btn-danger:disabled,
.btn-warning:disabled,
.btn-success:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
  border: 1px solid rgba(102, 126, 234, 0.1);
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 1.2rem;
}

.stat-icon.completed {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
}

.stat-icon.pending {
  background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
}

.stat-icon.revenue {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 1.5rem;
  font-weight: bold;
  color: #333;
  margin-bottom: 0.25rem;
}

.stat-label {
  font-size: 0.85rem;
  color: #666;
}

.orders-list {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(102, 126, 234, 0.1);
  overflow: hidden;
}

.loading-state,
.empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: #666;
}

.loading-spinner {
  font-size: 2rem;
  color: #667eea;
  margin-bottom: 1rem;
}

.empty-icon {
  font-size: 3rem;
  color: #ccc;
  margin-bottom: 1rem;
}

.empty-state h3 {
  margin-bottom: 0.5rem;
  color: #333;
}

.orders-grid {
  padding: 1.5rem;
  display: grid;
  gap: 1.5rem;
}

.order-card {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 8px;
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.order-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border-color: rgba(102, 126, 234, 0.3);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid #e9ecef;
}

.order-id {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: bold;
  color: #333;
}

.order-id i {
  color: #667eea;
}

.order-status {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: bold;
}

.status-completed {
  background: #d4edda;
  color: #155724;
}

.status-pending {
  background: #fff3cd;
  color: #856404;
}

.status-failed {
  background: #f8d7da;
  color: #721c24;
}

.status-refunded {
  background: #d1ecf1;
  color: #0c5460;
}

.order-info {
  margin-bottom: 1rem;
}

.info-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  color: #666;
}

.info-item i {
  width: 14px;
  color: #667eea;
}

.card-type {
  padding: 0.125rem 0.5rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: bold;
}

.card-type.time {
  background: #e3f2fd;
  color: #1976d2;
}

.card-type.count {
  background: #e8f5e8;
  color: #388e3c;
}

.card-spec {
  margin-left: 0.5rem;
  font-weight: 500;
}

.total-price {
  font-weight: bold;
  color: #ff6b6b;
}

.order-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.pagination {
  padding: 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 1px solid #e9ecef;
  flex-wrap: wrap;
  gap: 1rem;
}

.pagination-info {
  font-size: 0.85rem;
  color: #666;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.page-numbers {
  display: flex;
  gap: 0.25rem;
}

.page-btn {
  padding: 0.5rem 0.75rem;
  border: 1px solid #e9ecef;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.85rem;
  transition: all 0.3s ease;
}

.page-btn:hover {
  background: #f8f9fa;
  border-color: #667eea;
}

.page-btn.active {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.page-size-selector {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
}

.page-size-selector label {
  color: #666;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(5px);
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  max-height: 80vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  animation: modalSlideUp 0.3s ease-out;
}

@keyframes modalSlideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  padding: 1.5rem 1.5rem 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  color: #333;
  font-size: 1.2rem;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.2rem;
  color: #666;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 50%;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: #f8f9fa;
  color: #333;
}

.modal-body {
  padding: 1.5rem;
  max-height: 400px;
  overflow-y: auto;
}

.detail-section {
  margin-bottom: 1.5rem;
}

.detail-section h4 {
  margin: 0 0 1rem 0;
  color: #333;
  font-size: 1rem;
  border-bottom: 1px solid #e9ecef;
  padding-bottom: 0.5rem;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.detail-item {
  display: flex;
  align-items: center;
}

.detail-item label {
  font-weight: bold;
  color: #666;
  margin-right: 0.5rem;
  min-width: 80px;
  font-size: 0.85rem;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: bold;
}

.card-type-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: bold;
}

.card-type-badge.time {
  background: #dbeafe;
  color: #1e40af;
}

.card-type-badge.count {
  background: #dcfce7;
  color: #166534;
}

.total-price {
  font-weight: bold;
  color: #ef4444;
  font-size: 1rem;
}

.card-keys {
  max-height: 200px;
  overflow-y: auto;
}

.card-key-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 6px;
  margin-bottom: 0.5rem;
}

.key-index {
  font-weight: bold;
  color: #666;
  min-width: 20px;
}

.key-value {
  flex: 1;
  font-family: 'Courier New', monospace;
  background: white;
  padding: 0.5rem;
  border-radius: 4px;
  border: 1px solid #e9ecef;
  font-size: 0.8rem;
  word-break: break-all;
}

.copy-btn {
  background: #4f46e5;
  color: white;
  border: none;
  padding: 0.5rem 0.75rem;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.75rem;
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
}

.copy-btn:hover {
  background: #4338ca;
  transform: translateY(-1px);
}

.remark {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 6px;
  margin: 0;
  color: #666;
  font-size: 0.9rem;
  line-height: 1.5;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: bold;
  color: #333;
  font-size: 0.9rem;
}

.form-textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 0.9rem;
  transition: all 0.3s ease;
  box-sizing: border-box;
  resize: vertical;
  font-family: inherit;
}

.form-textarea:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  padding: 0 1.5rem 1.5rem;
}

@media (max-width: 768px) {
  .filter-row {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }
  
  .filter-actions {
    margin-left: 0;
    justify-content: center;
  }
  
  .stats-cards {
    grid-template-columns: 1fr;
  }
  
  .detail-grid {
    grid-template-columns: 1fr;
  }
  
  .pagination {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }
  
  .pagination-controls {
    order: -1;
    margin-bottom: 1rem;
  }
  
  .modal-content {
    margin: 1rem;
    width: calc(100% - 2rem);
  }
  
  .order-actions {
    justify-content: center;
  }
  
  .info-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
}

@keyframes slideInRight {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
</style>