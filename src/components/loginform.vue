<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <div class="brand-logo">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="logo-icon"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"></path></svg>
        </div>
        <h2>{{ userType === 'admin' ? '管理员登录' : '卡密管理系统' }}</h2>
        <p>请登录您的账号</p>
      </div>

      <form @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label :for="userType + '-username'">
            {{ userType === 'admin' ? '管理员账号' : '用户名/邮箱' }}
          </label>
          <input
            :id="userType + '-username'"
            type="text"
            v-model="loginForm.username"
            :placeholder="userType === 'admin' ? '请输入管理员账号' : '请输入用户名或邮箱'"
            required
            :disabled="loading"
          />
        </div>

        <div class="form-group">
          <label :for="userType + '-password'">密码</label>
          <div class="password-input">
            <input
              :id="userType + '-password'"
              :type="showPassword ? 'text' : 'password'"
              v-model="loginForm.password"
              placeholder="请输入密码"
              required
              :disabled="loading"
            />
            <button
              type="button"
              class="password-toggle"
              @click="showPassword = !showPassword"
              :disabled="loading"
            >
              <svg v-if="showPassword" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
              <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
            </button>
          </div>
          <div class="forgot-password-link">
            <a href="#" @click.prevent="showForgotPassword = true">忘记密码？</a>
          </div>
        </div>

        <div class="form-actions">
          <button
            type="submit"
            class="login-button"
            :disabled="loading || !loginForm.username || !loginForm.password"
          >
            {{ loading ? '登录中...' : '登录' }}
          </button>
        </div>

        <div v-if="userType === 'user'" class="register-link">
          <span>还没有账号？</span>
          <button type="button" @click="showRegister = true" class="link-button">
            立即注册
          </button>
        </div>
      </form>

      <div v-if="errorMessage" class="message error-message">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
        {{ errorMessage }}
      </div>

      <div v-if="successMessage" class="message success-message">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
        {{ successMessage }}
      </div>
    </div>

    <div v-if="showRegister" class="modal-overlay">
      <div class="modal-content">
        <div class="modal-header">
          <h3>用户注册</h3>
          <button class="close-button" @click="showRegister = false">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
          </button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="handleRegister" class="register-form">
            <div class="form-group">
              <label>登录名</label>
              <input type="text" v-model="registerForm.username" required placeholder="设置登录用户名">
            </div>
            <div class="form-group">
              <label>昵称</label>
              <input type="text" v-model="registerForm.nickname" required placeholder="设置显示昵称">
            </div>
            <div class="form-group">
              <label>密码</label>
              <input type="password" v-model="registerForm.password" required placeholder="设置登录密码">
            </div>
            <div class="form-group">
              <label>确认密码</label>
              <input type="password" v-model="registerForm.confirmPassword" required placeholder="再次输入密码">
            </div>
            <div class="form-group">
              <label>手机号</label>
              <input type="tel" v-model="registerForm.phone" required placeholder="输入手机号">
            </div>
            <div class="form-group">
              <label>邮箱</label>
              <input type="email" v-model="registerForm.email" required placeholder="输入邮箱地址">
            </div>
            <div class="form-group">
              <label>验证码</label>
              <div class="code-input-wrapper">
                <input type="text" v-model="registerForm.code" required placeholder="输入邮箱验证码">
                <button type="button" @click="sendCode" :disabled="codeTimer > 0 || !registerForm.email" class="code-btn">
                  {{ codeTimer > 0 ? `${codeTimer}s后重发` : '获取验证码' }}
                </button>
              </div>
            </div>
            
            <div v-if="registerError" class="message error-message">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
              {{ registerError }}
            </div>
            <div v-if="registerSuccess" class="message success-message">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
              {{ registerSuccess }}
            </div>

            <button type="submit" class="login-button" :disabled="registerLoading">
              {{ registerLoading ? '注册中...' : '立即注册' }}
            </button>
          </form>
        </div>
      </div>
    </div>

    <div v-if="showForgotPassword" class="modal-overlay">
      <div class="modal-content">
        <div class="modal-header">
          <h3>找回密码</h3>
          <button class="close-button" @click="showForgotPassword = false">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
          </button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="handleResetPassword" class="register-form">
            <div class="form-group">
              <label>用户名</label>
              <input type="text" v-model="forgotPasswordForm.username" required placeholder="请输入您的用户名">
            </div>
            <div class="form-group">
              <label>邮箱</label>
              <input type="email" v-model="forgotPasswordForm.email" required placeholder="请输入注册时的邮箱">
            </div>
             <div class="form-group">
               <label>验证码</label>
               <div class="code-input-wrapper">
                 <input type="text" v-model="forgotPasswordForm.code" required placeholder="输入邮箱验证码">
                 <button type="button" @click="sendForgotCode" :disabled="forgotCodeTimer > 0 || !forgotPasswordForm.username || !forgotPasswordForm.email" class="code-btn">
                   {{ forgotCodeTimer > 0 ? `${forgotCodeTimer}s后重发` : '获取验证码' }}
                 </button>
               </div>
             </div>
            <div class="form-group">
              <label>新密码</label>
              <input type="password" v-model="forgotPasswordForm.password" required placeholder="设置新密码">
            </div>
            <div class="form-group">
              <label>确认新密码</label>
              <input type="password" v-model="forgotPasswordForm.confirmPassword" required placeholder="再次输入新密码">
            </div>
            
            <div v-if="forgotPasswordError" class="message error-message">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
              {{ forgotPasswordError }}
            </div>
            <div v-if="forgotPasswordSuccess" class="message success-message">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
              {{ forgotPasswordSuccess }}
            </div>

            <button type="submit" class="login-button" :disabled="forgotPasswordLoading">
              {{ forgotPasswordLoading ? '重置中...' : '确认重置' }}
            </button>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, watch, onMounted } from 'vue'
