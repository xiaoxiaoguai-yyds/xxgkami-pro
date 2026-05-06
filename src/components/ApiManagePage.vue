<template>
  <div class="api-manage-page">
    <div class="section-header">
      <h2>API密钥管理</h2>
      <div class="header-actions">
        <button type="button" class="btn-secondary" title="查看多语言调用核销接口示例" @click="openUseCardCodeModal">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg>
          代码实例
        </button>
        <button class="btn-secondary" @click="showDocsModal = true">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
          接口文档
        </button>
        <button class="btn-primary" @click="showCreateModal = true">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"></path></svg>
          生成API密钥
        </button>
      </div>
    </div>
    
    <div class="api-keys-list">
      <div class="api-key-card" v-for="apiKey in apiKeys" :key="apiKey.id">
        <div class="api-key-info">
          <div class="api-key-header">
            <h3>{{ apiKey.name }}</h3>
            <span class="api-key-status" :class="{ active: apiKey.isActive }">
              {{ apiKey.isActive ? '活跃' : '未使用' }}
            </span>
          </div>
          <div class="api-key-value-container">
            <code class="api-key-value">{{ apiKey.key }}</code>
            <button class="copy-btn" @click="copyApiKey(apiKey.key)" title="复制API密钥">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
              复制
            </button>
          </div>
          <div class="api-key-meta">
            <div class="meta-item">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line><line x1="12" y1="15" x2="12" y2="15"></line></svg>
              <span>创建时间: {{ formatDate(apiKey.createdAt) }}</span>
            </div>
            <div class="meta-item">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
              <span>最后使用: {{ apiKey.lastUsed ? formatDate(apiKey.lastUsed) : '从未使用' }}</span>
            </div>
            <div class="meta-item" v-if="apiKey.requestCount">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline><polyline points="17 6 23 6 23 12"></polyline></svg>
              <span>请求次数: {{ apiKey.requestCount }}</span>
            </div>
            <div class="meta-item">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
              <span>专属卡密: {{ apiKey.cardCodes ? apiKey.cardCodes.length : 0 }} 个</span>
            </div>
            <div class="meta-item">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
              <span>绑定用户: {{ apiKey.assignedUsers ? apiKey.assignedUsers.length : 0 }} 个</span>
            </div>
          </div>
        </div>
        <div class="api-key-actions">
          <button class="btn-info" @click="manageCardCodes(apiKey)">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
            卡密管理
          </button>
          <button class="btn-info" @click="openInterfaceSettings(apiKey)">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V3.09a1.65 1.65 0 0 0 1.82.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0 .33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
            接口设置
          </button>
          <button class="btn-info" @click="manageUsers(apiKey)">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
            用户管理
          </button>
          <button class="btn-secondary" @click="editApiKey(apiKey)">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
            编辑
          </button>
          <button class="btn-warning" @click="toggleApiKey(apiKey)" :title="apiKey.isActive ? '禁用' : '启用'">
            <svg v-if="apiKey.isActive" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="6" y="4" width="4" height="16"></rect><rect x="14" y="4" width="4" height="16"></rect></svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="5 3 19 12 5 21 5 3"></polygon></svg>
            {{ apiKey.isActive ? '禁用' : '启用' }}
          </button>
          <button class="btn-danger" @click="deleteApiKey(apiKey.id)">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
            删除
          </button>
        </div>
      </div>
      
      <div v-if="apiKeys.length === 0" class="empty-state">
        <div class="empty-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"></path></svg>
        </div>
        <h3>暂无API密钥</h3>
        <p>点击上方按钮生成您的第一个API密钥</p>
      </div>
    </div>

    <!-- 创建API密钥模态框 -->
    <div v-if="showCreateModal" class="modal-overlay" @click="showCreateModal = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>创建新的API密钥</h3>
          <button class="close-btn" @click="showCreateModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>密钥名称 <span class="required">*</span></label>
            <input type="text" v-model="newApiKey.name" placeholder="请输入密钥名称" />
          </div>
          <div class="form-group">
            <label>描述</label>
            <textarea v-model="newApiKey.description" rows="3" placeholder="请输入密钥描述（可选）"></textarea>
          </div>
          <div class="form-group">
            <label class="switch-container">
              <div class="switch">
                <input type="checkbox" v-model="newApiKey.enableCardEncryption">
                <span class="slider round"></span>
              </div>
              <span class="switch-text">开启卡密加密验证</span>
            </label>
            <small style="color: #666; font-size: 0.8rem; display: block; margin-top: 0.2rem;">开启后，调用接口必须传入加密后的卡密，系统会自动解密验证。</small>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-secondary" @click="showCreateModal = false">取消</button>
          <button class="btn-primary" @click="createApiKey" :disabled="!newApiKey.name.trim()">
            <i class="fas fa-key"></i>
            创建密钥
          </button>
        </div>
      </div>
    </div>

    <!-- 编辑API密钥模态框 -->
    <div v-if="showEditModal" class="modal-overlay" @click="showEditModal = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>编辑API密钥</h3>
          <button class="close-btn" @click="showEditModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>密钥名称</label>
            <input type="text" v-model="editingKey.name" placeholder="请输入密钥名称" />
          </div>
          <div class="form-group">
            <label>描述</label>
            <textarea v-model="editingKey.description" rows="3" placeholder="请输入密钥描述（可选）"></textarea>
          </div>
          <div class="form-group">
            <label class="switch-container">
              <div class="switch">
                <input type="checkbox" v-model="editingKey.enableCardEncryption">
                <span class="slider round"></span>
              </div>
              <span class="switch-text">开启卡密加密验证</span>
            </label>
            <small style="color: #666; font-size: 0.8rem; display: block; margin-top: 0.2rem;">开启后，调用接口必须传入加密后的卡密，系统会自动解密验证。</small>
          </div>

          <div class="form-group">
            <label class="switch-container">
              <div class="switch">
                <input type="checkbox" v-model="editingKey.requireMachineCode">
                <span class="slider round"></span>
              </div>
              <span class="switch-text">核销时强制传入机器码</span>
            </label>
            <small style="color: #666; font-size: 0.8rem; display: block; margin-top: 0.2rem;">开启后客户端必须在核销接口中附带 machine_code，避免未绑定机器前被多台设备抢先使用。</small>
          </div>

          <div class="form-group">
            <label>同机同规格仅一次（JSON）</label>
            <textarea v-model="editingKey.machineSpecOnceConfig" rows="5" placeholder='例如：{"enabled":true,"rules":[{"card_type":"time","duration":1}]}'></textarea>
            <small style="color: #666; font-size: 0.8rem; display: block; margin-top: 0.2rem;">
              匹配的卡类型+规格在本密钥下每台机器码仅可成功核销一次。可写自定义 spec_key 精确指定一条规则。留空表示不启用；保存空内容将清空配置。
            </small>
          </div>

        </div>
        <div class="modal-actions">
          <button class="btn-secondary" @click="showEditModal = false">取消</button>
          <button class="btn-primary" @click="saveApiKey">
            <i class="fas fa-save"></i>
            保存
          </button>
        </div>
      </div>
    </div>

    <!-- 卡密管理模态框 -->
    <div v-if="showCardCodesModal" class="modal-overlay" @click="showCardCodesModal = false">
      <div class="modal-content large-modal" @click.stop>
        <div class="modal-header">
          <h3>{{ currentApiKey.name }} - 专属卡密管理</h3>
          <button class="close-btn" @click="showCardCodesModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <div class="card-codes-header">
            <div class="card-codes-toolbar">
            <div class="form-group inline">
              <label>生成数量</label>
              <input type="number" v-model="newCardCodeCount" min="1" max="100" placeholder="1-100" />
            </div>
            <div class="form-group inline">
              <label>卡密类型</label>
              <div class="custom-select-wrapper">
                <select v-model="newCardCodeType" class="custom-select">
                  <option value="time">时间卡密</option>
                  <option value="count">次数卡密</option>
                </select>
                <div class="select-arrow">
                  <i class="fas fa-chevron-down"></i>
                </div>
              </div>
            </div>
            <div class="form-group inline">
              <label>{{ newCardCodeType === 'time' ? '有效期（天）' : '使用次数' }}</label>
              <input type="number" v-model="newCardCodeValue" min="1" max="9999" :placeholder="newCardCodeType === 'time' ? '30' : '100'" />
            </div>
            <button class="btn-primary card-codes-generate-btn" @click="generateCardCodes">
              <i class="fas fa-plus"></i>
              生成卡密
            </button>
            </div>

            <div class="stack-time-stack-group api-exclusive-stack" v-if="newCardCodeType === 'time'">
              <div
                class="stack-option-card"
                :class="{ 'stack-option-card--active': newCardStackTime }"
              >
                <label class="stack-toggle-row">
                  <span class="stack-switch">
                    <input
                      type="checkbox"
                      v-model="newCardStackTime"
                      class="stack-switch-input"
                    />
                    <span class="stack-switch-track">
                      <span class="stack-switch-thumb"></span>
                    </span>
                  </span>
                  <span class="stack-toggle-copy">
                    <span class="stack-toggle-title">
                      同机时长叠加（续期）
                      <span v-if="newCardStackTime" class="stack-toggle-pill">已开启</span>
                    </span>
                    <span class="stack-toggle-desc">
                      同一机器码上若已有未过期时间卡，激活本卡时将天数累加到原卡到期时间（本卡标记为「已合并」）；关闭则每次仍从激活时刻重新起算。
                    </span>
                  </span>
                </label>
              </div>
            </div>
          </div>
          
          <div class="card-codes-list">
            <div class="card-code-item" v-for="cardCode in currentApiKey.cardCodes" :key="cardCode.id">
              <div class="card-code-info">
                <code class="card-code-value">{{ cardCode.code }}</code>
                <div class="card-code-meta">
                  <span class="type-badge">{{ cardCode.type }} ({{ cardCode.value }})</span>
                  <span class="status" :class="cardCode.status">{{ getCardCodeStatusText(cardCode.status) }}</span>
                  <span class="expiry" v-if="cardCode.expiryDate">到期: {{ formatDate(cardCode.expiryDate) }}</span>
                  <span class="usage" v-if="cardCode.usedBy">使用者: {{ cardCode.usedBy }}</span>
                </div>
              </div>
              <div class="card-code-actions">
                <button class="copy-btn small" @click="copyCardCode(cardCode.code)" title="复制卡密">
                  <i class="fas fa-copy"></i>
                  复制
                </button>
                <button v-if="currentApiKey.enableCardEncryption" class="copy-btn small warning" @click="copyEncryptedCardCode(cardCode.code)" title="复制加密卡密">
                  <i class="fas fa-lock"></i>
                  加密复制
                </button>
                <button class="btn-danger small" @click="deleteCardCode(cardCode.id)" v-if="cardCode.status === 'unused'">
                  <i class="fas fa-trash"></i>
                  删除
                </button>
              </div>
            </div>
            
            <div v-if="!currentApiKey.cardCodes || currentApiKey.cardCodes.length === 0" class="empty-card-codes">
              <i class="fas fa-credit-card"></i>
              <p>暂无专属卡密，点击上方按钮生成</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 用户管理模态框 -->
    <div v-if="showUsersModal" class="modal-overlay" @click="showUsersModal = false">
      <div class="modal-content large-modal" @click.stop>
        <div class="modal-header">
          <h3>{{ currentApiKey.name }} - 用户管理</h3>
          <button class="close-btn" @click="showUsersModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <div class="users-header">
            <div class="form-group inline">
              <label>添加用户</label>
              <div class="custom-select-wrapper">
                <select v-model="selectedUserId" class="custom-select">
                  <option value="">选择用户</option>
                  <option v-for="user in availableUsers" :key="user.id" :value="user.id">
                    {{ user.username }} ({{ user.email }})
                  </option>
                </select>
                <div class="select-arrow">
                  <i class="fas fa-chevron-down"></i>
                </div>
              </div>
            </div>
            <button class="btn-primary" @click="assignUser" :disabled="!selectedUserId">
              <i class="fas fa-user-plus"></i>
              分配用户
            </button>
          </div>
          
          <div class="assigned-users-list">
            <div class="user-item" v-for="user in currentApiKey.assignedUsers" :key="user.id">
              <div class="user-info">
                <div class="user-avatar">
                  <i class="fas fa-user"></i>
                </div>
                <div class="user-details">
                  <h4>{{ user.username }}</h4>
                  <p>{{ user.email }}</p>
                  <small>分配时间: {{ formatDate(user.assignedAt) }}</small>
                </div>
              </div>
              <div class="user-actions">
                <button class="btn-danger small" @click="unassignUser(user.id)">
                  <i class="fas fa-user-minus"></i>
                  移除
                </button>
              </div>
            </div>
            
            <div v-if="!currentApiKey.assignedUsers || currentApiKey.assignedUsers.length === 0" class="empty-users">
              <i class="fas fa-users"></i>
              <p>暂无分配用户，该API密钥可被所有用户使用</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- API Documentation Modal -->
    <div v-if="showDocsModal" class="modal-overlay" @click="showDocsModal = false">
      <div class="modal-content large-modal" @click.stop>
        <div class="modal-header">
          <h3>API 接口文档</h3>
          <button class="close-btn" @click="showDocsModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body docs-body">
          <div class="doc-section">
            <h4>1. 使用卡密接口</h4>
            <p>通过 API 密钥和卡密，直接使用/核销卡密。</p>
            
            <div class="endpoint-box">
              <span class="method-badge post">POST</span>
              <span class="method-badge get">GET</span>
              <code class="url">/api/v1/use_card</code>
            </div>

            <h5>请求参数</h5>
            <div class="table-container">
              <table class="params-table">
                <thead>
                  <tr>
                    <th>参数名</th>
                    <th>必选</th>
                    <th>类型</th>
                    <th>说明</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>api_key</td>
                    <td>是</td>
                    <td>String</td>
                    <td>您的 API 密钥 (api_key)</td>
                  </tr>
                  <tr>
                    <td>card_key</td>
                    <td>是</td>
                    <td>String</td>
                    <td>要使用的卡密</td>
                  </tr>
                  <tr>
                    <td>machine_code</td>
                    <td>否</td>
                    <td>String</td>
                    <td>机器码 (一机一码，首次使用时绑定)</td>
                  </tr>
                   <tr>
                    <td>ip_address</td>
                    <td>否</td>
                    <td>String</td>
                    <td>客户端IP (若不传则自动获取请求IP)</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <h5>响应示例</h5>
            <pre class="code-block">
{
  "code": 200,
  "message": "Card used successfully",
  "success": true
}</pre>
          </div>
        </div>
      </div>
    </div>

    <!-- 核销接口多语言代码示例 -->
    <div v-if="showUseCardCodeModal" class="modal-overlay" @click="showUseCardCodeModal = false">
      <div class="modal-content large-modal code-examples-modal" @click.stop>
        <div class="modal-header">
          <h3>核销接口代码实例（use_card）</h3>
          <button type="button" class="close-btn" @click="showUseCardCodeModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body code-examples-body">
          <p class="code-examples-intro">{{ useCardCodeIntroText }}</p>
          <p class="code-examples-hint">
            当前环境 API 根路径参考：<code>{{ apiBaseUrlHint }}</code>
            — 请将各示例中的 <code>BASE_URL</code> 换为此值（勿以 <code>/</code> 结尾）。
          </p>
          <div class="code-examples-layout">
            <aside class="code-examples-lang" aria-label="语言列表">
              <button
                v-for="ex in API_USE_CARD_EXAMPLES"
                :key="ex.id"
                type="button"
                class="code-lang-btn"
                :class="{ active: selectedUseCardExampleId === ex.id }"
                @click="selectedUseCardExampleId = ex.id"
              >
                {{ ex.label }}
              </button>
            </aside>
            <div class="code-examples-panel">
              <div class="code-examples-toolbar-inner">
                <span class="code-examples-lang-title">{{ currentUseCardExample?.label }}</span>
                <button type="button" class="btn-primary btn-code-copy" @click="copyUseCardExampleCode">
                  复制代码
                </button>
              </div>
              <pre class="code-block code-examples-pre"><code class="hljs" v-html="highlightedUseCardCodeHtml"></code></pre>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Interface Settings Modal -->
    <div v-if="showInterfaceModal" class="modal-overlay" @click="showInterfaceModal = false">
      <div class="modal-content large-modal" @click.stop>
        <div class="modal-header">
          <h3>{{ currentApiKey.name }} - 接口回调设置</h3>
          <div class="modal-header-right">
            <button type="button" class="btn-doc" @click.stop="toggleInterfaceDocPanel" title="查看配置说明">
              <i class="fas fa-book"></i> 文档
            </button>
            <button class="close-btn" @click="showInterfaceModal = false">
              <i class="fas fa-times"></i>
            </button>
          </div>
        </div>
        <div class="modal-body">
          <div class="interface-settings">
            <div class="form-group">
               <label>回调 URL (Webhook)</label>
               <div
                 class="stack-option-card webhook-url-toggle-card"
                 :class="{ 'stack-option-card--active': interfaceConfig.isCustomUrl }"
               >
                 <label class="stack-toggle-row">
                   <span class="stack-switch">
                     <input
                       type="checkbox"
                       v-model="interfaceConfig.isCustomUrl"
                       class="stack-switch-input"
                     />
                     <span class="stack-switch-track">
                       <span class="stack-switch-thumb"></span>
                     </span>
                   </span>
                   <span class="stack-toggle-copy">
                     <span class="stack-toggle-title">
                       自定义回调 URL
                       <span v-if="interfaceConfig.isCustomUrl" class="stack-toggle-pill">已开启</span>
                     </span>
                     <span class="stack-toggle-desc">
                       开启后可手动填写 Webhook 地址；关闭后由系统根据当前环境自动生成默认回调 URL。
                     </span>
                   </span>
                 </label>
               </div>
               <input type="text" v-model="interfaceConfig.url" :disabled="!interfaceConfig.isCustomUrl" :placeholder="interfaceConfig.isCustomUrl ? 'http://your-server.com/callback' : '系统将自动生成回调 URL'" />
               <small v-if="interfaceConfig.isCustomUrl">当卡密核销成功后，系统将请求此 URL</small>
               <small v-else>系统自动设置 URL (默认: http://{client_ip}:8888/callback)，支持变量替换</small>
             </div>
            <div class="form-group">
              <label>请求方式</label>
              <div class="method-selector-group">
                <div 
                  class="method-option" 
                  :class="{ active: interfaceConfig.method === 'GET' }" 
                  @click="interfaceConfig.method = 'GET'"
                >
                  <div class="radio-circle"></div>
                  <span class="method-name">GET</span>
                </div>
                <div 
                  class="method-option" 
                  :class="{ active: interfaceConfig.method === 'POST' }" 
                  @click="interfaceConfig.method = 'POST'"
                >
                  <div class="radio-circle"></div>
                  <span class="method-name">POST</span>
                </div>
              </div>
            </div>
            
            <div class="params-config">
              <div class="params-header">
                <label>自定义参数配置 (输入)</label>
                <button class="btn-primary small" @click="addInterfaceParam">
                  <i class="fas fa-plus"></i> 添加参数
                </button>
              </div>
              
              <div class="params-list">
                <div class="param-row header">
                  <span>参数名</span>
                  <span>值类型</span>
                  <span>值/变量</span>
                  <span>操作</span>
                </div>
                <div class="param-row" v-for="(param, index) in interfaceConfig.params" :key="'param-'+index">
                  <input type="text" v-model="param.key" placeholder="key" />
                  <select v-model="param.type">
                    <option value="fixed">固定值</option>
                    <option value="variable">系统变量</option>
                  </select>
                  <div class="value-input">
                    <input v-if="param.type === 'fixed'" type="text" v-model="param.value" placeholder="value" />
                    <select v-else v-model="param.value">
                      <option value="time">当前时间 (time)</option>
                      <option value="client_ip">使用者IP (client_ip)</option>
                      <option value="card_key">卡密 (card_key)</option>
                      <option value="api_key">API Key (api_key)</option>
                      <option value="machine_code">机器码 (machine_code)</option>
                      <option value="remaining_time">剩余时间 (remaining_time)</option>
                      <option value="remaining_count">剩余次数 (remaining_count)</option>
                    </select>
                  </div>
                  <div class="row-actions">
                    <button class="btn-icon" @click="moveParam(index, -1)" :disabled="index === 0" title="上移">
                      ↑
                    </button>
                    <button class="btn-icon" @click="moveParam(index, 1)" :disabled="index === interfaceConfig.params.length - 1" title="下移">
                      ↓
                    </button>
                    <button class="btn-danger small" @click="removeInterfaceParam(index)">
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </div>
                <div v-if="interfaceConfig.params.length === 0" class="empty-params">
                  暂无自定义参数，点击右上角添加
                </div>
              </div>
            </div>

            <div class="params-config" style="margin-top: 1.5rem;">
              <div class="params-header">
                <label>自定义返回配置 (JSON)</label>
                <button class="btn-primary small" @click="addResponseParam">
                  <i class="fas fa-plus"></i> 添加字段
                </button>
              </div>
              
              <div class="params-list">
                <div class="param-row header">
                  <span>字段名 (Key)</span>
                  <span>值类型</span>
                  <span>值/变量</span>
                  <span>操作</span>
                </div>
                <div class="param-row" v-for="(param, index) in interfaceConfig.response" :key="'resp-'+index">
                  <input type="text" v-model="param.key" placeholder="json key" />
                  <select v-model="param.type">
                    <option value="fixed">固定值</option>
                    <option value="variable">系统变量</option>
                  </select>
                  <div class="value-input">
                    <input v-if="param.type === 'fixed'" type="text" v-model="param.value" placeholder="value" />
                    <select v-else v-model="param.value">
                      <option value="success">成功标识 (true/false)</option>
                      <option value="message">提示信息 (Success/Error)</option>
                      <option value="status_code">状态码 (Code)</option>
                      <option value="remaining_time">剩余时间 (秒)</option>
                      <option value="remaining_count">剩余次数</option>
                      <option value="card_key">卡密</option>
                      <option value="expire_time">过期时间</option>
                      <option value="card_type">卡密类型</option>
                      <option value="card_status">卡密状态 (yes/no)</option>
                      <option value="machine_code">机器码</option>
                    </select>
                  </div>
                  <div class="row-actions">
                    <button class="btn-icon" @click="moveResponseParam(index, -1)" :disabled="index === 0" title="上移">
                      ↑
                    </button>
                    <button class="btn-icon" @click="moveResponseParam(index, 1)" :disabled="index === interfaceConfig.response.length - 1" title="下移">
                      ↓
                    </button>
                    <button class="btn-danger small" @click="removeResponseParam(index)">
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </div>
                <div v-if="!interfaceConfig.response || interfaceConfig.response.length === 0" class="empty-params">
                  默认返回: {"success": true, "message": "..."}
                </div>
              </div>
            </div>

            <div class="params-config" style="margin-top: 1.5rem;" v-if="interfaceConfig.statusCodes">
              <div class="params-header">
                <label>状态码配置 (Status Codes)</label>
                <button class="btn-secondary small" @click="restoreDefaultStatusCodes">
                  <i class="fas fa-undo"></i> 恢复默认
                </button>
              </div>
              
              <div class="params-list">
                <div class="param-row header">
                  <span>场景 (Scenario)</span>
                  <span>状态码 (Value)</span>
                  <span>说明</span>
                </div>
                <div class="param-row" v-for="(code, index) in interfaceConfig.statusCodes" :key="'status-'+index" style="grid-template-columns: 2fr 2fr 3fr;">
                  <span style="padding: 0.5rem; color: #495057;">{{ code.label }}</span>
                  <input type="text" v-model="code.value" placeholder="code" />
                  <span style="padding: 0.5rem; color: #999; font-size: 0.8rem;">对应变量: status_code</span>
                </div>
              </div>
            </div>

            <div class="url-preview-section">
              <div class="preview-row">
                 <div class="preview-col">
                    <label>实时链接预览 (Request)</label>
                    <div class="preview-box">
                      <code class="preview-url">{{ previewUrl }}</code>
                      <button class="copy-btn small" @click="copyPreviewUrl" title="复制链接">
                        复制
                      </button>
                    </div>
                 </div>
              </div>
              
              <div class="preview-row" style="margin-top: 1rem;">
                 <div class="preview-col">
                    <label>实时返回预览 (Response JSON)</label>
                    <div class="preview-box json-preview">
                      <pre>{{ previewResponseJson }}</pre>
                    </div>
                 </div>
              </div>
            </div>
          </div>
          <div class="modal-actions">
            <button class="btn-secondary" @click="showInterfaceModal = false">取消</button>
            <button class="btn-primary" @click="saveInterfaceConfig">保存配置</button>
          </div>
        </div>
      </div>
    </div>

    <Teleport to="body">
      <div
        v-if="showInterfaceModal && interfaceDocVisible"
        ref="interfaceDocPanelRef"
        class="interface-doc-panel"
        :class="{ 'interface-doc-panel--fullscreen': interfaceDocFullscreen }"
        :style="interfaceDocPanelStyle"
      >
        <div class="interface-doc-header" @mousedown="startDocPanelDrag">
          <span class="interface-doc-title">接口回调配置说明</span>
          <div class="interface-doc-toolbar" @mousedown.stop>
            <button type="button" class="interface-doc-tool-btn" @click="toggleDocFullscreen" :title="interfaceDocFullscreen ? '退出全屏' : '全屏'">
              <i :class="interfaceDocFullscreen ? 'fas fa-compress' : 'fas fa-expand'"></i>
            </button>
            <button type="button" class="interface-doc-tool-btn" @click="closeInterfaceDocPanel" title="关闭">
              <i class="fas fa-times"></i>
            </button>
          </div>
        </div>
        <div class="interface-doc-body">
          <div class="interface-doc-callout">
            <strong>新手提示：</strong>绝大多数场景下<strong>无需修改</strong>系统自动生成的<strong>回调 URL</strong>与默认的<strong>请求方式（GET）</strong>。仅在您的业务有特殊要求时，再调整请求方式或开启「自定义回调 URL」填写自有地址。
          </div>

          <section class="interface-doc-section">
            <h4>一、自定义参数配置（输入）</h4>
            <p>定义系统在核销成功后，向您的 Webhook 发起请求时<strong>附带哪些查询参数（GET）或表单/JSON 字段（POST）</strong>。</p>
            <ul>
              <li><strong>参数名</strong>：对方接口约定的 key，例如 <code>token</code>、<code>cdkey</code>。</li>
              <li><strong>值类型 · 固定值</strong>：每次请求都传同一个字符串，适合固定密钥等。</li>
              <li><strong>值类型 · 系统变量</strong>：由本系统自动填充，例如卡密 <code>card_key</code>、API Key、机器码 <code>machine_code</code>、剩余时间/次数等。</li>
              <li>使用「上移 / 下移」可调整参数顺序；GET 请求下参数会按顺序拼接到 URL 查询串。</li>
            </ul>
          </section>

          <section class="interface-doc-section">
            <h4>二、自定义返回配置（JSON）</h4>
            <p>用于定义当您的接口<strong>返回给客户端</strong>时，JSON 里各字段如何由系统变量或固定值组成（与下方「实时返回预览」一致）。</p>
            <ul>
              <li><strong>字段名 (Key)</strong>：返回 JSON 中的属性名，如 <code>success</code>、<code>msg</code>、<code>code</code>。</li>
              <li><strong>系统变量</strong>：将核销结果映射到字段，例如成功标识、提示信息、状态码、剩余时间、卡密类型等。</li>
              <li>请至少保留能表达「成功 / 失败」的字段，并与<strong>状态码配置</strong>中的逻辑一致，便于客户端判断。</li>
            </ul>
          </section>

          <section class="interface-doc-section">
            <h4>三、状态码配置（Status Codes）</h4>
            <p>为各类业务结果指定<strong>数字状态码</strong>（会映射到变量 <code>status_code</code>，供自定义返回 JSON 使用）。</p>
            <ul>
              <li>每一行对应一种场景（如验证成功、卡密不存在、已过期、机器码不匹配等）。</li>
              <li>修改「状态码 (Value)」即可；若不确定，可点击「恢复默认」还原推荐值。</li>
              <li>请在「自定义返回配置」中选用变量 <code>status_code</code>，与这里配置保持一致，客户端才能正确分支。</li>
            </ul>
          </section>

          <section class="interface-doc-section interface-doc-muted">
            <p>拖动顶部标题栏可移动窗口；拖动右下角斜线区域可调整大小；全屏后便于阅读长文档，再次点击可还原并回到右下角默认尺寸。</p>
          </section>
        </div>
        <div
          v-if="!interfaceDocFullscreen"
          class="interface-doc-resize"
          @mousedown.stop.prevent="startDocPanelResize"
          title="拖动调整大小"
        />
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { apiKeyApi, cardApi } from '../services/api'
import { ElMessage, ElMessageBox } from 'element-plus'
import { copyToClipboard } from '../utils/clipboard.js'
import { highlightUseCardExample } from '../utils/useCardCodeHighlight.js'
import { API_USE_CARD_INTRO, API_USE_CARD_EXAMPLES } from '../data/apiUseCardCodeExamples.js'
import 'highlight.js/styles/github-dark.css'

const props = defineProps({
  // apiKeys: Array, // No longer props, fetched internally
  // allUsers: Array
})

const emit = defineEmits([
  // 'generate-api-key', // No longer emitting, handling internally
  // ...
])

// Data
const apiKeys = ref([])
const allUsers = ref([])

const showEditModal = ref(false)
const showCreateModal = ref(false)
const showDocsModal = ref(false)
const showUseCardCodeModal = ref(false)
const selectedUseCardExampleId = ref(API_USE_CARD_EXAMPLES[0]?.id ?? 'curl')
const showInterfaceModal = ref(false)
const showCardCodesModal = ref(false)
const showUsersModal = ref(false)
const currentApiKey = ref({})
const selectedUserId = ref('')
const newCardCodeCount = ref(10)
const newCardCodeType = ref('time')
const newCardCodeValue = ref(30) // duration or count
const newCardStackTime = ref(false)

/** 接口回调设置 — 右下角可拖动/缩放/全屏的说明面板 */
const interfaceDocVisible = ref(false)
const interfaceDocFullscreen = ref(false)
const interfaceDocPanelRef = ref(null)
const docPanelLayout = reactive({
  x: null,
  y: null,
  w: 440,
  h: 420
})

const apiBaseUrlHint = computed(() => {
  const raw = import.meta.env?.VITE_API_BASE_URL
  let base = typeof raw === 'string' && raw.trim() ? raw.trim() : '/api'
  base = base.replace(/\/+$/, '')
  if (base.startsWith('http://') || base.startsWith('https://')) {
    return base
  }
  if (typeof window !== 'undefined') {
    const prefix = base.startsWith('/') ? base : `/${base}`
    return `${window.location.origin}${prefix}`
  }
  return base
})

const useCardCodeIntroText = computed(() =>
  API_USE_CARD_INTRO.replace(/\{BASE_URL\}/g, apiBaseUrlHint.value)
)

const currentUseCardExample = computed(
  () =>
    API_USE_CARD_EXAMPLES.find((e) => e.id === selectedUseCardExampleId.value) ?? API_USE_CARD_EXAMPLES[0]
)

const highlightedUseCardCodeHtml = computed(() => {
  const ex = currentUseCardExample.value
  if (!ex?.code) return ''
  return highlightUseCardExample(ex.code, ex.id)
})

function openUseCardCodeModal() {
  selectedUseCardExampleId.value = API_USE_CARD_EXAMPLES[0]?.id ?? 'curl'
  showUseCardCodeModal.value = true
}

async function copyUseCardExampleCode() {
  const code = currentUseCardExample.value?.code
  if (!code) return
  const ok = await copyToClipboard(code)
  if (ok) ElMessage.success('代码已复制')
  else ElMessage.error('复制失败')
}

watch(showInterfaceModal, (open) => {
  if (!open) {
    interfaceDocVisible.value = false
    interfaceDocFullscreen.value = false
    docPanelLayout.x = null
    docPanelLayout.y = null
    docPanelLayout.w = 440
    docPanelLayout.h = 420
  }
})

const interfaceDocPanelStyle = computed(() => {
  if (interfaceDocFullscreen.value) {
    return {
      position: 'fixed',
      left: '0',
      top: '0',
      width: '100vw',
      height: '100vh',
      maxWidth: '100vw',
      maxHeight: '100vh',
      zIndex: '10050'
    }
  }
  const base = {
    position: 'fixed',
    width: `${docPanelLayout.w}px`,
    height: `${docPanelLayout.h}px`,
    zIndex: '10050',
    minWidth: '300px',
    minHeight: '220px'
  }
  if (docPanelLayout.x != null && docPanelLayout.y != null) {
    return {
      ...base,
      left: `${docPanelLayout.x}px`,
      top: `${docPanelLayout.y}px`,
      right: 'auto',
      bottom: 'auto'
    }
  }
  return {
    ...base,
    right: '24px',
    bottom: '24px',
    left: 'auto',
    top: 'auto'
  }
})

function toggleInterfaceDocPanel() {
  interfaceDocVisible.value = !interfaceDocVisible.value
}

function closeInterfaceDocPanel() {
  interfaceDocVisible.value = false
}

function toggleDocFullscreen() {
  interfaceDocFullscreen.value = !interfaceDocFullscreen.value
  if (!interfaceDocFullscreen.value) {
    docPanelLayout.x = null
    docPanelLayout.y = null
    docPanelLayout.w = 440
    docPanelLayout.h = 420
  }
}

function startDocPanelDrag(e) {
  if (interfaceDocFullscreen.value) return
  if (e.button !== 0) return
  const el = interfaceDocPanelRef.value
  if (!el) return
  const rect = el.getBoundingClientRect()
  if (docPanelLayout.x == null || docPanelLayout.y == null) {
    docPanelLayout.x = rect.left
    docPanelLayout.y = rect.top
  }
  const sx = e.clientX
  const sy = e.clientY
  const ox = docPanelLayout.x
  const oy = docPanelLayout.y
  const onMove = (ev) => {
    let nx = ox + ev.clientX - sx
    let ny = oy + ev.clientY - sy
    const vw = window.innerWidth
    const vh = window.innerHeight
    const w = Math.min(docPanelLayout.w, vw)
    nx = Math.min(Math.max(0, nx), Math.max(0, vw - w))
    ny = Math.min(Math.max(0, ny), Math.max(0, vh - 48))
    docPanelLayout.x = nx
    docPanelLayout.y = ny
  }
  const onUp = () => {
    document.removeEventListener('mousemove', onMove)
    document.removeEventListener('mouseup', onUp)
  }
  document.addEventListener('mousemove', onMove)
  document.addEventListener('mouseup', onUp)
  e.preventDefault()
}

function startDocPanelResize(e) {
  if (interfaceDocFullscreen.value) return
  const el = interfaceDocPanelRef.value
  if (!el) return
  const rect = el.getBoundingClientRect()
  if (docPanelLayout.x == null || docPanelLayout.y == null) {
    docPanelLayout.x = rect.left
    docPanelLayout.y = rect.top
  }
  const sw = docPanelLayout.w
  const sh = docPanelLayout.h
  const sx = e.clientX
  const sy = e.clientY
  const onMove = (ev) => {
    docPanelLayout.w = Math.max(300, sw + ev.clientX - sx)
    docPanelLayout.h = Math.max(220, sh + ev.clientY - sy)
  }
  const onUp = () => {
    document.removeEventListener('mousemove', onMove)
    document.removeEventListener('mouseup', onUp)
  }
  document.addEventListener('mousemove', onMove)
  document.addEventListener('mouseup', onUp)
}

const interfaceConfig = reactive({
  url: '',
  method: 'GET',
  isCustomUrl: true,
  params: [],
  response: [],
  statusCodes: [
    { key: 'success', label: '验证成功', value: '200' },
    { key: 'not_found', label: '卡密不存在', value: '404' },
    { key: 'expired', label: '卡密已过期', value: '401' },
    { key: 'used', label: '卡密已使用/停用', value: '402' },
    { key: 'no_count', label: '次数已用尽', value: '403' },
    { key: 'machine_code_mismatch', label: '机器码不匹配', value: '406' },
    { key: 'reverify_denied', label: '不允许重复验证', value: '407' },
    { key: 'machine_code_required', label: '需提供机器码', value: '408' },
    { key: 'spec_once_used', label: '同机同规格已用', value: '409' },
    { key: 'merged', label: '卡密已合并续期', value: '410' },
    { key: 'spec_once_concurrency', label: '核销冲突', value: '411' },
    { key: 'error', label: '其他错误', value: '500' }
  ]
})



// Helper to generate default URL
const generateDefaultUrl = () => {
  const protocol = window.location.protocol
  const host = window.location.host
  const key = currentApiKey.value.key || '{api_key}'
  return `${protocol}//${host}/api/custom/${key}/use`
}

watch(() => interfaceConfig.isCustomUrl, (isCustom) => {
  if (!isCustom) {
    interfaceConfig.url = generateDefaultUrl()
  }
})

const editingKey = reactive({
  id: null,
  name: '',
  description: '',
  isActive: true,
  enableCardEncryption: false,
  requireMachineCode: false,
  machineSpecOnceConfig: ''
})

const newApiKey = reactive({
  name: '',
  description: '',
  enableCardEncryption: false
})

// Methods
const fetchApiKeys = async () => {
  try {
    const data = await apiKeyApi.getAllApiKeys()
    // Map backend data to frontend model and fetch related data
    apiKeys.value = await Promise.all(data.map(async key => {
      let cardCodes = [];
      try {
        // Fetch real cards count
        const cardsRes = await cardApi.getApiKeyCards(key.id);
        if (cardsRes.success) {
           cardCodes = cardsRes.data.map(c => ({
              id: c.id,
              code: c.card_key,
              status: c.status === 0 ? 'unused' : (c.status === 4 ? 'merged' : 'used'),
              expiryDate: c.expire_time,
              type: c.card_type === 'time' ? '时间卡' : '次数卡',
              value: c.card_type === 'time' ? `${c.duration}天` : `${c.total_count}次`,
              usedBy: c.device_id ? `Device ${c.device_id.substring(0, 6)}...` : null
           }));
        }
      } catch (e) {
        console.warn(`Failed to fetch cards for key ${key.id}`, e);
      }

      return {
        id: key.id,
        name: key.keyName, // Use keyName for user-defined name
        key: key.apiKey,   // Use apiKey for the secret key
        description: key.description,
        isActive: key.status === 1,
        createdAt: key.createTime,
        lastUsed: null, // Not implemented yet
        requestCount: 0, // Not implemented yet
        cardCodes: cardCodes, 
        webhookConfig: key.webhook_config ? JSON.parse(key.webhook_config) : null,
        assignedUsers: key.assignedUsers || [],
        enableCardEncryption: key.enable_card_encryption || false,
        requireMachineCode: key.require_machine_code || false,
        machineSpecOnceConfig: key.machine_spec_once_config || ''
      }
    }))
  } catch (error) {
    console.error('Failed to fetch API keys:', error)
    ElMessage.error('获取API密钥失败')
  }
}

const fetchUsers = async () => {
  try {
    const data = await apiKeyApi.getAllUsers()
    allUsers.value = data?.users || data || []
  } catch (error) {
    console.error('Failed to fetch users:', error)
    allUsers.value = []
  }
}

const createApiKey = async () => {
  if (!newApiKey.name.trim()) return
  
  try {
    await apiKeyApi.createApiKey({
      name: newApiKey.name,
      description: newApiKey.description,
      enable_card_encryption: newApiKey.enableCardEncryption
    })
    ElMessage.success('创建成功')
    showCreateModal.value = false
    newApiKey.name = ''
    newApiKey.description = ''
    newApiKey.enableCardEncryption = false
    fetchApiKeys()
  } catch (error) {
    console.error('Create failed:', error)
    ElMessage.error('创建失败')
  }
}

const saveApiKey = async () => {
  try {
    await apiKeyApi.updateApiKey(editingKey.id, {
      name: editingKey.name,
      description: editingKey.description,
      status: editingKey.isActive ? 1 : 0,
      enable_card_encryption: editingKey.enableCardEncryption,
      require_machine_code: editingKey.requireMachineCode,
      machine_spec_once_config: editingKey.machineSpecOnceConfig || ''
    })
    ElMessage.success('保存成功')
    
    // Update local list directly to reflect changes immediately
    const keyIndex = apiKeys.value.findIndex(k => k.id === editingKey.id)
    if (keyIndex !== -1) {
      apiKeys.value[keyIndex].name = editingKey.name
      apiKeys.value[keyIndex].description = editingKey.description
      apiKeys.value[keyIndex].enableCardEncryption = editingKey.enableCardEncryption
      apiKeys.value[keyIndex].requireMachineCode = editingKey.requireMachineCode
      apiKeys.value[keyIndex].machineSpecOnceConfig = editingKey.machineSpecOnceConfig
    }
    
    showEditModal.value = false
    fetchApiKeys()
  } catch (error) {
    console.error('Update failed:', error)
    ElMessage.error('保存失败')
  }
}

const deleteApiKey = async (id) => {
  try {
    await ElMessageBox.confirm('确定要删除这个API密钥吗？此操作不可恢复。', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await apiKeyApi.deleteApiKey(id)
    ElMessage.success('删除成功')
    fetchApiKeys()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('Delete failed:', error)
      ElMessage.error('删除失败')
    }
  }
}

const toggleApiKey = async (apiKey) => {
  try {
    const newStatus = !apiKey.isActive
    await apiKeyApi.updateApiKey(apiKey.id, {
      name: apiKey.name,
      description: apiKey.description,
      status: newStatus ? 1 : 0,
      enable_card_encryption: apiKey.enableCardEncryption
    })
    apiKey.isActive = newStatus
    ElMessage.success(newStatus ? '已启用' : '已禁用')
  } catch (error) {
    console.error('Toggle failed:', error)
    ElMessage.error('操作失败')
  }
}

const assignUser = async () => {
  if (!selectedUserId.value || !currentApiKey.value.id) return
  
  try {
    await apiKeyApi.assignUser(currentApiKey.value.id, selectedUserId.value)
    ElMessage.success('分配成功')
    selectedUserId.value = ''
    // Refresh to update list
    await fetchApiKeys()
    // Update currentApiKey reference from fresh list
    const updatedKey = apiKeys.value.find(k => k.id === currentApiKey.value.id)
    if (updatedKey) {
      currentApiKey.value = updatedKey
    }
  } catch (error) {
    console.error('Assign failed:', error)
    ElMessage.error('分配用户失败')
  }
}

const unassignUser = async (userId) => {
  if (!currentApiKey.value.id) return
  
  try {
    await apiKeyApi.unassignUser(currentApiKey.value.id, userId)
    ElMessage.success('移除成功')
    // Refresh
    await fetchApiKeys()
    const updatedKey = apiKeys.value.find(k => k.id === currentApiKey.value.id)
    if (updatedKey) {
      currentApiKey.value = updatedKey
    }
  } catch (error) {
    console.error('Unassign failed:', error)
    ElMessage.error('移除用户失败')
  }
}

// Card Code Management
const fetchCardCodes = async (apiKeyId) => {
  if (!apiKeyId) return
  try {
    const res = await cardApi.getApiKeyCards(apiKeyId)
    // Map to frontend format
    const cards = res.data.map(c => ({
       id: c.id,
       code: c.card_key,
       status: c.status === 0 ? 'unused' : 'used', // 0: 未使用, 1: 已使用 (时间卡即使激活也是1)
       expiryDate: c.expire_time,
       type: c.card_type === 'time' ? '时间卡' : '次数卡',
       value: c.card_type === 'time' ? `${c.duration}天` : `${c.total_count}次`,
       usedBy: c.device_id ? `Device ${c.device_id.substring(0, 6)}...` : null
     }))
    
    // Update currentApiKey.cardCodes
    if (currentApiKey.value.id === apiKeyId) {
      currentApiKey.value.cardCodes = cards
    }
    
    // Update apiKeys list as well
    const keyIndex = apiKeys.value.findIndex(k => k.id === apiKeyId)
    if (keyIndex !== -1) {
      apiKeys.value[keyIndex].cardCodes = cards
    }
  } catch (error) {
    console.error('Fetch cards failed:', error)
    ElMessage.error('获取卡密失败')
  }
}

const generateCardCodes = async () => {
  if (!currentApiKey.value.id) return
  
  try {
    const res = await cardApi.createCards({
      count: newCardCodeCount.value,
      card_type: newCardCodeType.value,
      duration: newCardCodeType.value === 'time' ? newCardCodeValue.value : 0,
      total_count: newCardCodeType.value === 'count' ? newCardCodeValue.value : 0,
      verify_method: 'web',
      encryption_type: 'advanced',
      allow_reverify: 1,
      api_key_id: currentApiKey.value.id,
      stack_time_if_same_machine: newCardCodeType.value === 'time' && newCardStackTime.value
    })
    
    ElMessage.success(`成功生成 ${res.data.length} 个卡密`)
    await fetchCardCodes(currentApiKey.value.id)
  } catch (error) {
    console.error('Generate cards failed:', error)
    ElMessage.error('生成卡密失败')
  }
}

const deleteCardCode = async (cardId) => {
  try {
    await ElMessageBox.confirm('确定要删除这个卡密吗？此操作不可恢复！', '确认删除', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const result = await cardApi.deleteCard(cardId)
    if (result.success) {
      ElMessage.success('卡密删除成功')
      // Refresh list
      await fetchCardCodes(currentApiKey.value.id)
    } else {
      ElMessage.error(result.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除卡密失败:', error)
      ElMessage.error(error.message || '删除失败')
    }
  }
}

const copyCardCode = async (code) => {
  const success = await copyToClipboard(code)
  if (success) {
    ElMessage.success('卡密已复制')
  } else {
    ElMessage.error('复制失败')
  }
}

// 简单的前端混淆实现，与后端 CustomCardObfuscator 保持一致
// 算法：URL编码 -> 反转 -> Base64 -> 替换字符
const obfuscateCardKey = (rawKey) => {
  if (!rawKey) return rawKey
  try {
    // 1. URL 编码
    const encoded = encodeURIComponent(rawKey)
    // 2. 字符串反转
    const reversed = encoded.split('').reverse().join('')
    // 3. Base64 编码 (使用 btoa，注意处理中文)
    const base64 = btoa(reversed)
    // 4. 字符替换
    return base64.replace(/e/g, '*').replace(/U/g, '-')
  } catch (e) {
    console.error('Obfuscation failed:', e)
    return rawKey
  }
}

const copyEncryptedCardCode = async (code) => {
  const encrypted = obfuscateCardKey(code)
  const success = await copyToClipboard(encrypted)
  if (success) {
    ElMessage.success('加密卡密已复制')
  } else {
    ElMessage.error('复制失败')
  }
}

const getCardCodeStatusText = (status) => {
  const map = {
    'unused': '未使用',
    'used': '已使用',
    'merged': '已合并续期',
    'expired': '已过期'
  }
  return map[status] || status
}

// Interface Config Management
const openInterfaceSettings = (apiKey) => {
  currentApiKey.value = apiKey
  if (apiKey.webhookConfig) {
    interfaceConfig.method = apiKey.webhookConfig.method || 'GET'
    interfaceConfig.params = apiKey.webhookConfig.params || []
    interfaceConfig.response = apiKey.webhookConfig.response || []
    interfaceConfig.isCustomUrl = apiKey.webhookConfig.isCustomUrl !== undefined ? apiKey.webhookConfig.isCustomUrl : true
    
    // Load status codes or use defaults
    if (apiKey.webhookConfig.statusCodes && apiKey.webhookConfig.statusCodes.length > 0) {
      // Merge with defaults to ensure all keys exist (in case of updates)
      const defaults = [
        { key: 'success', label: '验证成功', value: '200' },
        { key: 'not_found', label: '卡密不存在', value: '404' },
        { key: 'expired', label: '卡密已过期', value: '401' },
        { key: 'used', label: '卡密已使用/停用', value: '402' },
        { key: 'no_count', label: '次数已用尽', value: '403' },
        { key: 'error', label: '其他错误', value: '500' }
      ]
      interfaceConfig.statusCodes = defaults.map(def => {
        const saved = apiKey.webhookConfig.statusCodes.find(s => s.key === def.key)
        return saved ? { ...def, value: saved.value } : def
      })
    } else {
      interfaceConfig.statusCodes = [
        { key: 'success', label: '验证成功', value: '200' },
        { key: 'not_found', label: '卡密不存在', value: '404' },
        { key: 'expired', label: '卡密已过期', value: '401' },
        { key: 'used', label: '卡密已使用/停用', value: '402' },
        { key: 'no_count', label: '次数已用尽', value: '403' },
        { key: 'error', label: '其他错误', value: '500' }
      ]
    }

    // If system managed, regenerate URL to ensure it's correct for current environment
    if (!interfaceConfig.isCustomUrl) {
      interfaceConfig.url = generateDefaultUrl()
    } else {
      interfaceConfig.url = apiKey.webhookConfig.url || ''
    }
  } else {
    // Default for new config: System managed (Auto set)
    interfaceConfig.method = 'GET'
    interfaceConfig.params = []
    interfaceConfig.response = [
      { key: 'code', type: 'variable', value: 'status_code' },
      { key: 'msg', type: 'variable', value: 'message' },
      { key: 'data', type: 'variable', value: 'remaining_count' }
    ]
    interfaceConfig.statusCodes = [
      { key: 'success', label: '验证成功', value: '200' },
      { key: 'not_found', label: '卡密不存在', value: '404' },
      { key: 'expired', label: '卡密已过期', value: '401' },
      { key: 'used', label: '卡密已使用/停用', value: '402' },
      { key: 'no_count', label: '次数已用尽', value: '403' },
      { key: 'error', label: '其他错误', value: '500' }
    ]
    interfaceConfig.isCustomUrl = true
    interfaceConfig.url = generateDefaultUrl()
  }
  showInterfaceModal.value = true
}

const addInterfaceParam = () => {
  interfaceConfig.params.push({
    key: '',
    type: 'variable',
    value: 'card_key'
  })
}

const removeInterfaceParam = (index) => {
  interfaceConfig.params.splice(index, 1)
}

const moveParam = (index, direction) => {
  const newIndex = index + direction
  if (newIndex >= 0 && newIndex < interfaceConfig.params.length) {
    const temp = interfaceConfig.params[index]
    interfaceConfig.params[index] = interfaceConfig.params[newIndex]
    interfaceConfig.params[newIndex] = temp
  }
}

const addResponseParam = () => {
  interfaceConfig.response.push({
    key: '',
    type: 'fixed',
    value: ''
  })
}

const removeResponseParam = (index) => {
  interfaceConfig.response.splice(index, 1)
}

const moveResponseParam = (index, direction) => {
  const newIndex = index + direction
  if (newIndex >= 0 && newIndex < interfaceConfig.response.length) {
    const temp = interfaceConfig.response[index]
    interfaceConfig.response[index] = interfaceConfig.response[newIndex]
    interfaceConfig.response[newIndex] = temp
  }
}

const restoreDefaultStatusCodes = () => {
  interfaceConfig.statusCodes = [
    { key: 'success', label: '验证成功', value: '200' },
    { key: 'not_found', label: '卡密不存在', value: '404' },
    { key: 'expired', label: '卡密已过期', value: '401' },
    { key: 'used', label: '卡密已使用/停用', value: '402' },
    { key: 'no_count', label: '次数已用尽', value: '403' },
    { key: 'machine_code_mismatch', label: '机器码不匹配', value: '406' },
    { key: 'reverify_denied', label: '不允许重复验证', value: '407' },
    { key: 'machine_code_required', label: '需提供机器码', value: '408' },
    { key: 'spec_once_used', label: '同机同规格已用', value: '409' },
    { key: 'merged', label: '卡密已合并续期', value: '410' },
    { key: 'spec_once_concurrency', label: '核销冲突', value: '411' },
    { key: 'error', label: '其他错误', value: '500' }
  ]
}

const saveInterfaceConfig = async () => {
  // Validate that 'card_key' is mapped
  const hasCardKey = interfaceConfig.params.some(p => p.type === 'variable' && p.value === 'card_key')
  if (!hasCardKey) {
    ElMessage.error('必须配置"卡密 (card_key)"变量，否则系统无法获取卡密信息')
    return
  }

  // Validate that 'status_code' is mapped in response
  const hasStatusCode = interfaceConfig.response.some(p => p.type === 'variable' && p.value === 'status_code')
  if (!hasStatusCode) {
    try {
      await ElMessageBox.confirm(
        '检测到您配置了状态码规则，但未在返回结果中添加"状态码"字段。是否自动添加？',
        '配置提示',
        {
          confirmButtonText: '自动添加',
          cancelButtonText: '保持原样',
          type: 'warning'
        }
      )
      // User clicked "Auto Add"
      interfaceConfig.response.unshift({
        key: 'code',
        type: 'variable',
        value: 'status_code'
      })
    } catch (e) {
      // User clicked "Keep as is" (cancel), proceed to save
    }
  }

  try {
    // Generate URL based on parameters if needed, but user wants automatic URL setting?
    // User instruction: "核销卡密的回调url自动设置，当参数自定义完后自动设置回调url，不需要客户设置"
    // This implies that the URL is generated on the client side based on the parameters?
    // Or does it mean the backend automatically constructs the URL?
    // If "不需要客户设置", it means the input field for URL should be read-only or auto-filled.
    // Assuming the user provides a base URL, and parameters are appended automatically?
    // Or maybe the user means the system automatically generates a callback URL for them to USE?
    // "核销卡密的回调url自动设置" -> The URL that is CALLED when card is used.
    // Usually, the user provides this URL so the system can notify THEM.
    // If it's "automatic", maybe it means constructing the query string automatically?
    
    // Let's assume the user means: When I add parameters, the system should automatically append them to the URL in the preview or config?
    // BUT, usually Webhook URL is where WE send data TO.
    // If the user says "automatic setting", maybe they mean:
    // 1. They enter a base URL.
    // 2. We automatically append `?param1=value1&param2=value2` to it for GET requests?
    // OR
    // 3. Maybe they mean the `interfaceConfig.url` should be automatically generated? That doesn't make sense for a webhook (we need to know where to send).
    
    // Re-reading: "当参数自定义完后自动设置回调url"
    // Maybe they mean constructing the example URL?
    // OR, maybe they mean the *User's* callback URL?
    // Let's assume they want the URL input to be automatically updated with query params if method is GET.
    
    // Actually, if it's a webhook, the USER provides the URL.
    // If the user wants "automatic setting", maybe they mean we should just save the Base URL and the Params separately,
    // and the system (backend) handles the construction.
    
    // Let's look at the UI. There is a "回调 URL" input.
    // If the user says "no need for customer to set", maybe they mean the URL is FIXED?
    // Unlikely for a webhook.
    
    // Wait, "接口的参数支持用户自定义... 自定义参数支持... 使用者可以自行添加参数到get或者post请求"
    // This sounds like the USER (API consumer) defines what parameters they want to receive.
    // "核销卡密的回调url自动设置" -> Maybe they mean the query string part?
    
    // Let's try to interpret "automatic URL setting" as:
    // When saving, we don't need to manually type the full URL with params in the input box.
    // We just type the base URL, and the params are stored in `params` array.
    // The backend `WebhookService` already handles this:
    // `String finalUrl = url.contains("?") ? url + "&" + query : url + "?" + query;`
    // So the backend ALREADY supports this.
    
    // Maybe the user wants the UI to reflect this?
    // Or maybe they mean the URL input should be generated from the params?
    
    // Let's assume the user wants to see the *generated* URL.
    // Or maybe they want to REMOVE the manual URL input and only have a "Base URL" input?
    
    // Let's simply save the config as is, because the backend already handles the dynamic construction.
    // But the prompt says "不需要客户设置" (Customer doesn't need to set).
    // "当参数自定义完后自动设置回调url" -> When params are done, URL is auto set.
    
    // Let's update the `saveInterfaceConfig` to NOT require a full URL if params are present?
    // No, we need a destination.
    
    // Maybe the user means: The URL is constructed from the params and displayed?
    // Let's assume the user wants the input field to be updated with the params query string automatically for GET requests.
    
    // However, `interfaceConfig.url` is the TARGET.
    
    // Let's look at the previous prompt: "接口可以自定义增加参数和移动参数位置... 自定义参数支持：时间... 使用者可以自行添加参数"
    // This sounds like configuring the *Format* of the webhook.
    
    // If "不需要客户设置", maybe they mean the URL is derived?
    // Unlikely.
    
    // Let's assume the user simply wants to ensure the URL *includes* the parameters if it's a GET request,
    // automatically updating the input field?
    
    // Let's try to parse the intent: "When params are customized, automatically set the callback URL."
    // This might mean appending the query string to the URL input field.
    
    // Let's implement a computed property or a watcher that updates the URL display?
    // But `interfaceConfig.url` is bound to the input.
    
    // Let's just save. The backend handles it.
    
    // Wait, if the user means "I don't want to type the params in the URL field", 
    // then our current UI (Base URL input + Params list) is exactly that.
    // The backend joins them.
    
    // Maybe the user thinks they HAVE to type the params in the URL field?
    // I should add a helper to auto-append params to the URL view for visualization?
    
    // Let's assume the user wants the URL input to be *purely* the base URL,
    // and the actual call uses base + params.
    // Our backend does exactly this.
    
    // Is there anything missing?
    // "不需要客户设置" -> Maybe hide the URL input? No.
    
    // Let's assume the user wants to *preview* the full URL.
    // I will add a preview of the full URL.
    
    // OR, maybe the user implies that the URL should be *constructed* from the params and saved as the `url` field?
    // If so, `interfaceConfig.url` should be updated before saving.
    
    // Let's try to update the `interfaceConfig.url` if method is GET?
    // No, that duplicates data.
    
    // Let's stick to the current implementation but verify if "自动设置" means something else.
    // "当参数自定义完后自动设置回调url" -> After params are customized, the callback URL is automatically set.
    // This sounds like: User enters "http://site.com", adds param "id", and the system treats the callback as "http://site.com?id=..."
    // This IS what we implemented in backend.
    
    // Maybe the user wants the UI to *show* this behavior?
    // I will add a "Preview URL" section.
    
    const configStr = JSON.stringify(interfaceConfig)
    await apiKeyApi.updateApiKey(currentApiKey.value.id, {
      name: currentApiKey.value.name,
      description: currentApiKey.value.description,
      status: currentApiKey.value.isActive ? 1 : 0,
      webhook_config: configStr
    })
    
    // Update local state
    currentApiKey.value.webhookConfig = JSON.parse(configStr)
    // Also update enableCardEncryption if it was changed in edit modal (although this is saveInterfaceConfig, not saveApiKey)
    // Wait, saveInterfaceConfig only updates webhook_config.
    // saveApiKey updates enable_card_encryption.
    
    const keyIndex = apiKeys.value.findIndex(k => k.id === currentApiKey.value.id)
    if (keyIndex !== -1) {
      apiKeys.value[keyIndex].webhookConfig = JSON.parse(configStr)
    }
    
    ElMessage.success('接口配置已保存')
    showInterfaceModal.value = false
  } catch (error) {
    console.error('Save interface config failed:', error)
    ElMessage.error('保存失败')
  }
}

// Helper methods for UI interactions
const editApiKey = (apiKey) => {
  editingKey.id = apiKey.id
  editingKey.name = apiKey.name
  editingKey.description = apiKey.description
  editingKey.enableCardEncryption = apiKey.enableCardEncryption
  editingKey.requireMachineCode = apiKey.requireMachineCode || false
  editingKey.machineSpecOnceConfig = apiKey.machineSpecOnceConfig || ''
  editingKey.isActive = apiKey.isActive
  showEditModal.value = true
}

const manageUsers = (apiKey) => {
  currentApiKey.value = apiKey
  showUsersModal.value = true
}

const manageCardCodes = (apiKey) => {
  currentApiKey.value = apiKey
  showCardCodesModal.value = true
  fetchCardCodes(apiKey.id)
}

const copyApiKey = async (key) => {
  const success = await copyToClipboard(key)
  if (success) {
    ElMessage.success('API密钥已复制')
  } else {
    ElMessage.error('复制失败')
  }
}

const formatDate = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleString()
}

// Lifecycle
onMounted(() => {
  fetchApiKeys()
  fetchUsers()
})

// Computed
const availableUsers = computed(() => {
  if (!allUsers.value || !Array.isArray(allUsers.value)) {
    return []
  }
  if (!currentApiKey.value.assignedUsers) {
    return allUsers.value
  }
  const assignedUserIds = currentApiKey.value.assignedUsers.map(u => u.id)
  return allUsers.value.filter(user => !assignedUserIds.includes(user.id))
})

const previewUrl = computed(() => {
  let url = interfaceConfig.url || ''
  
  // Force default URL if empty or just to be safe since we forced non-custom
  if (!url) {
    url = generateDefaultUrl()
  }

  if (interfaceConfig.method === 'GET' && interfaceConfig.params.length > 0) {
    // Check if 'api_key' is present in parameters
    const hasApiKeyParam = interfaceConfig.params.some(p => p.type === 'variable' && p.value === 'api_key')
    
    // Adjust URL based on whether API Key is passed in params
    if (hasApiKeyParam) {
       // If API Key is in params, we don't need it in the path
       // Remove the /{api_key}/ part from the URL if it exists
       // Assuming standard format: .../api/custom/{key}/use
       // We change it to: .../api/custom/use
       url = url.replace(/\/api\/custom\/[^/]+\/use/, '/api/custom/use')
    } else {
       // If API Key is NOT in params, we MUST ensure it's in the path
       // If it's currently the generic path, revert to specific path
       if (url.endsWith('/api/custom/use')) {
         const key = currentApiKey.value.key || '{api_key}'
         url = url.replace('/api/custom/use', `/api/custom/${key}/use`)
       }
    }

    const queryParts = interfaceConfig.params.map(p => {
      // 预览时显示真实值或更有意义的占位符
      let val = p.value
      if (p.type === 'variable') {
        if (p.value === 'api_key') {
          val = currentApiKey.value.key || 'YOUR_API_KEY'
        } else if (p.value === 'card_key') {
          val = '{card_key}'
        } else if (p.value === 'machine_code') {
          val = '{machine_code}'
        } else if (p.value === 'client_ip') {
          val = '127.0.0.1'
        } else if (p.value === 'time') {
          val = Math.floor(Date.now() / 1000)
        } else {
          val = `{${p.value}}`
        }
      }
      
      // 如果 key 为空，显示占位符
      const key = p.key || 'key'
      return `${key}=${val}`
    })
    const queryString = queryParts.join('&')
    
    // Check if url already has query params
    if (queryString) {
        return url.includes('?') ? `${url}&${queryString}` : `${url}?${queryString}`
    }
    return url
  }

  return url
})

const previewPostParams = computed(() => {
  if (interfaceConfig.method === 'POST' && interfaceConfig.params.length > 0) {
    const paramsObj = {}
    interfaceConfig.params.forEach(p => {
      paramsObj[p.key] = p.type === 'variable' ? `{${p.value}}` : p.value
    })
    return JSON.stringify(paramsObj, null, 2)
  }
  return ''
})

const previewResponseJson = computed(() => {
  if (!interfaceConfig.response || interfaceConfig.response.length === 0) {
    return JSON.stringify({ success: true, message: 'Card used successfully' }, null, 2)
  }
  
  // Manually construct JSON string to preserve insertion order (standard JSON.stringify sorts integer-like keys)
  const entries = interfaceConfig.response
    .filter(p => p.key) // Only include items with a key
    .map(p => {
      let val = p.value
      if (p.type === 'variable') {
        if (p.value === 'remaining_time') val = '30天0小时0分钟'
        else if (p.value === 'remaining_count') val = '5次'
        else if (p.value === 'card_key') val = 'ABC123XYZ'
        else if (p.value === 'expire_time') val = '2026-01-01 12:00:00'
        else if (p.value === 'card_type') val = '时间卡'
        else if (p.value === 'card_status') val = 'no'
        else if (p.value === 'machine_code') val = 'MC-ABCDEF123456'
        else if (p.value === 'success') val = true
        else if (p.value === 'message') val = '验证成功'
        else if (p.value === 'status_code') {
            const successCode = interfaceConfig.statusCodes && interfaceConfig.statusCodes.find(c => c.key === 'success')
            val = successCode ? successCode.value : '200'
        }
        else val = `{${p.value}}`
      } else {
         if (val === 'true') val = true
         if (val === 'false') val = false
      }
      
      // Use JSON.stringify for the value to handle types (strings, booleans, etc.) correctly
      return `  "${p.key}": ${JSON.stringify(val)}`
    })

  return `{\n${entries.join(',\n')}\n}`
})

const copyPreviewUrl = async () => {
  const content = interfaceConfig.method === 'GET' ? previewUrl.value : previewPostParams.value
  if (!content) return
  
  const success = await copyToClipboard(content)
  if (success) {
    ElMessage.success('内容已复制')
  } else {
    ElMessage.error('复制失败')
  }
}
</script>

<style scoped>
.api-manage-page {
  padding: 0;
  width: 100%;
  box-sizing: border-box;
  overflow-x: auto;
}

.code-examples-modal {
  max-width: min(960px, 96vw);
  width: 100%;
  display: flex;
  flex-direction: column;
  max-height: 86vh;
}

.code-examples-body {
  padding: 1rem 1.25rem 1.25rem;
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.code-examples-intro {
  white-space: pre-line;
  margin: 0 0 0.65rem;
  color: #374151;
  font-size: 0.9rem;
  line-height: 1.5;
}

.code-examples-hint {
  margin: 0 0 1rem;
  font-size: 0.82rem;
  color: #64748b;
  line-height: 1.5;
}

.code-examples-hint code {
  background: #f1f5f9;
  padding: 0.1em 0.35em;
  border-radius: 4px;
  font-size: 0.9em;
}

.code-examples-layout {
  display: flex;
  gap: 0.75rem;
  flex: 1;
  min-height: 0;
  align-items: stretch;
}

.code-examples-lang {
  flex: 0 0 11.5rem;
  max-height: min(52vh, 420px);
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding-right: 0.5rem;
  margin-right: 0.25rem;
  border-right: 1px solid #e5e7eb;
}

.code-lang-btn {
  text-align: left;
  padding: 0.45rem 0.6rem;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  background: #f8fafc;
  cursor: pointer;
  font-size: 0.8rem;
  color: #334155;
  transition: background 0.15s ease, border-color 0.15s ease;
}

.code-lang-btn:hover {
  background: #f1f5f9;
  border-color: #cbd5e1;
}

.code-lang-btn.active {
  background: #eef2ff;
  border-color: #a5b4fc;
  color: #3730a3;
  font-weight: 600;
}

.code-examples-panel {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.code-examples-toolbar-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
  flex-shrink: 0;
}

.code-examples-lang-title {
  font-size: 0.9rem;
  font-weight: 600;
  color: #1e293b;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.btn-code-copy {
  flex-shrink: 0;
  padding: 0.4rem 0.85rem;
  font-size: 0.8rem;
}

.code-examples-pre {
  flex: 1;
  min-height: 180px;
  max-height: min(52vh, 420px);
  margin: 0;
  overflow: auto;
  white-space: pre;
  tab-size: 2;
}

.code-examples-pre code.hljs {
  display: block;
  padding: 0;
  background: transparent !important;
  overflow: visible;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.section-header h2 {
  color: #333;
  margin: 0;
  font-size: 1.5rem;
  font-weight: bold;
}

.btn-primary,
.btn-secondary,
.btn-danger,
.btn-warning {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  font-size: 0.85rem;
  font-weight: 500;
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
  transform: translateY(-1px);
}

.btn-warning {
  background: #f59e0b;
  color: white;
}

.btn-warning:hover {
  background: #d97706;
  transform: translateY(-1px);
}

.btn-danger {
  background: #ef4444;
  color: white;
}

.btn-danger:hover {
  background: #dc2626;
  transform: translateY(-1px);
}

.api-keys-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.api-key-card {
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

.api-key-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  border-color: #d1d5db;
}

.api-key-info {
  flex: 1;
  margin-right: 1rem;
}

.api-key-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.api-key-header h3 {
  margin: 0;
  color: #333;
  font-size: 1.1rem;
}

.type-badge {
  background: #e0e7ff;
  color: #4f46e5;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: bold;
}

.api-key-status {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: bold;
  background: #fee2e2;
  color: #991b1b;
}

.api-key-status.active {
  background: #dcfce7;
  color: #166534;
}

.api-key-value-container {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.api-key-value {
  font-family: 'Courier New', monospace;
  background: #f8f9fa;
  padding: 0.75rem;
  border-radius: 4px;
  font-size: 0.85rem;
  color: #495057;
  flex: 1;
  border: 1px solid #e9ecef;
  word-break: break-all;
}

.copy-btn {
  background: #4f46e5;
  color: white;
  border: none;
  padding: 0.75rem;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.copy-btn:hover {
  background: #4338ca;
  transform: scale(1.05);
}

.api-key-meta {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.8rem;
  color: #666;
}

.meta-item svg {
  color: #667eea;
}

.api-key-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  min-width: 120px;
}

.empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: #666;
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
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
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

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 0.9rem;
  transition: all 0.3s ease;
  box-sizing: border-box;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.permissions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: normal;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  width: auto;
  margin: 0;
}

.modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  padding: 0 1.5rem 1.5rem;
}

@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .api-key-card {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }

  .api-key-info {
    margin-right: 0;
  }

  .api-key-actions {
    flex-direction: row;
    min-width: auto;
  }

  .api-key-value-container {
    flex-direction: column;
    align-items: stretch;
  }

  .modal-content {
    margin: 1rem;
    width: calc(100% - 2rem);
  }
}

/* 新增按钮样式 */
.btn-info {
  background: #0ea5e9;
  color: white;
}

.btn-info:hover {
  background: #0284c7;
  transform: translateY(-1px);
}

.btn-primary:disabled {
  background: #6c757d;
  cursor: not-allowed;
  transform: none;
}

.btn-primary:disabled:hover {
  background: #6c757d;
  transform: none;
  box-shadow: none;
}

/* 大型模态框 */
.large-modal {
  max-width: 800px;
  max-height: 80vh;
  overflow-y: auto;
}

/* 卡密管理样式 */
.card-codes-header {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e9ecef;
}

.card-codes-toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: flex-end;
}

.card-codes-generate-btn {
  flex-shrink: 0;
}

.form-group.inline {
  margin-bottom: 0;
  flex: 1;
  min-width: 120px;
}

.form-group.inline input,
.form-group.inline select {
  width: 100%;
}

/* 专属卡密：与 KeysManagePage 统一的「同机时长叠加」卡片开关 */
.stack-time-stack-group.api-exclusive-stack {
  margin-bottom: 0;
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

/* 接口回调设置：自定义 URL 开关与表单项间距 */
.webhook-url-toggle-card {
  margin-bottom: 0.75rem;
}

/* 必填字段样式 */
.required {
  color: #dc3545;
  font-weight: bold;
}




/* 自定义下拉选择框样式 */
.custom-select-wrapper {
  position: relative;
  display: inline-block;
  width: 100%;
}

.custom-select {
  width: 100%;
  padding: 0.75rem 2.5rem 0.75rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  background: white;
  font-size: 0.9rem;
  color: #495057;
  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;
  cursor: pointer;
  transition: all 0.3s ease;
}

.custom-select:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.custom-select:hover {
  border-color: #007bff;
}

.custom-select option {
  padding: 0.5rem;
  background: white;
  color: #495057;
}

.custom-select option:hover {
  background: #f8f9fa;
}

.select-arrow {
  position: absolute;
  top: 50%;
  right: 0.75rem;
  transform: translateY(-50%);
  pointer-events: none;
  color: #6c757d;
  transition: transform 0.3s ease;
}

.custom-select:focus + .select-arrow {
  transform: translateY(-50%) rotate(180deg);
  color: #007bff;
}

.card-codes-list {
  max-height: 400px;
  overflow-y: auto;
}

.card-code-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 1.2rem;
  border: 1px solid #e9ecef;
  border-radius: 6px;
  margin-bottom: 0.75rem;
  background: #f8f9fa;
  gap: 1rem;
}

.card-code-info {
  flex: 1;
  min-width: 0;
}

.card-code-value {
  font-family: 'Courier New', monospace;
  background: white;
  padding: 0.75rem;
  border-radius: 4px;
  font-size: 0.85rem;
  color: #495057;
  border: 1px solid #dee2e6;
  display: block;
  margin-bottom: 0.75rem;
  word-break: break-all;
  line-height: 1.4;
}

.card-code-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  font-size: 0.8rem;
  color: #666;
  align-items: center;
}

