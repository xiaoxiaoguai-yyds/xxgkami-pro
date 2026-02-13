import { ElMessage, ElMessageBox } from 'element-plus'

// API服务配置
// 优先使用环境变量中的配置，如果没有则根据环境自动判断
// 开发环境使用 http://localhost:8080/api
// 生产环境使用 /api (通过Nginx反向代理)
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';
let isRefreshing = false;
let failedQueue = [];

const processQueue = (error, token = null) => {
  failedQueue.forEach(prom => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(token);
    }
  });
  failedQueue = [];
};

/**
 * 通用的API请求函数
 */
async function apiRequest(endpoint, options = {}) {
  const url = `${API_BASE_URL}${endpoint}`;
  
  // Get token from storage
  const token = localStorage.getItem('token');
  
  const defaultOptions = {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { 'Authorization': `Bearer ${token}` } : {})
    },
  };

  const config = { ...defaultOptions, ...options };
  // Merge headers carefully
  config.headers = { ...defaultOptions.headers, ...options.headers };

  // If body is FormData, let the browser set the Content-Type header
  if (options.body instanceof FormData) {
    delete config.headers['Content-Type'];
  }

  try {
    const response = await fetch(url, config);
    
    if (response.status === 401) {
       if (endpoint.includes('/login') || endpoint.includes('/refresh')) {
           throw new Error('Authentication failed');
       }

       if (isRefreshing) {
         return new Promise((resolve, reject) => {
           failedQueue.push({ resolve, reject });
         }).then(newToken => {
           config.headers['Authorization'] = `Bearer ${newToken}`;
           return fetch(url, config).then(res => res.json());
         });
       }

       isRefreshing = true;
       const refreshToken = localStorage.getItem('refreshToken');
       
       if (!refreshToken) {
           isRefreshing = false;
           throw new Error('No refresh token available');
       }

       try {
           const refreshResponse = await fetch(`${API_BASE_URL}/auth/refresh`, {
               method: 'POST',
               headers: { 'Content-Type': 'application/json' },
               body: JSON.stringify({ refreshToken })
           });

           const refreshData = await refreshResponse.json();

           if (refreshData.success) {
               const newToken = refreshData.data.token;
               localStorage.setItem('token', newToken);
               if (refreshData.data.refreshToken) {
                   localStorage.setItem('refreshToken', refreshData.data.refreshToken);
               }
               
               processQueue(null, newToken);
               isRefreshing = false;
               
               // Retry original request
               config.headers['Authorization'] = `Bearer ${newToken}`;
               const retryResponse = await fetch(url, config);
               return await retryResponse.json();
           } else {
               throw new Error('Refresh failed');
           }
       } catch (refreshError) {
           processQueue(refreshError, null);
           isRefreshing = false;
           // Clear auth data
           const storedUserInfo = localStorage.getItem('userInfo');
           let isAdmin = false;
           if (storedUserInfo) {
               try {
                   const u = JSON.parse(storedUserInfo);
                   if (u.role === 'admin') isAdmin = true;
               } catch (e) {}
           }

           localStorage.removeItem('token');
           localStorage.removeItem('refreshToken');
           localStorage.removeItem('user');
           localStorage.removeItem('userInfo');
           localStorage.removeItem('isLoggedIn');
           
           // Show popup and redirect
           ElMessageBox.alert('当前登录已过期，请重新登录', '登录过期', {
             confirmButtonText: '确定',
             type: 'warning',
             showClose: false,
             callback: () => {
                // If admin, go to admin login (via reload or specific path)
                // App.vue will handle routing based on URL
                if (isAdmin) {
                    // Ensure we are on an admin path so App.vue redirects to admin login
                    if (!window.location.hash.includes('admin') && !window.location.pathname.includes('admin')) {
                         window.location.href = '/#/admin';
                    }
                    window.location.reload();
                } else {
                    // User -> Home
                    window.location.href = '/';
                }
             }
           });
           
           // Throw to stop execution
           throw refreshError;
       }
    }

    if (!response.ok) {
      let errorMsg = `HTTP error! status: ${response.status}`;
      try {
        const errorText = await response.text();
        if (errorText) {
          try {
             const errorJson = JSON.parse(errorText);
             if (errorJson.message) errorMsg = errorJson.message;
             else errorMsg = errorText;
          } catch (e) {
             errorMsg = errorText;
          }
        }
      } catch (e) {
        // ignore
      }
      throw new Error(errorMsg);
    }
    
    // Check content type before parsing JSON
    const contentType = response.headers.get("content-type");
    if (contentType && contentType.includes("application/json")) {
      return await response.json();
    } else {
      // For non-JSON responses (like simple strings), return text
      return await response.text();
    }
  } catch (error) {
    console.error('API request failed:', error);
    throw error;
  }
}