import { authApi } from '../services/api.js'
import { mockLogin } from '../data/mockData.js'

const props = defineProps({
  initialUserType: {
    type: String,
    default: 'user'
  }
})

const userType = ref(props.initialUserType)
const showPassword = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const showRegister = ref(false)
const showForgotPassword = ref(false)

const registerForm = reactive({
  username: '',
  nickname: '',
  password: '',
  confirmPassword: '',
  phone: '',
  email: '',
  code: ''
})

const registerError = ref('')
const registerSuccess = ref('')
const registerLoading = ref(false)
const codeTimer = ref(0)
let timerInterval = null

const sendCode = async () => {
  if (!registerForm.email) {
    registerError.value = '请先输入邮箱'
    return
  }
  
  try {
    const response = await authApi.sendEmailCode(registerForm.email, 'register')
    if (response.success) {
      registerSuccess.value = '验证码已发送，请查收邮件'
      registerError.value = ''
      localStorage.setItem('lastRegisterSendTime_' + registerForm.email, Date.now())
      startTimer()
    } else {
      registerError.value = response.message || '发送失败'
    }
  } catch (error) {
    registerError.value = '发送失败，请稍后重试'
  }
}

const startTimer = (initialValue = 60) => {
  codeTimer.value = initialValue
  if (timerInterval) clearInterval(timerInterval)
  timerInterval = setInterval(() => {
    codeTimer.value--
    if (codeTimer.value <= 0) {
      clearInterval(timerInterval)
    }
  }, 1000)
}

watch(() => registerForm.email, (newEmail) => {
  if (timerInterval) {
    clearInterval(timerInterval)
    codeTimer.value = 0
  }
  if (newEmail) {
    const lastTime = localStorage.getItem('lastRegisterSendTime_' + newEmail)
    if (lastTime) {
      const diff = Math.floor((Date.now() - parseInt(lastTime)) / 1000)
      if (diff < 60) {
        startTimer(60 - diff)
      }
    }
  }
})

const handleRegister = async () => {
  if (registerForm.password !== registerForm.confirmPassword) {
    registerError.value = '两次输入的密码不一致'
    return
  }
  
  registerLoading.value = true
  registerError.value = ''
  registerSuccess.value = ''
  
  try {
    const response = await authApi.register({
      username: registerForm.username,
      nickname: registerForm.nickname,
      password: registerForm.password,
      phone: registerForm.phone,
      email: registerForm.email,
      code: registerForm.code
    })
    
    if (response.success) {
      registerSuccess.value = '注册成功！请登录'
      setTimeout(() => {
        showRegister.value = false
        // Reset form
        Object.keys(registerForm).forEach(key => registerForm[key] = '')
      }, 1500)
    } else {
      registerError.value = response.message || '注册失败'
    }
  } catch (error) {
    registerError.value = '注册请求失败'
  } finally {
    registerLoading.value = false
  }
}

const forgotPasswordForm = reactive({
  username: '',
  email: '',
  code: '',
  password: '',
  confirmPassword: ''
})

const forgotPasswordError = ref('')
const forgotPasswordSuccess = ref('')
const forgotPasswordLoading = ref(false)

const autoDismiss = (messageRef) => {
  let timer = null
  watch(messageRef, (newVal) => {
    if (newVal) {
      if (timer) clearTimeout(timer)
      timer = setTimeout(() => {
        messageRef.value = ''
      }, 3000)
    }
  })
}