.card-code-meta .status {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-weight: bold;
  font-size: 0.75rem;
}

.card-code-meta .status.unused {
  background: #dcfce7;
  color: #166534;
}

.card-code-meta .status.used {
  background: #dbeafe;
  color: #1e40af;
}

.card-code-meta .status.expired {
  background: #fee2e2;
  color: #991b1b;
}

.card-code-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  flex-shrink: 0;
  min-width: 80px;
}

.copy-btn.small,
.btn-danger.small {
  padding: 0.5rem 0.75rem;
  font-size: 0.75rem;
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
}

.copy-btn.warning {
  background: #f59e0b;
}

.copy-btn.warning:hover {
  background: #d97706;
}

.empty-card-codes,
.empty-users {
  text-align: center;
  padding: 2rem;
  color: #666;
}

.empty-card-codes svg,
.empty-users svg {
  color: #ccc;
  margin-bottom: 0.5rem;
  display: block;
  margin-left: auto;
  margin-right: auto;
}

/* 用户管理样式 */
.users-header {
  display: flex;
  gap: 1rem;
  align-items: end;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e9ecef;
}

.assigned-users-list {
  max-height: 400px;
  overflow-y: auto;
}

.user-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border: 1px solid #e9ecef;
  border-radius: 6px;
  margin-bottom: 0.5rem;
  background: #f8f9fa;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #4f46e5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.2rem;
}

