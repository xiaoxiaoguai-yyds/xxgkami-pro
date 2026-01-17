<template>
  <div class="pricing-manage-page">
    <div class="section-header">
      <h2>卡密定价管理</h2>
      <button class="btn-primary" @click="openAddModal">
        <i class="fas fa-plus"></i>
        添加定价
      </button>
    </div>

    <!-- 时间卡定价 -->
    <div class="pricing-section">
      <h3>时间卡定价</h3>
      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>描述</th>
              <th>时长(天)</th>
              <th>价格(元)</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in timeCards" :key="item.id">
              <td>{{ item.id }}</td>
              <td>{{ item.description }}</td>
              <td>{{ item.value }}</td>
              <td>¥{{ item.price }}</td>
              <td>
                <div class="action-buttons">
                  <button class="btn-primary btn-sm" @click="editPricing(item)">编辑</button>
                  <button class="btn-danger btn-sm" @click="deletePricing(item.id)">删除</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 次数卡定价 -->
    <div class="pricing-section" style="margin-top: 2rem;">
      <h3>次数卡定价</h3>
      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>描述</th>
              <th>次数</th>
              <th>价格(元)</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in countCards" :key="item.id">
              <td>{{ item.id }}</td>
              <td>{{ item.description }}</td>
              <td>{{ item.value }}</td>
              <td>¥{{ item.price }}</td>
              <td>
                <div class="action-buttons">
                  <button class="btn-primary btn-sm" @click="editPricing(item)">编辑</button>
                  <button class="btn-danger btn-sm" @click="deletePricing(item.id)">删除</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 编辑/添加 弹窗 -->
    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ isEditing ? '编辑定价' : '添加定价' }}</h3>
          <button class="close-btn" @click="closeModal">&times;</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="savePricing">
            <div class="form-group">
              <label>类型</label>
              <select v-model="form.type" :disabled="isEditing">
                <option value="time">时间卡</option>
                <option value="count">次数卡</option>
              </select>
            </div>
            <div class="form-group">
              <label>{{ form.type === 'time' ? '时长(天)' : '次数' }}</label>
              <input type="number" v-model="form.value" required min="1">
            </div>
            <div class="form-group">
              <label>价格</label>
              <input type="number" v-model="form.price" required min="0" step="0.01">
            </div>
            <div class="form-group">
              <label>描述</label>
              <input type="text" v-model="form.description" required placeholder="例如: 7天时间卡">
            </div>
            <div class="modal-actions">
              <button type="button" class="btn-secondary" @click="closeModal">取消</button>
              <button type="submit" class="btn-primary">保存</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { pricingApi } from '../services/api.js'

const timeCards = ref([])
const countCards = ref([])
const showModal = ref(false)
const isEditing = ref(false)
const form = reactive({
  id: null,
  type: 'time',
  value: 1,
  price: 0,
  description: ''
})

const fetchPricing = async () => {
  try {
    const res = await pricingApi.getAllPricing()
    if (res.success && res.data) {
      timeCards.value = res.data.timeCards || []
      countCards.value = res.data.countCards || []
    }
  } catch (error) {
    console.error('Failed to fetch pricing:', error)
    // alert('获取定价失败')
  }
}

const openAddModal = () => {
  isEditing.value = false
  form.id = null
  form.type = 'time'
  form.value = 1
  form.price = 0
  form.description = ''
  showModal.value = true
}

const editPricing = (item) => {
  isEditing.value = true
  form.id = item.id
  form.type = item.type
  form.value = item.value
  form.price = item.price
  form.description = item.description
  showModal.value = true
}

const deletePricing = async (id) => {
  if (!confirm('确定要删除这个定价吗？')) return
  try {
    const res = await pricingApi.deletePricing(id)
    if (res.success) {
      fetchPricing()
    } else {
      alert(res.message || '删除失败')
    }
  } catch (error) {
    console.error('Failed to delete pricing:', error)
    alert('删除失败')
  }
}

const closeModal = () => {
  showModal.value = false
}

const savePricing = async () => {
  try {
    let res
    if (isEditing.value) {
      res = await pricingApi.updatePricing(form.id, form)
    } else {
      res = await pricingApi.addPricing(form)
    }
    
    if (res.success) {
      closeModal()
      fetchPricing()
    } else {
      alert(res.message || '保存失败')
    }
  } catch (error) {
    console.error('Failed to save pricing:', error)
    alert('保存失败')
  }
}

onMounted(() => {
  fetchPricing()
})
</script>

<style scoped>
.pricing-manage-page {
  padding: 1rem;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.table-container {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #eee;
}

th {
  background: #f9fafb;
  font-weight: 600;
  color: #374151;
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.btn-primary {
  background: #2563eb;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-danger {
  background: #dc2626;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 100%;
  max-width: 500px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.modal-header {
  padding: 1rem;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-body {
  padding: 1.5rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #374151;
}

.form-group input, .form-group select {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1.5rem;
}

.btn-secondary {
  background: #9ca3af;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #6b7280;
}
</style>
