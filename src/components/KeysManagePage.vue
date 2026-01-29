<template>
  <div class="keys-manage-page">
    <div class="section-header">
      <h2>卡密管理</h2>
      <button class="btn-primary" @click="showCreateKeyModal = true">
        <i class="fas fa-plus"></i>
        生成卡密
      </button>
    </div>
    
    <div class="keys-table">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>卡密</th>
            <th>类型</th>
            <th>状态</th>
            <th>创建时间</th>
            <th>持续时间/剩余次数</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="key in paginatedKeys" :key="key.id">
            <td>{{ key.id }}</td>
            <td class="key-code">{{ key.card_key }}</td>
            <td>
              <span class="card-type" :class="key.card_type">
                {{ getCardTypeText(key.card_type) }}
              </span>
            </td>
            <td>
              <span :class="['status', getStatusClass(key.status)]">
                {{ getStatusText(key.status) }}
              </span>
            </td>
            <td>{{ formatDate(key.create_time) }}</td>
            <td>{{ key.card_type === 'time' ? key.duration + '天' : key.remaining_count + '次' }}</td>
            <td>
              <div class="action-buttons">
                <button class="btn-secondary btn-sm" @click="copyKey(key.card_key)">
                  <i class="fas fa-copy"></i>
                  复制
                </button>
                <button class="btn-primary btn-sm" @click="editKey(key)">
                  <i class="fas fa-edit"></i>
                  编辑
                </button>
                <button 
                  v-if="key.status === 0 || key.status === 2" 
                  class="btn-success btn-sm" 
                  @click="toggleKeyStatus(key.id, 1)"
                >
                  <i class="fas fa-play"></i>
                  启用
                </button>
                <button 
                  v-if="key.status === 1" 
                  class="btn-warning btn-sm" 
                  @click="toggleKeyStatus(key.id, 2)"
                >
                  <i class="fas fa-pause"></i>
                  暂停
                </button>
                <button class="btn-danger btn-sm" @click="deleteKey(key.id)">
                  <i class="fas fa-trash"></i>
                  删除
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 分页组件 -->
    <div class="pagination-container" v-if="totalPages > 1">
      <div class="pagination">
        <!-- 上一页按钮 -->
        <button 
          class="pagination-btn" 
          :disabled="currentPage === 1" 
          @click="goToPage(currentPage - 1)"
        >
          ‹ 上一页
        </button>
        
        <!-- 页码按钮 -->
        <div class="page-numbers">
          <!-- 第一页 -->
          <button 
            v-if="showFirstPage" 
            class="page-btn" 
            :class="{ active: currentPage === 1 }" 
            @click="goToPage(1)"
          >
            1
          </button>
          
          <!-- 省略号 -->
          <span v-if="showStartEllipsis" class="ellipsis">...</span>
          
          <!-- 中间页码 -->
          <button 
            v-for="page in visiblePages" 
            :key="page" 
            class="page-btn" 
            :class="{ active: currentPage === page }" 
            @click="goToPage(page)"
          >
            {{ page }}
          </button>
          
          <!-- 省略号 -->
          <span v-if="showEndEllipsis" class="ellipsis">...</span>
          
          <!-- 最后一页 -->
          <button 
            v-if="showLastPage" 
            class="page-btn" 
            :class="{ active: currentPage === totalPages }" 
            @click="goToPage(totalPages)"
          >
            {{ totalPages }}
          </button>
        </div>
        
        <!-- 下一页按钮 -->
        <button 
          class="pagination-btn" 
          :disabled="currentPage === totalPages" 
          @click="goToPage(currentPage + 1)"
        >
          下一页 ›
        </button>
        
        <!-- 页码跳转 -->
        <div class="page-jump">
          <span>跳转到</span>
          <input 
            type="number" 
            v-model.number="jumpPage" 
            :min="1" 
            :max="totalPages" 
            @keyup.enter="jumpToPage"
            class="jump-input"
          />
          <span>页</span>
          <button class="jump-btn" @click="jumpToPage">跳转</button>
        </div>
        
        <!-- 分页信息 -->
        <div class="pagination-info">
          共 {{ totalItems }} 条记录，第 {{ currentPage }} / {{ totalPages }} 页
        </div>
      </div>
    </div>

    <!-- 编辑卡密模态框 -->
    <div v-if="showEditKeyModal" class="modal-overlay" @click="showEditKeyModal = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>编辑卡密</h3>
          <button class="close-btn" @click="showEditKeyModal = false">
            ×
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>卡密</label>
            <input type="text" :value="editingKey.card_key" readonly class="readonly-input" />
          </div>
          <div class="form-group">
            <label>卡密类型</label>
            <select v-model="editingKey.card_type">
              <option value="time">时间卡密</option>
              <option value="count">次数卡密</option>
            </select>
          </div>
          <div class="form-group">
            <label>持续时间（天）</label>
            <input type="number" v-model="editingKey.duration" min="1" max="365" />
          </div>
          <div class="form-group" v-if="editingKey.card_type === 'count'">
            <label>总次数</label>
            <input type="number" v-model="editingKey.total_count" min="1" max="10000" />
          </div>
          <div class="form-group" v-if="editingKey.card_type === 'count'">
            <label>剩余次数</label>
            <input type="number" v-model="editingKey.remaining_count" min="0" :max="editingKey.total_count" />
          </div>
          <div class="form-group">
            <label>状态</label>
            <select v-model="editingKey.status">
              <option value="0">未使用</option>
              <option value="1">已使用</option>
              <option value="2">已停用</option>
            </select>
          </div>
          <div class="form-group">
            <label>验证方式</label>
            <select v-model="editingKey.verify_method">
              <option value="web">Web验证</option>
              <option value="post">POST验证</option>
              <option value="get">GET验证</option>
            </select>
          </div>
          <div class="form-group">
            <label>加密类型</label>
            <select v-model="editingKey.encryption_type">
              <option value="sha1">SHA1</option>
              <option value="rc4">RC4</option>
            </select>
          </div>
          <div class="form-group">
            <label>允许重复验证</label>
            <select v-model="editingKey.allow_reverify">
              <option value="1">允许</option>
              <option value="0">不允许</option>
            </select>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-secondary" @click="showEditKeyModal = false">取消</button>
          <button class="btn-primary" @click="updateKey">
            <i class="fas fa-save"></i>
            保存
          </button>
        </div>
      </div>
    </div>

    <!-- 生成卡密模态框 -->
    <div v-if="showCreateKeyModal" class="modal-overlay" @click="showCreateKeyModal = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>生成卡密</h3>
          <button class="close-btn" @click="showCreateKeyModal = false">
            ×
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>卡密类型</label>
            <select v-model="newKey.card_type">
              <option value="time">时间卡密</option>
              <option value="count">次数卡密</option>
            </select>
          </div>
          <div class="form-group">
            <label>生成数量</label>
            <input type="number" v-model="newKey.count" min="1" max="100" />
          </div>
          <div class="form-group">
            <label>持续时间（天）</label>
            <input type="number" v-model="newKey.duration" min="1" max="365" />
          </div>
          <div class="form-group" v-if="newKey.card_type === 'count'">
            <label>总次数</label>
            <input type="number" v-model="newKey.total_count" min="1" max="10000" />
          </div>
          <div class="form-group">
            <label>验证方式</label>
            <select v-model="newKey.verify_method">
              <option value="web">Web验证</option>
              <option value="post">POST验证</option>
              <option value="get">GET验证</option>
            </select>
          </div>
          <div class="form-group">
            <label>加密类型</label>
            <select v-model="newKey.encryption_type">
              <option value="advanced">高级加密 (AES-256-GCM + ECC + Argon2id)</option>
            </select>
          </div>
          <div class="form-group">
            <label>允许重复验证</label>
            <select v-model="newKey.allow_reverify">
              <option value="1">允许</option>
              <option value="0">不允许</option>
            </select>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-secondary" @click="showCreateKeyModal = false">取消</button>
          <button class="btn-primary" @click="createKeys">
            <i class="fas fa-key"></i>
            生成
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'

