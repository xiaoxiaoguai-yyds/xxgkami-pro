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

    <div class="keys-toolbar">
      <div class="toolbar-search">
        <label class="toolbar-label" for="machine-code-search">机器码搜索</label>
        <input
          id="machine-code-search"
          v-model.trim="machineCodeSearch"
          type="search"
          class="toolbar-input"
          placeholder="输入设备码关键字，筛选已绑定该机器码的卡密"
          autocomplete="off"
          spellcheck="false"
        />
        <button v-if="machineCodeSearch" type="button" class="toolbar-clear" @click="machineCodeSearch = ''">
          清除
        </button>
      </div>
      <p class="toolbar-meta">
        当前列表：<strong>{{ filteredKeys.length }}</strong> 条
        <template v-if="machineCodeSearch">（已按机器码过滤）</template>
        <span class="toolbar-divider">|</span>
        全库共计 {{ props.keys?.length || 0 }} 条
      </p>
    </div>

    <div class="keys-table">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>卡密</th>
            <th>类型</th>
            <th>状态</th>
            <th>机器码</th>
            <th>创建时间</th>
            <th>剩余时间/剩余次数</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="filteredKeys.length === 0">
            <td colspan="8" class="empty-table-hint">
              {{ machineCodeSearch ? '没有绑定该机器码的卡密（可尝试缩短关键字或清除筛选）' : '暂无卡密数据' }}
            </td>
          </tr>
          <template v-else>
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
            <td class="machine-code-cell" :title="key.machine_code || ''">
              <span v-if="key.machine_code" class="machine-code-tag">{{ key.machine_code }}</span>
              <span v-else class="machine-code-empty">未绑定</span>
            </td>
            <td>{{ formatDate(key.create_time) }}</td>
            <td class="duration-cell">
              <template v-if="key.card_type === 'time'">
                <span
                  v-if="key.expire_time"
                  :class="['time-countdown', { 'is-expired': isTimeCardExpired(key) }]"
                >
                  {{ formatTimeCardRemaining(key) }}
                </span>
                <span v-else class="time-spec">{{ (key.duration ?? 0) }} 天（未激活）</span>
              </template>
              <template v-else>{{ key.remaining_count }} 次</template>
            </td>
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
          </template>
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
          <div class="setting-group export-scope-group">
            <h4>导出范围</h4>
            <p class="export-scope-hint">会先应用上方「机器码搜索」的结果，再按使用状态筛选；选「全部」则仅受机器码搜索影响。</p>
            <div class="radio-group horizontal">
              <label class="radio-label">
                <input type="radio" v-model="exportUsageScope" value="all"> 全部（未按状态筛选）
              </label>
              <label class="radio-label">
                <input type="radio" v-model="exportUsageScope" value="unused"> 仅未使用
              </label>
              <label class="radio-label">
                <input type="radio" v-model="exportUsageScope" value="used"> 仅已使用（含已暂停）
              </label>
            </div>
          </div>
          
          <div class="preview-section">
            <h4>数据预览 (前 5 条，共符合条件 {{ keysForExport.length }} 条)</h4>
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
          <div class="form-group" v-if="editingKey.card_type === 'time'">
            <label>允许重复验证</label>
            <select v-model="editingKey.allow_reverify">
              <option value="1">允许</option>
              <option value="0">不允许</option>
            </select>
            <small class="form-hint" v-if="editingKey.allow_reverify == 0">关闭后，时间卡密激活一次即不可再次验证</small>
            <small class="form-hint" v-else>开启后，时间卡密在有效期内可无限次验证</small>
          </div>
          <div class="form-group stack-time-stack-group">
            <div
              class="stack-option-card"
              :class="{ 'stack-option-card--active': editingKey.allow_self_unbind }"
            >
              <label class="stack-toggle-row">
                <span class="stack-switch">
                  <input
                    type="checkbox"
                    v-model="editingKey.allow_self_unbind"
                    class="stack-switch-input"
                  />
                  <span class="stack-switch-track">
                    <span class="stack-switch-thumb"></span>
                  </span>
                </span>
                <span class="stack-toggle-copy">
                  <span class="stack-toggle-title">
                    允许自助解绑
                    <span v-if="editingKey.allow_self_unbind" class="stack-toggle-pill">已开启</span>
                  </span>
                  <span class="stack-toggle-desc">
                    开启后，用户可凭卡密在首页「在线解绑」自行清空机器码；关闭则只能通过管理员重置。
                  </span>
                </span>
              </label>
            </div>
          </div>
          <div class="form-group">
            <label>机器码</label>
            <div class="machine-code-edit">
              <input
                type="text"
                :value="editingKey.machine_code || ''"
                readonly
                class="readonly-input"
                :placeholder="editingKey.machine_code ? '' : '未绑定'"
              />
              <button
                v-if="editingKey.machine_code"
                class="btn-danger btn-sm"
                @click="editingKey.machine_code = ''"
                title="重置机器码"
              >
                <i class="fas fa-undo"></i> 重置
              </button>
              <span v-else class="machine-code-hint">未绑定，无需重置</span>
            </div>
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
          <div class="form-group" v-if="newKey.card_type === 'time'">
            <label>允许重复验证</label>
            <select v-model="newKey.allow_reverify">
              <option value="1">允许</option>
              <option value="0">不允许</option>
            </select>
            <small class="form-hint" v-if="newKey.allow_reverify == 0">关闭后，时间卡密激活一次即不可再次验证</small>
            <small class="form-hint" v-else>开启后，时间卡密在有效期内可无限次验证</small>
          </div>
          <div class="form-group stack-time-stack-group" v-if="newKey.card_type === 'time'">
            <div
              class="stack-option-card"
              :class="{ 'stack-option-card--active': newKey.stack_time_if_same_machine }"
            >
              <label class="stack-toggle-row">
                <span class="stack-switch">
                  <input
                    type="checkbox"
                    v-model="newKey.stack_time_if_same_machine"
                    class="stack-switch-input"
                  />
                  <span class="stack-switch-track">
                    <span class="stack-switch-thumb"></span>
                  </span>
                </span>
                <span class="stack-toggle-copy">
                  <span class="stack-toggle-title">
                    同机时长叠加（续期）
                    <span v-if="newKey.stack_time_if_same_machine" class="stack-toggle-pill">已开启</span>
                  </span>
                  <span class="stack-toggle-desc">
                    同一机器码上若已有未过期时间卡，激活本卡时将天数累加到原卡到期时间（本卡标记为「已合并」）；关闭则每次仍从激活时刻重新起算。
                  </span>
                </span>
              </label>
            </div>
          </div>
          <div class="form-group stack-time-stack-group">
            <div
              class="stack-option-card"
              :class="{ 'stack-option-card--active': newKey.allow_self_unbind }"
            >
              <label class="stack-toggle-row">
                <span class="stack-switch">
                  <input
                    type="checkbox"
                    v-model="newKey.allow_self_unbind"
                    class="stack-switch-input"
                  />
                  <span class="stack-switch-track">
                    <span class="stack-switch-thumb"></span>
                  </span>
                </span>
                <span class="stack-toggle-copy">
                  <span class="stack-toggle-title">
                    允许自助解绑
                    <span v-if="newKey.allow_self_unbind" class="stack-toggle-pill">已开启</span>
                  </span>
                  <span class="stack-toggle-desc">
                    开启后，用户可凭卡密在首页「在线解绑」自行清空机器码；关闭则只能通过管理员重置。
                  </span>
                </span>
              </label>
            </div>
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
import { ref, reactive, computed, watch, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import * as XLSX from 'xlsx'
import { cardApi } from '../services/api.js'
import { copyToClipboard } from '../utils/clipboard.js'

const props = defineProps({
  keys: Array
})

const emit = defineEmits(['create-keys', 'delete-key', 'update-key', 'toggle-key-status'])

/** 每秒刷新，驱动时间卡密倒计时 */
const nowMs = ref(Date.now())
let countdownTimer = null

onMounted(() => {
  countdownTimer = setInterval(() => {
    nowMs.value = Date.now()
  }, 1000)
})

onUnmounted(() => {
  if (countdownTimer) {
    clearInterval(countdownTimer)
    countdownTimer = null
  }
})

const pad2 = (n) => String(n).padStart(2, '0')

const parseExpireTimeMs = (key) => {
  const raw = key?.expire_time
  if (raw == null || raw === '') return null
  const t = new Date(raw).getTime()
  return Number.isFinite(t) ? t : null
}

const isTimeCardExpired = (key) => {
  const end = parseExpireTimeMs(key)
  return end != null && end <= nowMs.value
}

const formatTimeCardRemaining = (key) => {
  const end = parseExpireTimeMs(key)
  if (end == null) return '—'
  const ms = end - nowMs.value
  if (ms <= 0) return '已过期'
  const totalSec = Math.floor(ms / 1000)
  const days = Math.floor(totalSec / 86400)
  const h = Math.floor((totalSec % 86400) / 3600)
  const m = Math.floor((totalSec % 3600) / 60)
  const s = totalSec % 60
  if (days > 0) {
    return `${days} 天 ${pad2(h)}:${pad2(m)}:${pad2(s)}`
  }
  return `${pad2(h)}:${pad2(m)}:${pad2(s)}`
}

const showCreateKeyModal = ref(false)
const showEditKeyModal = ref(false)
const showExportModal = ref(false)
const exporting = ref(false)
const exportFormat = ref('xlsx')
/** all | unused | used — 导出时筛选未使用 / 已使用（含暂停） */
const exportUsageScope = ref('all')
/** 列表与导出预览均先按机器码关键字过滤（不区分大小写） */
const machineCodeSearch = ref('')
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
  { key: 'machine_code', label: '机器码' },
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
      if (item.card_type === 'time') {
        if (item.expire_time) {
          const ms = new Date(item.expire_time).getTime() - Date.now()
          if (ms <= 0) {
            processed.remaining_time = '已过期'
          } else {
            const d = Math.floor(ms / 86400000)
            const h = Math.floor((ms % 86400000) / 3600000)
            const m = Math.floor((ms % 3600000) / 60000)
            processed.remaining_time = d > 0 ? `${d}天${h}小时${m}分钟` : `${h}小时${m}分钟`
          }
        } else {
          processed.remaining_time = `${item.duration}天（未激活）`
        }
      } else {
        processed.remaining_time = '-'
      }
    }
    if (selectedColumns.value.includes('remaining_count')) {
      processed.remaining_count = item.card_type === 'count' ? `${item.remaining_count}/${item.total_count}` : '-'
    }

    // 时间字段
    if (selectedColumns.value.includes('expire_time')) {
      processed.expire_time = item.expire_time ? formatDate(item.expire_time) : (item.card_type === 'time' ? '未激活' : '-')
    }
    if (selectedColumns.value.includes('create_time')) processed.create_time = formatDate(item.create_time) // Add create_time if needed, though not in user request list but useful
    
    // 类型和专属信息
    if (selectedColumns.value.includes('card_type')) processed.card_type = getCardTypeText(item.card_type)
    if (selectedColumns.value.includes('status')) processed.status = getStatusText(item.status) // Status also useful
    if (selectedColumns.value.includes('machine_code')) processed.machine_code = item.machine_code || '-'
    if (selectedColumns.value.includes('is_exclusive')) processed.is_exclusive = item.api_key_id ? '是' : '否'
    if (selectedColumns.value.includes('api_key_id')) processed.api_key_id = item.api_key_id || '-'
    
    return processed
  })
}