[errorMessage, successMessage, registerError, registerSuccess, forgotPasswordError, forgotPasswordSuccess].forEach(autoDismiss)

const forgotCodeTimer = ref(0)
let forgotTimerInterval = null

const sendForgotCode = async () => {
  if (!forgotPasswordForm.username || !forgotPasswordForm.email) {
    forgotPasswordError.value = '请先输入用户名和邮箱'
    return
  }
  
  try {
    const response = await authApi.sendResetCode(forgotPasswordForm.username, forgotPasswordForm.email)
    if (response.success) {
      forgotPasswordSuccess.value = '验证码已发送，请查收邮件'
      forgotPasswordError.value = ''
      localStorage.setItem('lastResetSendTime_' + forgotPasswordForm.email, Date.now())
      startForgotTimer()
    } else {
      forgotPasswordError.value = response.message || '发送失败'
    }
  } catch (error) {
    forgotPasswordError.value = '发送失败: ' + error.message
  }
}

const startForgotTimer = (initialValue = 60) => {
  forgotCodeTimer.value = initialValue
  if (forgotTimerInterval) clearInterval(forgotTimerInterval)
  forgotTimerInterval = setInterval(() => {
    forgotCodeTimer.value--
    if (forgotCodeTimer.value <= 0) {
      clearInterval(forgotTimerInterval)
    }
  }, 1000)
}

watch(() => forgotPasswordForm.email, (newEmail) => {
  if (forgotTimerInterval) {
    clearInterval(forgotTimerInterval)
    forgotCodeTimer.value = 0
  }
  if (newEmail) {
    const lastTime = localStorage.getItem('lastResetSendTime_' + newEmail)
    if (lastTime) {
      const diff = Math.floor((Date.now() - parseInt(lastTime)) / 1000)
      if (diff < 60) {
        startForgotTimer(60 - diff)
      }
    }
  }
})

const handleResetPassword = async () => {
  if (forgotPasswordForm.password !== forgotPasswordForm.confirmPassword) {
    forgotPasswordError.value = '两次输入的密码不一致'
    return
  }
  
  forgotPasswordLoading.value = true
  forgotPasswordError.value = ''
  forgotPasswordSuccess.value = ''
  
  try {
    const response = await authApi.resetPassword({
      username: forgotPasswordForm.username,
      code: forgotPasswordForm.code,
      password: forgotPasswordForm.password
    })
    
    if (response.success) {
      forgotPasswordSuccess.value = '密码重置成功！请使用新密码登录'
      setTimeout(() => {
        showForgotPassword.value = false
        // Reset form
        Object.keys(forgotPasswordForm).forEach(key => forgotPasswordForm[key] = '')
      }, 1500)
    } else {
      forgotPasswordError.value = response.message || '重置失败'
    }
  } catch (error) {
    forgotPasswordError.value = '请求失败: ' + error.message
  } finally {
    forgotPasswordLoading.value = false
  }
}

const loginForm = reactive({
  username: '',
  password: ''
})

watch(userType, () => {
  if (!loginForm.username || !loginForm.password) {
    return
  }
  
  errorMessage.value = ''
  successMessage.value = ''
})

const emit = defineEmits(['login-success'])

const handleLogin = async () => {
  if (!loginForm.username || !loginForm.password) {
    errorMessage.value = '请填写完整的登录信息'
    return
  }

  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    // 调用后端API进行登录
    let response;
    if (userType.value === 'admin') {
      response = await authApi.loginAdmin(loginForm.username, loginForm.password);
    } else {
      response = await authApi.loginUser(loginForm.username, loginForm.password);
    }

    if (response.success) {
      const resultData = response.data;
      successMessage.value = response.message || '登录成功！'
      
      if (resultData && resultData.userInfo) {
        localStorage.setItem('userInfo', JSON.stringify(resultData.userInfo))
        localStorage.setItem('isLoggedIn', 'true')
        if (resultData.token) {
          localStorage.setItem('token', resultData.token);
        }
        if (resultData.refreshToken) {
          localStorage.setItem('refreshToken', resultData.refreshToken);
        }
      }
      
      emit('login-success', {
        userInfo: resultData.userInfo,
        token: resultData.token
      })
      
      setTimeout(() => {
        resetForm()
      }, 1000)
    } else {
      errorMessage.value = response.message || '登录失败，请检查用户名和密码'
    }
  } catch (error) {
    console.error('登录请求失败:', error)
    errorMessage.value = '登录验证失败，请稍后重试'
  } finally {
    loading.value = false
  }
}

const resetForm = () => {
  loginForm.username = ''
  loginForm.password = ''
  errorMessage.value = ''
  successMessage.value = ''
  showPassword.value = false
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  background: #f3f4f6;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  box-sizing: border-box;
}

