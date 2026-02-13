<template>
  <div class="user-manage-page">
    <div class="section-header">
      <h2>用户管理</h2>
      <div class="header-actions">
        <div class="search-box">
          <input 
            type="text" 
            v-model="searchKeyword" 
            placeholder="搜索用户名/邮箱/昵称"
            @keyup.enter="handleSearch"
          >
          <button class="btn-secondary" @click="handleSearch">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          </button>
        </div>
        <button class="btn-primary" @click="openCreateModal">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
          新建用户
        </button>
      </div>
    </div>
    
    <div class="user-list">
      <div class="user-card" v-for="user in users" :key="user.id">
        <div class="user-info">
          <div class="user-header">
            <h3>{{ user.username }}</h3>
            <span :class="['user-status', user.status === 1 ? 'active' : 'inactive']">
              {{ user.status === 1 ? '正常' : '禁用' }}
            </span>
          </div>
          
          <div class="user-meta">
            <div class="meta-item">
              <span class="label">ID:</span>
              <span class="value">{{ user.id }}</span>
            </div>
            <div class="meta-item">
              <span class="label">昵称:</span>
              <span class="value">{{ user.nickname || '-' }}</span>
            </div>
            <div class="meta-item">
              <span class="label">邮箱:</span>
              <span class="value">{{ user.email }}</span>
            </div>
            <div class="meta-item">
              <span class="label">手机号:</span>
              <span class="value">{{ user.phone || '-' }}</span>
            </div>
            <div class="meta-item">
              <span class="label">创建时间:</span>
              <span class="value">{{ formatDate(user.createTime) }}</span>
            </div>
          </div>
        </div>
        
        <div class="user-actions">
          <button class="btn-secondary" @click="openEditModal(user)">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
            编辑
          </button>
          
          <button 
            v-if="user.status === 0" 
            class="btn-success" 
            @click="toggleUserStatus(user.id, 1)"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14"><polyline points="20 6 9 17 4 12"></polyline></svg>
            启用
          </button>
          
          <button 
            v-if="user.status === 1" 
            class="btn-warning" 
            @click="toggleUserStatus(user.id, 0)"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
            禁用
          </button>
          
          <button class="btn-danger" @click="handleDeleteUser(user.id)">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
            删除
          </button>
        </div>
      </div>
      
      <div v-if="users.length === 0 && !loading" class="empty-state">
        <div class="empty-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" width="48" height="48"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        </div>
        <h3>暂无用户数据</h3>
        <p>点击上方按钮创建新用户</p>
      </div>
    </div>

    <!-- 分页组件 -->
    <div class="pagination-container" v-if="totalPages > 1">
      <div class="pagination">
        <button 
          class="pagination-btn" 
          :disabled="currentPage === 1" 
          @click="goToPage(currentPage - 1)"
        >
          ‹ 上一页
        </button>
        
        <div class="page-numbers">
          <button 
            v-for="page in visiblePages" 
            :key="page"
            class="page-btn" 
            :class="{ active: currentPage === page }" 
            @click="goToPage(page)"
          >
            {{ page }}
          </button>
        </div>

        <button 
          class="pagination-btn" 
          :disabled="currentPage === totalPages" 
          @click="goToPage(currentPage + 1)"
        >
          下一页 ›
        </button>
      </div>
    </div>

    <!-- 创建/编辑用户模态框 -->
    <div class="modal-overlay" v-if="showModal" @click.self="closeModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ isEditing ? '编辑用户' : '新建用户' }}</h3>
          <button class="close-btn" @click="closeModal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>用户名 <span class="required" v-if="!isEditing">*</span></label>
            <input type="text" v-model="form.username" :disabled="isEditing" placeholder="请输入用户名">
          </div>
          <div class="form-group">
            <label>密码 <span class="required" v-if="!isEditing">*</span></label>
            <input type="password" v-model="form.password" :placeholder="isEditing ? '留空则不修改密码' : '请输入密码'">
          </div>
          <div class="form-group">
            <label>昵称</label>
            <input type="text" v-model="form.nickname" placeholder="请输入昵称">
          </div>
          <div class="form-group">
            <label>邮箱 <span class="required">*</span></label>
            <input type="email" v-model="form.email" placeholder="请输入邮箱">
          </div>
          <div class="form-group">
            <label>手机号</label>
            <input type="text" v-model="form.phone" placeholder="请输入手机号">
          </div>
          <div class="form-group" v-if="isEditing">
             <label>状态</label>
             <div class="custom-select-wrapper">
               <select v-model="form.status" class="custom-select">
                 <option :value="1">正常</option>
                 <option :value="0">禁用</option>
               </select>
               <div class="select-arrow">
                  <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
               </div>
             </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-secondary" @click="closeModal">取消</button>
          <button class="btn-primary" @click="submitForm" :disabled="loading">
            {{ loading ? '提交中...' : '确定' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { userApi } from '../services/api.js'

const users = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const searchKeyword = ref('')
const totalPages = computed(() => Math.ceil(total.value / pageSize.value))

// Modal state
const showModal = ref(false)
const isEditing = ref(false)
const form = reactive({
  id: null,
  username: '',
  password: '',
  nickname: '',
  email: '',
  phone: '',
  status: 1
})

// Pagination logic
const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, start + 4)
  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

onMounted(() => {
  fetchUsers()
})

const fetchUsers = async () => {
  try {
    loading.value = true
    const res = await userApi.getUsers(currentPage.value, pageSize.value, searchKeyword.value)
    users.value = res.users
    total.value = res.total
  } catch (error) {
    console.error('Failed to fetch users:', error)
    alert('获取用户列表失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchUsers()
}

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  fetchUsers()
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleString()
}

const openCreateModal = () => {
  isEditing.value = false
  form.id = null
  form.username = ''
  form.password = ''
  form.nickname = ''
  form.email = ''
  form.phone = ''
  form.status = 1
  showModal.value = true
}

const openEditModal = (user) => {
  isEditing.value = true
  form.id = user.id
  form.username = user.username
  form.password = '' // Don't show password
  form.nickname = user.nickname
  form.email = user.email
  form.phone = user.phone
  form.status = user.status
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const submitForm = async () => {
  try {
    loading.value = true
    if (isEditing.value) {
      await userApi.updateUser(form.id, form)
    } else {
      await userApi.createUser(form)
    }
    closeModal()
    fetchUsers()
    alert(isEditing.value ? '用户更新成功' : '用户创建成功')
  } catch (error) {
    console.error('Submit failed:', error)
    alert('操作失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

const toggleUserStatus = async (id, status) => {
  try {
    await userApi.updateUserStatus(id, status)
    fetchUsers()
  } catch (error) {
    console.error('Status update failed:', error)
    alert('状态更新失败: ' + error.message)
  }
}

const handleDeleteUser = async (id) => {
  if (!confirm('确定要删除该用户吗？此操作不可恢复。')) return
  try {
    await userApi.deleteUser(id)
    fetchUsers()
    alert('用户已删除')
  } catch (error) {
    console.error('Delete failed:', error)
    alert('删除失败: ' + error.message)
  }
}
</script>

<style scoped>
.user-manage-page {
  padding: 0;
  width: 100%;
  box-sizing: border-box;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 15px;
}

.section-header h2 {
  color: #333;
  margin: 0;
  font-size: 1.5rem;
  font-weight: bold;
}

.header-actions {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.search-box {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.search-box input {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  width: 240px;
  max-width: 100%;
  box-sizing: border-box;
  font-size: 0.9rem;
}

.user-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.user-card {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  border: 1px solid #e1e5e9;
  transition: all 0.3s ease;
}

.user-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  border-color: #d1d5db;
}

.user-info {
  flex: 1;
  margin-right: 1rem;
}

.user-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.user-header h3 {
  margin: 0;
  color: #333;
  font-size: 1.1rem;
  font-weight: 600;
}

.user-status {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: bold;
}

.user-status.active {
  background: #dcfce7;
  color: #166534;
}

.user-status.inactive {
  background: #fee2e2;
  color: #991b1b;
}

.user-meta {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  color: #666;
}

.meta-item .label {
  color: #9ca3af;
  min-width: 60px;
}

.meta-item .value {
  color: #4b5563;
  font-family: 'Courier New', monospace;
}

.user-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  min-width: 100px;
}

.btn-primary, .btn-secondary, .btn-success, .btn-warning, .btn-danger {
  border: none;
  border-radius: 6px;
  cursor: pointer;
  padding: 0.5rem 1rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  font-weight: 500;
  transition: all 0.3s ease;
  box-sizing: border-box;
  text-decoration: none;
}

.btn-primary { background: #4f46e5; color: white; }
.btn-primary:hover { background: #4338ca; transform: translateY(-1px); }

.btn-secondary { background: #6b7280; color: white; }
.btn-secondary:hover { background: #4b5563; transform: translateY(-1px); }

.btn-success { background: #10b981; color: white; }
.btn-success:hover { background: #059669; transform: translateY(-1px); }

.btn-warning { background: #f59e0b; color: white; }
.btn-warning:hover { background: #d97706; transform: translateY(-1px); }

.btn-danger { background: #ef4444; color: white; }
.btn-danger:hover { background: #dc2626; transform: translateY(-1px); }

.btn-primary:disabled {
  background: #a5a6f6;
  cursor: not-allowed;
  transform: none;
}

.pagination-container {
  margin-top: 2rem;
  display: flex;
  justify-content: flex-end;
}

.pagination {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.pagination-btn, .page-btn {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  color: #4b5563;
}

.pagination-btn:hover:not(:disabled), .page-btn:hover:not(.active) {
  background-color: #f3f4f6;
  border-color: #9ca3af;
}

.pagination-btn:disabled {
  background-color: #f9fafb;
  color: #d1d5db;
  cursor: not-allowed;
}

.page-btn.active {
  background-color: #4f46e5;
  color: white;
  border-color: #4f46e5;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(5px);
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 500px;
  max-width: 90%;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  animation: modalSlideUp 0.3s ease-out;
}

@keyframes modalSlideUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

.modal-header {
  padding: 1.5rem 1.5rem 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  color: #111827;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #6b7280;
  padding: 0.5rem;
  border-radius: 50%;
  transition: background 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
}

.close-btn:hover {
  background: #f3f4f6;
  color: #111827;
}

.modal-body {
  padding: 1.5rem;
}

.form-group {
  margin-bottom: 1.25rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #374151;
  font-weight: 500;
  font-size: 0.9rem;
}

.form-group input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  box-sizing: border-box;
  font-size: 0.95rem;
  transition: border-color 0.2s;
}

.form-group input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.required {
  color: #ef4444;
  margin-left: 4px;
}

.modal-footer {
  padding: 1.5rem;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

/* Custom Select */
.custom-select-wrapper {
  position: relative;
}

.custom-select {
  width: 100%;
  padding: 0.75rem 2.5rem 0.75rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: white;
  appearance: none;
  font-size: 0.95rem;
  color: #374151;
}

.select-arrow {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  color: #6b7280;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: #6b7280;
  background: #f9fafb;
  border-radius: 8px;
  border: 2px dashed #e5e7eb;
}

.empty-icon {
  color: #9ca3af;
  margin-bottom: 1rem;
}

.empty-state h3 {
  font-size: 1.1rem;
  color: #374151;
  margin-bottom: 0.5rem;
}

/* Mobile Responsive */
@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }
  
  .header-actions {
    flex-direction: column;
  }
  
  .search-box {
    width: 100%;
  }
  
  .search-box input {
    width: 100%;
    flex: 1;
  }
  
  .user-card {
    flex-direction: column;
    gap: 1rem;
  }
  
  .user-info {
    margin-right: 0;
    width: 100%;
  }
  
  .user-actions {
    flex-direction: row;
    width: 100%;
    justify-content: space-between;
    flex-wrap: wrap;
  }
  
  .user-actions button {
    flex: 1;
    justify-content: center;
  }
  
  .pagination {
    justify-content: center;
  }
}
</style>