const filteredKeys = computed(() => {
  const list = props.keys || []
  const q = (machineCodeSearch.value || '').trim().toLowerCase()
  if (!q) return list
  return list.filter((k) => {
    const mc = (k.machine_code ?? '').toString().toLowerCase()
    return mc.includes(q)
  })
})

const keysForExport = computed(() => {
  let keys = filteredKeys.value
  if (exportUsageScope.value === 'unused') {
    keys = keys.filter((k) => Number(k.status) === 0)
  } else if (exportUsageScope.value === 'used') {
    keys = keys.filter((k) => [1, 2, 4].includes(Number(k.status)))
  }
  return keys
})

const previewData = computed(() => {
  const src = keysForExport.value
  if (!src.length) return []
  return processExportData(src.slice(0, 5))
})

const exportData = async () => {
  if (selectedColumns.value.length === 0) return

  const allData = keysForExport.value
  if (allData.length === 0) {
    ElMessage.warning('当前筛选条件下没有可导出的数据')
    return
  }

  exporting.value = true
  try {
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

watch(machineCodeSearch, () => {
  currentPage.value = 1
  jumpPage.value = 1
})

const newKey = reactive({
  card_type: 'time',
  count: 1,
  duration: 30,
  total_count: 100,
  verify_method: 'web',
  encryption_type: 'advanced',
  allow_reverify: 1,
  stack_time_if_same_machine: false,
  allow_self_unbind: false
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
  allow_reverify: 1,
  machine_code: '',
  allow_self_unbind: false
})

// 计算属性
const totalItems = computed(() => filteredKeys.value?.length ?? 0)
const totalPages = computed(() => Math.max(1, Math.ceil(totalItems.value / pageSize.value)))

// 当前页显示的数据
const paginatedKeys = computed(() => {
  const list = filteredKeys.value || []
  if (!list.length) return []
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return list.slice(start, end)
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
    2: '已暂停',
    4: '已合并(续期)'
  }
  return statusMap[status] || status
}

const getStatusClass = (status) => {
  const statusClassMap = {
    0: 'unused',
    1: 'used',
    2: 'disabled',
    4: 'used'
  }
  return statusClassMap[status] || 'unknown'
}

const createKeys = () => {
  // Deep copy and clean data
  const keyData = { ...newKey }
  if (keyData.card_type === 'time') {
    keyData.total_count = 0
  }
  
  emit('create-keys', keyData)
  showCreateKeyModal.value = false
  // 重置表单
  newKey.card_type = 'time'
  newKey.count = 1
  newKey.duration = 30
  newKey.total_count = 100
  newKey.verify_method = 'web'
  newKey.encryption_type = 'advanced'
  newKey.allow_reverify = 1
  newKey.stack_time_if_same_machine = false
  newKey.allow_self_unbind = false
}

const editKey = (key) => {
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
    allow_reverify: key.allow_reverify !== undefined ? key.allow_reverify : 1,
    machine_code: key.machine_code || '',
    allow_self_unbind: key.allow_self_unbind === true || key.allow_self_unbind === 1
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
  const success = await copyToClipboard(cardKey)
  if (success) {
    ElMessage.success('卡密已复制到剪贴板')
  } else {
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
  margin-bottom: 0;
  padding: 2rem;
  background: white;
  border-bottom: 1px solid #e1e5e9;
}

.keys-toolbar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 1rem 1.5rem;
  padding: 1rem 2rem 1.25rem;
  background: white;
  border-bottom: 1px solid #e1e5e9;
}

.toolbar-search {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.5rem 0.75rem;
  flex: 1;
  min-width: 220px;
}

.toolbar-label {
  font-size: 0.875rem;
  font-weight: 600;
  color: #4a5568;
  white-space: nowrap;
}

.toolbar-input {
  flex: 1;
  min-width: 200px;
  max-width: 480px;
  padding: 0.5rem 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 0.875rem;
}

.toolbar-input:focus {
  outline: none;
  border-color: #3182ce;
  box-shadow: 0 0 0 3px rgba(49, 130, 206, 0.15);
}

.toolbar-clear {
  background: none;
  border: none;
  color: #718096;
  font-size: 0.8125rem;
  cursor: pointer;
  padding: 0.25rem 0.5rem;
}

.toolbar-clear:hover {
  color: #2d3748;
  text-decoration: underline;
}

.toolbar-meta {
  margin: 0;
  font-size: 0.8125rem;
  color: #718096;
}

.toolbar-divider {
  margin: 0 0.35rem;
  opacity: 0.5;
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

.radio-group.horizontal {
  flex-direction: row;
  flex-wrap: wrap;
  align-items: flex-start;
  gap: 0.75rem 1.25rem;
}

.export-scope-group {
  margin-bottom: 1rem;
}

.export-scope-hint {
  margin: 0 0 0.75rem 0;
  font-size: 0.8125rem;
  color: #718096;
  line-height: 1.5;
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
  margin: 1rem 2rem 2rem;
  border: 1px solid #e1e5e9;
}

.keys-table table {
  width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
}

.empty-table-hint {
  text-align: center;
  padding: 2.5rem 1rem !important;
  color: #718096;
  font-size: 0.9rem;
}

.keys-table th:nth-child(1) { width: 4%; }   /* ID */
.keys-table th:nth-child(2) { width: 20%; }  /* 卡密 */
.keys-table th:nth-child(3) { width: 7%; }   /* 类型 */
.keys-table th:nth-child(4) { width: 7%; }   /* 状态 */
.keys-table th:nth-child(5) { width: 10%; }  /* 机器码 */
.keys-table th:nth-child(6) { width: 13%; }  /* 创建时间 */
.keys-table th:nth-child(7) { width: 17%; }  /* 剩余时间/次数（倒计时） */
.keys-table th:nth-child(8) { width: 22%; }  /* 操作 */

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

.machine-code-cell {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.machine-code-tag {
  font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', monospace;
  font-size: 0.75rem;
  background: #f0fdf4;
  color: #15803d;
  padding: 0.15rem 0.5rem;
  border-radius: 4px;
  border: 1px solid #bbf7d0;
}

.machine-code-empty {
  font-size: 0.75rem;
  color: #a1a1aa;
}

.machine-code-edit {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.machine-code-edit .readonly-input {
  flex: 1;
}

.machine-code-hint {
  font-size: 0.8rem;
  color: #a1a1aa;
  white-space: nowrap;
}

.form-hint {
  display: block;
  margin-top: 0.35rem;
  font-size: 0.8rem;
  color: #6b7280;
}

/* 生成卡密：同机时长叠加 — 卡片 + iOS 风格开关 */
.stack-time-stack-group {
  margin-bottom: 1.5rem;
}

.stack-option-card {
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 1rem 1.125rem;
  background: #fff;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  transition:
    border-color 0.2s ease,
    box-shadow 0.2s ease,
    background 0.2s ease;
}

.stack-option-card--active {
  border-color: #c7d2fe;
  background: linear-gradient(165deg, #f8faff 0%, #ffffff 55%);
  box-shadow:
    0 0 0 1px rgba(79, 70, 229, 0.07),
    0 6px 20px rgba(79, 70, 229, 0.08);
}

.stack-toggle-row {
  display: flex !important;
  align-items: flex-start;
  gap: 0.875rem;
  margin: 0 !important;
  cursor: pointer;
  font-weight: normal !important;
  color: inherit !important;
}

.stack-switch {
  position: relative;
  width: 48px;
  height: 28px;
  flex-shrink: 0;
  margin-top: 2px;
}

.stack-switch-input {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  margin: 0;
  opacity: 0;
  z-index: 2;
  cursor: pointer;
}

.stack-switch-track {
  position: absolute;
  inset: 0;
  border-radius: 999px;
  background: #d1d5db;
  transition: background 0.22s ease;
}

.stack-switch-thumb {
  position: absolute;
  top: 3px;
  left: 3px;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: #fff;
  box-shadow: 0 1px 3px rgba(15, 23, 42, 0.18);
  transition: transform 0.22s cubic-bezier(0.34, 1.1, 0.64, 1);
  pointer-events: none;
}

.stack-switch-input:checked + .stack-switch-track {
  background: #4f46e5;
}

.stack-switch-input:checked + .stack-switch-track .stack-switch-thumb {
  transform: translateX(20px);
}

.stack-switch-input:focus-visible + .stack-switch-track {
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.28);
}

.stack-toggle-copy {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  min-width: 0;
}

.stack-toggle-title {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9375rem;
  font-weight: 600;
  color: #111827;
  line-height: 1.35;
}

.stack-toggle-pill {
  display: inline-flex;
  align-items: center;
  padding: 0.125rem 0.5rem;
  border-radius: 999px;
  font-size: 0.6875rem;
  font-weight: 600;
  letter-spacing: 0.02em;
  color: #4338ca;
  background: #e0e7ff;
}

.stack-toggle-desc {
  font-size: 0.8125rem;
  line-height: 1.5;
  color: #6b7280;
  font-weight: 400;
}

.duration-cell {
  font-size: 0.8125rem;
  line-height: 1.45;
  word-break: break-word;
}

.time-countdown {
  font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', monospace;
  font-variant-numeric: tabular-nums;
  color: #0369a1;
  font-weight: 600;
  letter-spacing: 0.02em;
}

.time-countdown.is-expired {
  color: #b91c1c;
}

.time-spec {
  color: #64748b;
  font-size: 0.8125rem;
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