const props = defineProps({
  keys: Array
})

const emit = defineEmits(['create-keys', 'delete-key', 'update-key', 'toggle-key-status'])

const showCreateKeyModal = ref(false)
const showEditKeyModal = ref(false)

// 分页相关状态
const currentPage = ref(1)
const pageSize = ref(10)
const jumpPage = ref(1)

const newKey = reactive({
  card_type: 'time',
  count: 1,
  duration: 30,
  total_count: 100,
  verify_method: 'web',
  encryption_type: 'advanced',
  allow_reverify: 1
})

const editingKey = reactive({
  id: null,
  card_key: '',
  card_type: 'time',
  duration: 30,
  total_count: 100,
  remaining_count: 100,
  status: 0,
  verify_method: 'web',
  encryption_type: 'sha1',
  allow_reverify: 1
})

// 计算属性
const totalItems = computed(() => props.keys?.length || 0)
const totalPages = computed(() => Math.ceil(totalItems.value / pageSize.value))

// 当前页显示的数据
const paginatedKeys = computed(() => {
  if (!props.keys) return []
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return props.keys.slice(start, end)
})

// 可见页码计算
const visiblePages = computed(() => {
  const pages = []
  const total = totalPages.value
  const current = currentPage.value
  
  if (total <= 7) {
    // 总页数小于等于7，显示所有页码
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // 总页数大于7，显示当前页前后各2页
    let start = Math.max(2, current - 2)
    let end = Math.min(total - 1, current + 2)
    
    // 调整范围确保显示5个页码
    if (end - start < 4) {
      if (start === 2) {
        end = Math.min(total - 1, start + 4)
      } else {
        start = Math.max(2, end - 4)
      }
    }
    
    for (let i = start; i <= end; i++) {
      pages.push(i)
    }
  }
  
  return pages
})

