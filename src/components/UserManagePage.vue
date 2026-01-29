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
    
    <div class="keys-table">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>用户名</th>
            <th>昵称</th>
            <th>邮箱</th>
            <th>手机号</th>
            <th>状态</th>
            <th>创建时间</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="user.id">
            <td>{{ user.id }}</td>
            <td>{{ user.username }}</td>
            <td>{{ user.nickname || '-' }}</td>
            <td>{{ user.email }}</td>
            <td>{{ user.phone || '-' }}</td>
            <td>
              <span :class="['status', user.status === 1 ? 'status-active' : 'status-inactive']">
                {{ user.status === 1 ? '正常' : '禁用' }}
              </span>
            </td>
            <td>{{ formatDate(user.createTime) }}</td>
            <td>
              <div class="action-buttons">
                <button class="btn-primary btn-sm" @click="openEditModal(user)">
                  编辑
                </button>
                <button 
                  v-if="user.status === 0" 
                  class="btn-success btn-sm" 
                  @click="toggleUserStatus(user.id, 1)"
                >
                  启用
                </button>
                <button 
                  v-if="user.status === 1" 
                  class="btn-warning btn-sm" 
                  @click="toggleUserStatus(user.id, 0)"
                >
                  禁用
                </button>
                <button class="btn-danger btn-sm" @click="handleDeleteUser(user.id)">
                  删除
                </button>
              </div>
            </td>
          </tr>
          <tr v-if="users.length === 0">
            <td colspan="8" class="empty-text">暂无用户数据</td>
          </tr>
        </tbody>
      </table>
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
             <select v-model="form.status">
               <option :value="1">正常</option>
               <option :value="0">禁用</option>
             </select>
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
  padding: 20px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-actions {
  display: flex;
  gap: 15px;
}

.search-box {
  display: flex;
  gap: 10px;
}

.search-box input {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  width: 200px;
}

.keys-table {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.1);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #ebeef5;
}

th {
  background-color: #f5f7fa;
  color: #909399;
  font-weight: 600;
}

.status {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.status-active {
  background-color: #f0f9eb;
  color: #67c23a;
}

.status-inactive {
  background-color: #fef0f0;
  color: #f56c6c;
}

.action-buttons {
  display: flex;
  gap: 8px;
}

.btn-primary, .btn-secondary, .btn-success, .btn-warning, .btn-danger {
  border: none;
  border-radius: 4px;
  cursor: pointer;
  padding: 8px 16px;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  transition: all 0.3s;
}

.btn-sm {
  padding: 4px 8px;
  font-size: 12px;
}

.btn-primary {
  background-color: #409eff;
  color: white;
}

.btn-secondary {
  background-color: #f4f4f5;
  color: #909399;
}

.btn-success {
  background-color: #67c23a;
  color: white;
}

.btn-warning {
  background-color: #e6a23c;
  color: white;
}

.btn-danger {
  background-color: #f56c6c;
  color: white;
}

.btn-primary:disabled {
  background-color: #a0cfff;
  cursor: not-allowed;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.pagination {
  display: flex;
  gap: 10px;
}

.pagination-btn, .page-btn {
  padding: 6px 12px;
  border: 1px solid #dcdfe6;
  background: white;
  border-radius: 4px;
  cursor: pointer;
}

.pagination-btn:disabled {
  background-color: #f5f7fa;
  color: #c0c4cc;
  cursor: not-allowed;
}

.page-btn.active {
  background-color: #409eff;
  color: white;
  border-color: #409eff;
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
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 500px;
  max-width: 90%;
}

.modal-header {
  padding: 20px;
  border-bottom: 1px solid #ebeef5;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #909399;
}

.modal-body {
  padding: 20px;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: #606266;
}

.form-group input, .form-group select {
  width: 100%;
  padding: 8px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  box-sizing: border-box;
}

.required {
  color: #f56c6c;
}

.modal-footer {
  padding: 20px;
  border-top: 1px solid #ebeef5;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>