.login-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  padding: 2.5rem;
  width: 100%;
  max-width: 400px;
}

.login-header {
  text-align: center;
  margin-bottom: 2rem;
}

.brand-logo {
  display: flex;
  justify-content: center;
  margin-bottom: 1rem;
}

.logo-icon {
  width: 40px;
  height: 40px;
  color: #111827;
}

.login-header h2 {
  color: #111827;
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
  font-weight: 700;
  letter-spacing: -0.025em;
}

.login-header p {
  color: #6b7280;
  margin: 0;
  font-size: 0.875rem;
}



.form-group {
  margin-bottom: 1.25rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #374151;
  font-weight: 500;
  font-size: 0.875rem;
}

.form-group input {
  width: 100%;
  padding: 0.625rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 0.875rem;
  transition: all 0.2s;
  box-sizing: border-box;
  background: white;
  color: #111827;
}

.form-group input:focus {
  outline: none;
  border-color: #111827;
  ring: 1px solid #111827;
}

.form-group input:disabled {
  background-color: #f3f4f6;
  cursor: not-allowed;
}

.password-input {
  position: relative;
  display: flex;
}

.password-toggle {
  position: absolute;
  right: 0;
  top: 0;
  height: 100%;
  padding: 0 0.75rem;
  background: transparent;
  border: none;
  color: #6b7280;
  cursor: pointer;
  display: flex;
  align-items: center;
}

.password-toggle svg {
  width: 16px;
  height: 16px;
}

.password-toggle:hover {
  color: #374151;
}

.login-button {
  width: 100%;
  padding: 0.75rem;
  background: #111827;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.login-button:hover:not(:disabled) {
  background: #1f2937;
}

.login-button:disabled {
  background: #9ca3af;
  cursor: not-allowed;
}

.register-link {
  margin-top: 1.5rem;
  text-align: center;
  font-size: 0.875rem;
  color: #6b7280;
}

.forgot-password-link {
  text-align: right;
  margin-top: 0.5rem;
}

.forgot-password-link a {
  color: #6b7280;
  font-size: 0.875rem;
  text-decoration: none;
}

.forgot-password-link a:hover {
  color: #374151;
  text-decoration: underline;
}

.link-button {
  background: none;
  border: none;
  color: #111827;
  cursor: pointer;
  text-decoration: none;
  font-size: 0.875rem;
  font-weight: 600;
  margin-left: 0.25rem;
  padding: 0;
}

.link-button:hover {
  text-decoration: underline;
}

.message {
  padding: 0.75rem;
  border-radius: 4px;
  margin-top: 1.5rem;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.message svg {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

.error-message {
  background: #fef2f2;
  color: #b91c1c;
  border: 1px solid #fecaca;
}

.success-message {
  background: #ecfdf5;
  color: #047857;
  border: 1px solid #a7f3d0;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}

.modal-content {
  background: white;
  border-radius: 4px;
  width: 100%;
  max-width: 400px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.modal-header {
  padding: 1rem 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h3 {
  margin: 0;
  color: #111827;
  font-size: 1.1rem;
  font-weight: 600;
}

.close-button {
  background: none;
  border: none;
  cursor: pointer;
  color: #6b7280;
  padding: 0.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
}

.close-button:hover {
  background: #f3f4f6;
  color: #111827;
}

.close-button svg {
  width: 20px;
  height: 20px;
}

.modal-body {
  padding: 1.5rem;
}

.modal-body p {
  margin: 0 0 0.5rem 0;
  color: #4b5563;
  line-height: 1.5;
  font-size: 0.9rem;
}

.modal-footer {
  padding: 1rem 1.5rem;
  display: flex;
  justify-content: flex-end;
  border-top: 1px solid #e5e7eb;
  background: #f9fafb;
}

.button {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
  font-weight: 500;
  background: white;
  color: #374151;
  transition: all 0.2s;
}

.button:hover {
  background: #f3f4f6;
  border-color: #9ca3af;
}

@media (max-width: 480px) {
  .login-card {
    padding: 1.5rem;
  }
}

.code-input-wrapper {
  display: flex;
  gap: 0.5rem;
}

.code-btn {
  white-space: nowrap;
  padding: 0 1rem;
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
  color: #374151;
  transition: all 0.2s;
}

.code-btn:hover:not(:disabled) {
  background: #e5e7eb;
}

.code-btn:disabled {
  color: #9ca3af;
  cursor: not-allowed;
  background: #f9fafb;
}

.register-form .form-group {
  margin-bottom: 1rem;
}
</style>