// 是否显示第一页
const showFirstPage = computed(() => {
  return totalPages.value > 7 && !visiblePages.value.includes(1)
})

// 是否显示最后一页
const showLastPage = computed(() => {
  return totalPages.value > 7 && !visiblePages.value.includes(totalPages.value)
})

// 是否显示开始省略号
const showStartEllipsis = computed(() => {
  return showFirstPage.value && visiblePages.value[0] > 2
})

// 是否显示结束省略号
const showEndEllipsis = computed(() => {
  return showLastPage.value && visiblePages.value[visiblePages.value.length - 1] < totalPages.value - 1
})

// 分页方法
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    jumpPage.value = page
  }
}

const jumpToPage = () => {
  if (jumpPage.value >= 1 && jumpPage.value <= totalPages.value) {
    currentPage.value = jumpPage.value
  } else {
    jumpPage.value = currentPage.value
  }
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleString('zh-CN')
}

const getCardTypeText = (cardType) => {
  const typeMap = {
    time: '时间卡密',
    count: '次数卡密'
  }
  return typeMap[cardType] || cardType
}

const getStatusText = (status) => {
  const statusMap = {
    0: '未使用',
    1: '已使用',
    2: '已停用'
  }
  return statusMap[status] || status
}

const getStatusClass = (status) => {
  const statusClassMap = {
    0: 'unused',
    1: 'used',
    2: 'disabled'
  }
  return statusClassMap[status] || 'unknown'
}

const createKeys = () => {
  emit('create-keys', { ...newKey })
  showCreateKeyModal.value = false
  // 重置表单
  newKey.card_type = 'time'
  newKey.count = 1
  newKey.duration = 30
  newKey.total_count = 100
  newKey.verify_method = 'web'
  newKey.encryption_type = 'advanced'
  newKey.allow_reverify = 1
}

const editKey = (key) => {
  // 复制卡密数据到编辑对象
  Object.assign(editingKey, {
    id: key.id,
    card_key: key.card_key,
    card_type: key.card_type,
    duration: key.duration,
    total_count: key.total_count || 100,
    remaining_count: key.remaining_count || key.total_count || 100,
    status: key.status,
    verify_method: key.verify_method || 'web',
    encryption_type: key.encryption_type || 'advanced',
    allow_reverify: key.allow_reverify !== undefined ? key.allow_reverify : 1
  })
  showEditKeyModal.value = true
}