.user-details h4 {
  margin: 0 0 0.25rem 0;
  color: #333;
  font-size: 0.9rem;
}

.user-details p {
  margin: 0 0 0.25rem 0;
  color: #666;
  font-size: 0.8rem;
}

.user-details small {
  color: #999;
  font-size: 0.7rem;
}

.user-actions {
  display: flex;
  gap: 0.5rem;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .card-codes-toolbar,
  .users-header {
    flex-direction: column;
    align-items: stretch;
  }

  .card-codes-generate-btn {
    width: 100%;
  }
  
  .card-code-item,
  .user-item {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }
  
  .card-code-actions {
    flex-direction: row;
    justify-content: flex-end;
    min-width: auto;
  }
  
  .card-code-meta {
    flex-direction: column;
    gap: 0.5rem;
    align-items: flex-start;
  }
  
  .user-info {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }
  
  .large-modal {
    max-width: 95%;
    margin: 1rem;
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

.docs-body {
  padding: 1.5rem;
  max-height: 70vh;
  overflow-y: auto;
}

.doc-section {
  margin-bottom: 2rem;
}

.doc-section h4 {
  margin-top: 0;
  margin-bottom: 0.5rem;
  color: #333;
}

.doc-section h5 {
  margin-top: 1.5rem;
  margin-bottom: 0.8rem;
  color: #555;
  font-size: 1rem;
}

.interface-settings {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  padding: 1rem 0;
}

.method-selector {
  display: flex;
  gap: 2rem;
}

.radio-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
}

.params-config {
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 1rem;
  background: #f9fafb;
}

.params-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.params-header label {
  font-weight: bold;
  color: #374151;
}

.params-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.param-row {
  display: grid;
  grid-template-columns: 2fr 1.5fr 3fr 1.5fr;
  gap: 0.5rem;
  align-items: center;
}

.param-row.header {
  font-weight: bold;
  font-size: 0.85rem;
  color: #6b7280;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 0.5rem;
}

.param-row input,
.param-row select {
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 0.9rem;
  width: 100%;
  box-sizing: border-box;
}

.row-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

.btn-icon {
  background: none;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #6b7280;
  transition: all 0.2s;
}

.btn-icon:hover:not(:disabled) {
  background: #f3f4f6;
  color: #374151;
}

.btn-icon:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.empty-params {
  text-align: center;
  padding: 2rem;
  color: #9ca3af;
  font-style: italic;
  border: 1px dashed #d1d5db;
  border-radius: 4px;
}

.endpoint-box {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  padding: 1rem;
  display: flex;
  align-items: center;
  gap: 0.8rem;
  margin: 1rem 0;
}

.method-badge {
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: bold;
  text-transform: uppercase;
}

.method-badge.post {
  background: #dbeafe;
  color: #1e40af;
}

.method-badge.get {
  background: #dcfce7;
  color: #166534;
}

.url {
  font-family: monospace;
  color: #475569;
  font-size: 0.9rem;
}

.params-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.params-table th,
.params-table td {
  padding: 0.75rem;
  border-bottom: 1px solid #e2e8f0;
  text-align: left;
}

.params-table th {
  background: #f8fafc;
  color: #64748b;
  font-weight: 600;
}

.code-block {
  background: #1e293b;
  color: #e2e8f0;
  padding: 1rem;
  border-radius: 6px;
  overflow-x: auto;
  font-family: monospace;
  font-size: 0.85rem;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 10px;
}

/* 开关样式 */
.switch-container {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}

.switch {
  position: relative;
  display: inline-block;
  width: 44px;
  height: 24px;
}

.switch input { 
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: .4s;
}

.slider:before {
  position: absolute;
  content: "";
  height: 18px;
  width: 18px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: .4s;
  box-shadow: 0 1px 3px rgba(0,0,0,0.3);
}

input:checked + .slider {
  background-color: #2196F3;
}

input:focus + .slider {
  box-shadow: 0 0 1px #2196F3;
}

input:checked + .slider:before {
  transform: translateX(20px);
}

.slider.round {
  border-radius: 34px;
}

.slider.round:before {
  border-radius: 50%;
}

.switch-text {
  font-size: 0.9rem;
  color: #555;
  font-weight: 500;
}

/* 请求方式选择器样式 */
.method-selector-group {
  display: flex;
  gap: 15px;
}

.method-option {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 80px;
  justify-content: center;
  background: white;
}

.method-option:hover {
  border-color: #90caf9;
  background: #f5faff;
}

.method-option.active {
  border-color: #2196F3;
  background: #e3f2fd;
  color: #1976d2;
}

.radio-circle {
  width: 16px;
  height: 16px;
  border: 2px solid #ccc;
  border-radius: 50%;
  position: relative;
  transition: all 0.3s ease;
}

.method-option.active .radio-circle {
  border-color: #2196F3;
}

.method-option.active .radio-circle:after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 8px;
  height: 8px;
  background: #2196F3;
  border-radius: 50%;
}

