<template>
  <div class="keys-manage-page">
    <div class="section-header">
      <h2>卡密管理</h2>
      <div class="header-actions">
        <button class="btn-secondary" @click="showExportModal = true">
          <i class="fas fa-file-export"></i>
          导出数据
        </button>
        <button class="btn-primary" @click="showCreateKeyModal = true">
          <i class="fas fa-plus"></i>
          生成卡密
        </button>
      </div>
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
            <td class="key-code" @click="copyKey(key.card_key)" title="点击复制">
              {{ key.card_key }}
            </td>
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

    <!-- 导出数据模态框 -->
    <div v-if="showExportModal" class="modal-overlay" @click="showExportModal = false">
      <div class="modal-content export-modal" @click.stop>
        <div class="modal-header">
          <h3>导出卡密数据</h3>
          <button class="close-btn" @click="showExportModal = false">×</button>
        </div>
        <div class="modal-body">
          <div class="export-settings">
            <div class="setting-group">
              <h4>选择导出列</h4>
              <div class="checkbox-grid">
                <label v-for="col in availableColumns" :key="col.key" class="checkbox-label">
                  <input type="checkbox" v-model="selectedColumns" :value="col.key">
                  {{ col.label }}
                </label>
              </div>
            </div>
            <div class="setting-group">
              <h4>导出格式</h4>
              <div class="radio-group">
                <label class="radio-label">
                  <input type="radio" v-model="exportFormat" value="xlsx"> Excel (.xlsx)
                </label>
                <label class="radio-label">
                  <input type="radio" v-model="exportFormat" value="csv"> CSV (.csv)
                </label>
              </div>
            </div>
          </div>
          
          <div class="preview-section">
            <h4>数据预览 (前5条)</h4>
            <div class="preview-table-container">
              <table class="preview-table">
                <thead>
                  <tr>
                    <th v-for="colKey in selectedColumns" :key="colKey">
                      {{ getColumnLabel(colKey) }}
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, index) in previewData" :key="index">
                    <td v-for="colKey in selectedColumns" :key="colKey">
                      {{ row[colKey] }}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-secondary" @click="showExportModal = false">取消</button>
          <button class="btn-primary" @click="exportData" :disabled="selectedColumns.length === 0 || exporting">
            <i class="fas" :class="exporting ? 'fa-spinner fa-spin' : 'fa-file-export'"></i>
            {{ exporting ? '导出中...' : '确认导出' }}
          </button>
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
import { ref, reactive, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import * as XLSX from 'xlsx'
import { cardApi } from '../services/api.js'

const props = defineProps({
  keys: Array
})

const emit = defineEmits(['create-keys', 'delete-key', 'update-key', 'toggle-key-status'])

const showCreateKeyModal = ref(false)
const showEditKeyModal = ref(false)
const showExportModal = ref(false)
const exporting = ref(false)
const exportFormat = ref('xlsx')
const selectedColumns = ref(['id', 'card_key', 'card_type', 'status', 'create_time'])

const availableColumns = [
  { key: 'id', label: '序号' },
  { key: 'card_key', label: '卡密' },
  { key: 'encrypted_key', label: '加密卡密' },
  { key: 'user_info', label: '使用者' },
  { key: 'remaining_time', label: '剩余时间' },
  { key: 'remaining_count', label: '剩余次数' },
  { key: 'expire_time', label: '过期时间' },
  { key: 'card_type', label: '卡密类型' },
  { key: 'is_exclusive', label: '是否专属' },
  { key: 'api_key_id', label: '专属API Key' }
]

const getColumnLabel = (key) => {
  const col = availableColumns.find(c => c.key === key)
  return col ? col.label : key
}

// 简单的前端混淆实现，与ApiManagePage保持一致
const obfuscateCardKey = (rawKey) => {
  if (!rawKey) return rawKey
  try {
    const encoded = encodeURIComponent(rawKey)
    const reversed = encoded.split('').reverse().join('')
    const base64 = btoa(reversed)
    return base64.replace(/e/g, '*').replace(/U/g, '-')
  } catch (e) {
    console.error('Obfuscation failed:', e)
    return rawKey
  }
}

const processExportData = (data) => {
  return data.map(item => {
    const processed = {}
    
    // 基础字段处理
    if (selectedColumns.value.includes('id')) processed.id = item.id
    if (selectedColumns.value.includes('card_key')) processed.card_key = item.card_key
    if (selectedColumns.value.includes('encrypted_key')) processed.encrypted_key = obfuscateCardKey(item.card_key)
    
    // 使用者信息 (优先显示设备ID或IP)
    if (selectedColumns.value.includes('user_info')) {
      processed.user_info = item.device_id ? `Device: ${item.device_id}` : (item.ip_address ? `IP: ${item.ip_address}` : '-')
    }
    
    // 剩余时间/次数
    if (selectedColumns.value.includes('remaining_time')) {
      processed.remaining_time = item.card_type === 'time' ? `${item.duration}天` : '-'
    }
    if (selectedColumns.value.includes('remaining_count')) {
      processed.remaining_count = item.card_type === 'count' ? `${item.remaining_count}/${item.total_count}` : '-'
    }
    
    // 时间字段
    if (selectedColumns.value.includes('expire_time')) processed.expire_time = formatDate(item.expire_time)
    if (selectedColumns.value.includes('create_time')) processed.create_time = formatDate(item.create_time) // Add create_time if needed, though not in user request list but useful
    
    // 类型和专属信息
    if (selectedColumns.value.includes('card_type')) processed.card_type = getCardTypeText(item.card_type)
    if (selectedColumns.value.includes('status')) processed.status = getStatusText(item.status) // Status also useful
    if (selectedColumns.value.includes('is_exclusive')) processed.is_exclusive = item.api_key_id ? '是' : '否'
    if (selectedColumns.value.includes('api_key_id')) processed.api_key_id = item.api_key_id || '-'
    
    return processed
  })
}

const previewData = computed(() => {
  if (!props.keys || props.keys.length === 0) return []
  return processExportData(props.keys.slice(0, 5))
})

const exportData = async () => {
  if (selectedColumns.value.length === 0) return
  
  exporting.value = true
  try {
    // 获取所有数据 (如果 props.keys 是分页后的，这里应该请求 API 获取所有，但目前 dashboard 似乎一次性加载了所有 keys)
    // 根据 Dashboard.vue 的 loadKeys 实现，cardApi.getAllCards() 获取了所有数据赋值给 keys
    // 所以 props.keys 应该是全量数据
    const allData = props.keys || []
    
    const dataToExport = processExportData(allData)
    
    // 创建工作簿
    const wb = XLSX.utils.book_new()
    
    // 转换表头为中文
    const header = selectedColumns.value.map(key => getColumnLabel(key))
    const body = dataToExport.map(row => selectedColumns.value.map(key => row[key]))
    
    const ws = XLSX.utils.aoa_to_sheet([header, ...body])
    XLSX.utils.book_append_sheet(wb, ws, "卡密数据")
    
    // 导出文件
    const fileName = `卡密导出_${new Date().toISOString().slice(0,10)}.${exportFormat.value}`
    XLSX.writeFile(wb, fileName)
    
    ElMessage.success('导出成功')
    showExportModal.value = false
  } catch (error) {
    console.error('Export failed:', error)
    ElMessage.error('导出失败')
  } finally {
    exporting.value = false
  }
}

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

const copyKey = async (cardKey) => {
  try {
    await navigator.clipboard.writeText(cardKey)
    ElMessage.success('卡密已复制到剪贴板')
  } catch (err) {
    console.error('Copy failed:', err)
    ElMessage.error('复制失败，请手动复制')
  }
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

.header-actions {
  display: flex;
  gap: 1rem;
}

.export-modal {
  max-width: 800px;
  width: 90%;
}

.export-settings {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 2rem;
  margin-bottom: 2rem;
}

.setting-group h4 {
  margin: 0 0 1rem 0;
  color: #2d3748;
  font-size: 1rem;
}

.checkbox-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 0.75rem;
}

.checkbox-label, .radio-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  color: #4a5568;
  font-size: 0.875rem;
}

.radio-group {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.preview-section {
  border-top: 1px solid #e2e8f0;
  padding-top: 1.5rem;
}

.preview-section h4 {
  margin: 0 0 1rem 0;
  color: #2d3748;
  font-size: 1rem;
}

.preview-table-container {
  overflow-x: auto;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
}

.preview-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
}

.preview-table th, .preview-table td {
  padding: 0.75rem;
  border-bottom: 1px solid #e2e8f0;
  text-align: left;
  white-space: nowrap;
}

.preview-table th {
  background: #f7fafc;
  font-weight: 600;
  color: #4a5568;
}

@media (max-width: 768px) {
  .export-settings {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
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
  cursor: pointer;
  transition: all 0.2s;
}

.key-code:hover {
  background: #e2e8f0;
  color: #2563eb;
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