const updateKey = () => {
  emit('update-key', { ...editingKey })
  showEditKeyModal.value = false
}

const toggleKeyStatus = (keyId, newStatus) => {
  emit('toggle-key-status', { id: keyId, status: newStatus })
}

const deleteKey = (keyId) => {
  if (confirm('确定要删除这个卡密吗？此操作不可恢复！')) {
    emit('delete-key', keyId)
  }
}

const copyKey = (cardKey) => {
  navigator.clipboard.writeText(cardKey).then(() => {
    alert('卡密已复制到剪贴板')
  }).catch(() => {
    alert('复制失败，请手动复制')
  })
}
</script>

<style scoped>
.keys-manage-page {
  padding: 0;
  width: 100%;
  box-sizing: border-box;
  overflow-x: auto;
  background: #fafbfc;
  min-height: 100vh;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  padding: 2rem;
  background: white;
  border-bottom: 1px solid #e1e5e9;
}

.section-header h2 {
  color: #2d3748;
  margin: 0;
  font-size: 1.75rem;
  font-weight: 600;
}

.btn-primary,
.btn-secondary,
.btn-danger,
.btn-success,
.btn-warning {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.2s ease;
  font-size: 0.875rem;
  font-weight: 500;
  text-decoration: none;
}

.btn-sm {
  padding: 0.375rem 0.5rem;
  font-size: 0.75rem;
  border-radius: 4px;
  min-width: auto;
}

.btn-primary {
  background: #4f46e5;
  color: white;
}

.btn-primary:hover {
  background: #4338ca;
  transform: translateY(-1px);
}

.btn-secondary {
  background: #6b7280;
  color: white;
}

.btn-secondary:hover {
  background: #4b5563;
}

.btn-danger {
  background: #ef4444;
  color: white;
}

.btn-danger:hover {
  background: #dc2626;
}

.btn-success {
  background: #10b981;
  color: white;
}

.btn-success:hover {
  background: #059669;
}

.btn-warning {
  background: #f59e0b;
  color: white;
}

.btn-warning:hover {
  background: #d97706;
}

.keys-table {
  overflow-x: hidden;
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  margin: 0 2rem 2rem;
  border: 1px solid #e1e5e9;
}

.keys-table table {
  width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
}

.keys-table th:nth-child(1) { width: 6%; }   /* ID */
.keys-table th:nth-child(2) { width: 28%; }  /* 卡密 */
.keys-table th:nth-child(3) { width: 10%; }  /* 类型 */
.keys-table th:nth-child(4) { width: 10%; }  /* 状态 */
.keys-table th:nth-child(5) { width: 16%; }  /* 创建时间 */
.keys-table th:nth-child(6) { width: 8%; }   /* 持续时间 */
.keys-table th:nth-child(7) { width: 22%; }  /* 操作 */

.keys-table th,
.keys-table td {
  padding: 0.5rem 0.75rem;
  text-align: left;
  border-bottom: 1px solid #f1f5f9;
  vertical-align: middle;
}

.keys-table th {
  background: #f8fafc;
  font-weight: 600;
  color: #475569;
  font-size: 0.875rem;
}

.keys-table tbody tr {
  transition: background-color 0.2s ease;
}

.keys-table tbody tr:hover {
  background: #f8fafc;
}

.key-code {
  font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', monospace;
  background: #f1f5f9;
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 500;
  color: #475569;
  white-space: nowrap;
  text-overflow: ellipsis;
  max-width: 100%;
  display: block;
  overflow: hidden;
}

.card-type {
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 500;
  display: inline-block;
}

.card-type.time {
  background: #dbeafe;
  color: #1e40af;
}

.card-type.count {
  background: #fce7f3;
  color: #be185d;
}

.status {
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 500;
  display: inline-block;
}

.status.unused {
  background: #dcfce7;
  color: #166534;
}

.status.used {
  background: #e0f2fe;
  color: #0c4a6e;
}

.status.disabled {
  background: #fef2f2;
  color: #991b1b;
}

.status.expired {
  background: #fef2f2;
  color: #991b1b;
}