/**
 * 认证API服务
 */
export const authApi = {
  /**
   * 管理员登录
   */
  async loginAdmin(username, password, totpCode) {
    return await apiRequest('/auth/admin/login', {
      method: 'POST',
      body: JSON.stringify({ username, password, totpCode })
    });
  },

  /**
   * 用户登录
   */
  async loginUser(username, password) {
    return await apiRequest('/auth/user/login', {
      method: 'POST',
      body: JSON.stringify({ username, password })
    });
  },

  /**
   * 发送邮箱验证码
   */
  async sendEmailCode(email, type = 'register') {
    return await apiRequest('/auth/email-code', {
      method: 'POST',
      body: JSON.stringify({ email, type })
    });
  },

  /**
   * 用户注册
   */
  async register(data) {
    return await apiRequest('/auth/register', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  /**
   * 绑定注册
   */
  async registerBind(data) {
    return await apiRequest('/auth/register-bind', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  async logout(id, role) {
    return await apiRequest('/auth/logout', {
      method: 'POST',
      body: JSON.stringify({ id, role })
    });
  },

  async updateAdmin(data) {
    return await apiRequest('/auth/admin/update', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  /**
   * 获取当前用户信息
   */
  async getUserInfo() {
    return await apiRequest('/auth/user/info');
  },

  /**
   * 获取TOTP配置信息
   */
  async setupTotp(id) {
    return await apiRequest('/auth/totp/setup', {
      method: 'POST',
      body: JSON.stringify({ id })
    });
  },

  /**
   * 启用TOTP
   */
  async enableTotp(id, secret, code) {
    return await apiRequest('/auth/totp/enable', {
      method: 'POST',
      body: JSON.stringify({ id, secret, code })
    });
  },

  /**
   * 禁用TOTP
   */
  async disableTotp(id) {
    return await apiRequest('/auth/totp/disable', {
      method: 'POST',
      body: JSON.stringify({ id })
    });
  },

  /**
   * 发送重置密码验证码
   */
  async sendResetCode(username, email) {
    return await apiRequest('/auth/reset-code', {
      method: 'POST',
      body: JSON.stringify({ username, email })
    });
  },

  /**
   * 重置密码
   */
  async resetPassword(data) {
    return await apiRequest('/auth/reset-password', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  /**
   * 发送TOTP恢复验证码
   */
  async sendRecoveryCode(username) {
    return await apiRequest('/auth/totp/recovery-code', {
      method: 'POST',
      body: JSON.stringify({ username })
    });
  },

  /**
   * 通过恢复码禁用TOTP
   */
  async disableTotpByRecovery(username, code) {
    return await apiRequest('/auth/totp/disable-by-recovery', {
      method: 'POST',
      body: JSON.stringify({ username, code })
    });
  }
};

/**
 * 系统监控API服务
 */
export const monitorApi = {
  /**
   * 获取数据库状态
   */
  async getDatabaseStatus() {
    return await apiRequest('/monitor/database');
  },

  /**
   * 获取系统资源状态
   */
  async getSystemStatus() {
    return await apiRequest('/monitor/system');
  },

  /**
   * 获取API服务状态
   */
  async getApiStatus() {
    return await apiRequest('/monitor/api');
  },

  /**
   * 获取在线用户信息
   */
  async getOnlineUsers() {
    return await apiRequest('/monitor/users');
  },

  /**
   * 获取所有监控数据
   */
  async getAllMonitorData() {
    return await apiRequest('/monitor/all');
  }
};

/**
 * 用户管理API服务 (管理员)
 */
export const userApi = {
  // 获取用户列表 (分页, 搜索)
  async getUsers(page = 1, size = 10, keyword = '') {
    const params = new URLSearchParams({ page, size });
    if (keyword) params.append('keyword', keyword);
    return await apiRequest(`/admin/users?${params.toString()}`);
  },

  // 创建用户
  async createUser(userData) {
    return await apiRequest('/admin/users', {
      method: 'POST',
      body: JSON.stringify(userData)
    });
  },

  // 更新用户
  async updateUser(id, userData) {
    return await apiRequest(`/admin/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(userData)
    });
  },

  // 删除用户
  async deleteUser(id) {
    return await apiRequest(`/admin/users/${id}`, {
      method: 'DELETE'
    });
  },

  // 更新用户状态
  async updateUserStatus(id, status) {
    return await apiRequest(`/admin/users/${id}/status`, {
      method: 'PUT',
      body: JSON.stringify({ status })
    });
  }
};

/**
 * 在线用户管理API服务
 */
export const onlineUserApi = {
  /**
   * 用户上线
   */
  async userLogin(userId, username, nickname) {
    return await apiRequest('/online/login', {
      method: 'POST',
      body: JSON.stringify({
        userId: userId.toString(),
        username,
        nickname
      })
    });
  },

  /**
   * 用户下线
   */
  async userLogout(userId) {
    return await apiRequest('/online/logout', {
      method: 'POST',
      body: JSON.stringify({
        userId: userId.toString()
      })
    });
  },

  /**
   * 发送心跳，更新用户活动时间
   */
  async sendHeartbeat(userId) {
    return await apiRequest('/online/heartbeat', {
      method: 'POST',
      body: JSON.stringify({
        userId: userId.toString()
      })
    });
  },

  /**
   * 检查用户是否在线
   */
  async checkUserOnline(userId) {
    return await apiRequest(`/online/check/${userId}`);
  },

  /**
   * 获取在线用户列表
   */
  async getOnlineUsers() {
    return await apiRequest('/online/list');
  }
};

/**
 * 卡密管理API服务
 */
export const cardApi = {
  /**
   * 批量创建卡密
   */
  async createCards(data) {
    return await apiRequest('/cards/admin/create', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  /**
   * 获取所有卡密
   */
  async getAllCards() {
    return await apiRequest('/cards/admin/all');
  },

  /**
   * 获取指定API Key的卡密
   */
  async getApiKeyCards(apiKeyId) {
    return await apiRequest(`/cards/apikey/${apiKeyId}`);
  },

  /**
   * 获取卡密使用趋势
   */
  async getUsageTrend(days = 7) {
    return await apiRequest(`/cards/trend?days=${days}`);
  },

  /**
   * 使用卡密
   */
  async useCard(cardKey, deviceId = 'Unknown', ipAddress = '') {
    return await apiRequest('/cards/use', {
      method: 'POST',
      body: JSON.stringify({ 
        card_key: cardKey,
        device_id: deviceId,
        ip_address: ipAddress
      })
    });
  },

  /**
   * 获取用户的卡密
   */
  async getUserCards(userId) {
    return await apiRequest(`/cards/user/${userId}`);
  },

  /**
   * 删除卡密
   */
  async deleteCard(cardId) {
    return await apiRequest(`/cards/${cardId}`, {
      method: 'DELETE'
    });
  }
};

/**
 * 系统设置API服务
 */
export const settingsApi = {
  /**
   * 获取所有设置
   */
  async getAllSettings() {
    return await apiRequest('/settings/all');
  },

  /**
   * 批量保存设置
   */
  async saveSettings(settings) {
    return await apiRequest('/settings/save', {
      method: 'POST',
      body: JSON.stringify(settings)
    });
  },

  /**
   * 发送测试邮件
   */
  async sendTestEmail(to, settings = {}) {
    return await apiRequest('/settings/email/test', {
      method: 'POST',
      body: JSON.stringify({ to, ...settings })
    });
  }
};

/**
 * 用户统计API服务
 */
export const statsApi = {
  /**
   * 获取仪表盘统计数据
   */
  async getDashboardStats() {
    return await apiRequest('/stats/dashboard');
  },

  /**
   * 获取用户活跃度统计
   */
  async getUserActivityStats(period = '7d') {
    let days = period;
    // 如果传入的是 '7d' 格式，提取数字
    if (typeof period === 'string' && period.endsWith('d')) {
        days = period.replace('d', '');
    }
    return await apiRequest(`/stats/user-activity?days=${days}`);
  },

  /**
   * 获取卡片使用趋势
   */
  async getCardUsageTrends(period = '7') {
    const days = parseInt(period);
    return await apiRequest(`/cards/trend?days=${days}`);
  }
};

/**
 * 订单API服务
 */
export const orderApi = {
  /**
   * 创建订单
   */
  async createOrder(data) {
    return await apiRequest('/orders', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  /**
   * 获取用户订单列表
   * @param {number} userId 
   */
  async getOrders(userId) {
    return await apiRequest(`/orders?userId=${userId}`);
  },

  /**
   * 获取所有订单（管理员）
   */
  async getAllOrders(params = {}) {
    // Filter out empty params
    const queryParams = {};
    Object.keys(params).forEach(key => {
        if (params[key] !== null && params[key] !== '' && params[key] !== undefined) {
            queryParams[key] = params[key];
        }
    });
    const queryString = new URLSearchParams(queryParams).toString();
    return await apiRequest(`/orders/admin/all?${queryString}`);
  },

  /**
   * 更新订单状态（管理员）
   */
  async updateOrderStatus(orderNo, status) {
    return await apiRequest('/orders/admin/updateStatus', {
      method: 'POST',
      body: JSON.stringify({ orderNo, status })
    });
  }
};

/**
 * API Key管理服务
 */
export const apiKeyApi = {
  async getAllApiKeys() {
    return await apiRequest('/admin/apikeys');
  },

  async createApiKey(data) {
    return await apiRequest('/admin/apikeys', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  async updateApiKey(id, data) {
    return await apiRequest(`/admin/apikeys/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data)
    });
  },

  async deleteApiKey(id) {
    return await apiRequest(`/admin/apikeys/${id}`, {
      method: 'DELETE'
    });
  },

  async assignUser(id, userId) {
    return await apiRequest(`/admin/apikeys/${id}/users`, {
      method: 'POST',
      body: JSON.stringify({ userId })
    });
  },

  async unassignUser(id, userId) {
    return await apiRequest(`/admin/apikeys/${id}/users/${userId}`, {
      method: 'DELETE'
    });
  },

  async getAllUsers() {
    return await apiRequest('/admin/users');
  }
};

/**
 * 卡密定价API服务
 */
export const pricingApi = {
  getAllPricing() {
    return apiRequest('/pricing');
  },
  
  addPricing(data) {
    return apiRequest('/pricing', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },
  
  updatePricing(id, data) {
    return apiRequest(`/pricing/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data)
    });
  },
  
  deletePricing(id) {
    return apiRequest(`/pricing/${id}`, {
      method: 'DELETE'
    });
  }
};

/**
 * 用户个人信息API服务
 */
export const userProfileApi = {
  /**
   * 获取个人信息
   */
  async getProfile() {
    return await apiRequest('/user/profile');
  },

  /**
   * 更新个人信息
   */
  async updateProfile(data) {
    return await apiRequest('/user/profile', {
      method: 'PUT',
      body: JSON.stringify(data)
    });
  },

  /**
   * 上传头像
   */
  async uploadAvatar(file) {
    const formData = new FormData();
    formData.append('file', file);
    return await apiRequest('/user/avatar', {
      method: 'POST',
      body: formData
    });
  },

  /**
   * 修改密码
   */
  async changePassword(oldPassword, newPassword) {
    return await apiRequest('/user/password', {
      method: 'POST',
      body: JSON.stringify({ oldPassword, newPassword })
    });
  },

  /**
   * 获取社交账号绑定列表
   */
  async getSocialBindings() {
    return await apiRequest('/user/social');
  },

  /**
   * 绑定社交账号
   */
  async bindSocial(token) {
    return await apiRequest('/user/social/bind', {
      method: 'POST',
      body: JSON.stringify({ token })
    });
  },

  /**
   * 解绑社交账号
   */
  async unbindSocial(type) {
    return await apiRequest('/user/social/unbind', {
      method: 'POST',
      body: JSON.stringify({ type })
    });
  }
};

/**
 * 系统维护API服务
 */
export const maintenanceApi = {
  /**
   * 获取维护状态
   */
  async getStatus() {
    return await apiRequest('/maintenance/status');
  },

  /**
   * 更新维护设置
   */
  async updateSettings(settings) {
    return await apiRequest('/maintenance/update', {
      method: 'POST',
      body: JSON.stringify(settings)
    });
  },

  /**
   * 创建备份
   */
  async createBackup() {
    return await apiRequest('/backup/create', {
        method: 'POST'
    });
  },

  /**
   * 清理缓存
   */
  async clearCache() {
    return await apiRequest('/maintenance/clear-cache', {
        method: 'POST'
    });
  },

  /**
   * 清理日志
   */
  async clearLogs() {
    return await apiRequest('/maintenance/clear-logs', {
        method: 'POST'
    });
  }
};

/**
 * 支付API服务
 */
export const paymentApi = {
  /**
   * 发起支付
   */
  async createPayment(data) {
    return await apiRequest('/payment/pay', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  }
};

export default {
  authApi,
  monitorApi,
  onlineUserApi,
  cardApi,
  settingsApi,
  statsApi,
  orderApi,
  apiKeyApi,
  userApi,
  userProfileApi,
  maintenanceApi,
  pricingApi,
  paymentApi
};