.method-name {
  font-weight: bold;
  font-size: 0.95rem;
}

.url-preview-section {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #e5e7eb;
}

.url-preview-section label {
  display: block;
  font-weight: bold;
  margin-bottom: 0.5rem;
  color: #333;
}

.preview-box {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  padding: 0.75rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}

.preview-url {
  font-family: monospace;
  color: #475569;
  font-size: 0.9rem;
  word-break: break-all;
  white-space: pre-wrap;
}

.modal-header-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-doc {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.45rem 0.85rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: #2563eb;
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.2s, border-color 0.2s;
}

.btn-doc:hover {
  background: #dbeafe;
  border-color: #93c5fd;
}

.interface-doc-panel {
  display: flex;
  flex-direction: column;
  position: relative;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
  border: 1px solid #e5e7eb;
  overflow: hidden;
  box-sizing: border-box;
}

.interface-doc-panel--fullscreen {
  border-radius: 0;
  border: none;
}

.interface-doc-header {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.65rem 0.75rem;
  background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
  border-bottom: 1px solid #e2e8f0;
  cursor: move;
  user-select: none;
}

.interface-doc-panel--fullscreen .interface-doc-header {
  cursor: default;
}

.interface-doc-title {
  font-weight: 600;
  font-size: 0.95rem;
  color: #1e293b;
}