.action-buttons {
  display: flex;
  gap: 0.25rem;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
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
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.modal-header {
  padding: 1.5rem 1.5rem 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  color: #2d3748;
  font-size: 1.25rem;
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.25rem;
  color: #6b7280;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 6px;
  transition: all 0.2s ease;
}

.close-btn:hover {
  background: #f3f4f6;
  color: #374151;
}

.modal-body {
  padding: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #374151;
  font-size: 0.875rem;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 0.875rem;
  transition: border-color 0.2s ease;
  box-sizing: border-box;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.readonly-input {
  background: #f9fafb !important;
  color: #6b7280 !important;
  cursor: not-allowed !important;
}

.modal-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
  padding: 0 1.5rem 1.5rem;
}

/* 分页样式 */
.pagination-container {
  padding: 1.5rem 2rem;
  background: white;
  border-top: 1px solid #e1e5e9;
}

.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.pagination-btn {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  background: white;
  color: #374151;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.pagination-btn:hover:not(:disabled) {
  background: #f3f4f6;
  border-color: #9ca3af;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background: #f9fafb;
}

.page-numbers {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.page-btn {
  width: 2.5rem;
  height: 2.5rem;
  border: 1px solid #d1d5db;
  background: white;
  color: #374151;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.page-btn:hover {
  background: #f3f4f6;
  border-color: #9ca3af;
}

.page-btn.active {
  background: #4f46e5;
  border-color: #4f46e5;
  color: white;
}

.ellipsis {
  padding: 0 0.5rem;
  color: #6b7280;
  font-size: 0.875rem;
}

.page-jump {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #374151;
}

.jump-input {
  width: 4rem;
  padding: 0.375rem 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 0.875rem;
  text-align: center;
}

.jump-input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.1);
}

.jump-btn {
  padding: 0.375rem 0.75rem;
  background: #4f46e5;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
  transition: background-color 0.2s ease;
}

.jump-btn:hover {
  background: #4338ca;
}

.pagination-info {
  font-size: 0.875rem;
  color: #6b7280;
  white-space: nowrap;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .keys-table {
    margin: 0 1rem 2rem;
  }
  
  .section-header {
    padding: 1.5rem 1rem;
  }

  .pagination-container {
    padding: 1.5rem 1rem;
  }
}

@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
    padding: 1rem;
  }

  .section-header h2 {
    font-size: 1.5rem;
    text-align: center;
  }

  .keys-table {
    font-size: 0.875rem;
    margin: 0 0.5rem 1rem;
    border-radius: 8px;
  }

  .keys-table th,
  .keys-table td {
    padding: 0.75rem 0.5rem;
  }

  .action-buttons {
    flex-direction: column;
    gap: 0.25rem;
  }

  .modal-content {
    margin: 1rem;
    width: calc(100% - 2rem);
    border-radius: 8px;
  }

  .modal-header,
  .modal-body,
  .modal-actions {
    padding: 1rem;
  }

  .btn-primary,
  .btn-secondary,
  .btn-danger {
    padding: 0.75rem 1rem;
    font-size: 0.875rem;
  }

  .pagination-container {
    padding: 1rem 0.5rem;
  }

  .pagination {
    flex-direction: column;
    gap: 0.75rem;
  }

  .page-numbers {
    order: 1;
  }

  .pagination-btn {
    order: 2;
    padding: 0.5rem 0.75rem;
    font-size: 0.8rem;
  }

  .page-jump {
    order: 3;
    font-size: 0.8rem;
  }

  .pagination-info {
    order: 4;
    text-align: center;
    font-size: 0.8rem;
  }
}

@media (max-width: 480px) {
  .keys-manage-page {
    border-radius: 0;
  }
  
  .section-header {
    border-radius: 0;
  }
  
  .keys-table {
    border-radius: 0;
    margin: 0 0 1rem;
  }
  
  .modal-content {
    border-radius: 0;
    margin: 0;
    width: 100%;
    height: 100%;
  }

  .pagination-container {
    padding: 0.75rem 0.25rem;
    border-radius: 0;
  }

  .page-btn {
    width: 2rem;
    height: 2rem;
    font-size: 0.75rem;
  }

  .jump-input {
    width: 3rem;
  }
}
</style>