.interface-doc-toolbar {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.interface-doc-tool-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  padding: 0;
  border: none;
  border-radius: 6px;
  background: transparent;
  color: #64748b;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
}

.interface-doc-tool-btn:hover {
  background: #e2e8f0;
  color: #0f172a;
}

.interface-doc-body {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  padding: 1rem 1.1rem 1.25rem;
  font-size: 0.875rem;
  line-height: 1.55;
  color: #334155;
}

.interface-doc-callout {
  padding: 0.75rem 1rem;
  margin-bottom: 1rem;
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: 6px;
  color: #1e40af;
}

.interface-doc-section {
  margin-bottom: 1.1rem;
}

.interface-doc-section h4 {
  margin: 0 0 0.5rem;
  font-size: 0.95rem;
  color: #0f172a;
}

.interface-doc-section p {
  margin: 0 0 0.5rem;
}

.interface-doc-section ul {
  margin: 0;
  padding-left: 1.25rem;
}

.interface-doc-section li {
  margin-bottom: 0.35rem;
}

.interface-doc-section code {
  font-size: 0.8rem;
  padding: 0.1rem 0.35rem;
  background: #f1f5f9;
  border-radius: 4px;
  color: #0f172a;
}

.interface-doc-muted {
  color: #64748b;
  font-size: 0.8rem;
}

.interface-doc-muted p {
  margin: 0;
}

.interface-doc-resize {
  position: absolute;
  right: 0;
  bottom: 0;
  width: 18px;
  height: 18px;
  cursor: nwse-resize;
  background: linear-gradient(135deg, transparent 50%, #cbd5e1 50%, #cbd5e1 55%, transparent 55%, transparent 65%, #cbd5e1 65%, #cbd5e1 70%, transparent 70%);
  opacity: 0.85;
}
</style>