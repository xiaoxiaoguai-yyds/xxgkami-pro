<template>
  <div class="settings-page">
    <div class="settings-header">
      <h2>系统设置</h2>
      <p>管理您的系统配置和偏好设置</p>
    </div>

    <div class="settings-sections">
      <!-- 基本设置 -->
      <div class="settings-section" id="settings-basic">
        <div class="section-title">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
          <h3>基本设置</h3>
        </div>
        <div class="settings-grid">
          <div class="setting-item">
            <label>系统名称</label>
            <input type="text" v-model="settings.systemName" placeholder="请输入系统名称" />
          </div>
          <div class="setting-item">
            <label>系统描述</label>
            <textarea v-model="settings.systemDescription" rows="3" placeholder="请输入系统描述"></textarea>
          </div>
          <div class="setting-item">
            <label>默认语言</label>
            <select v-model="settings.defaultLanguage">
              <option value="zh-CN">简体中文</option>
              <option value="en-US">English</option>
              <option value="ja-JP">日本語</option>
            </select>
          </div>
          <div class="setting-item">
            <label>站点地址 (URL) <span class="required">*</span></label>
            <input type="text" v-model="settings.site_url" placeholder="例如: http://www.example.com" />
            <small class="help-text">请填写您的公网域名或IP，用于支付回调跳转，请勿以/结尾</small>
          </div>
          <div class="setting-item">
            <label>时区设置</label>
            <select v-model="settings.timezone">
              <option value="Asia/Shanghai">亚洲/上海 (GMT+8)</option>
              <option value="America/New_York">美洲/纽约 (GMT-5)</option>
              <option value="Europe/London">欧洲/伦敦 (GMT+0)</option>
            </select>
          </div>
        </div>
      </div>

      <!-- 数据库设置 -->
      <div class="settings-section" id="settings-database">
        <div class="section-title">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"></ellipse><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"></path><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"></path></svg>
          <h3>数据库设置</h3>
        </div>
        <div class="settings-grid">
          <div class="setting-item">
            <label class="switch-label">
              <span>自动备份</span>
              <label class="switch">
                <input type="checkbox" v-model="settings.autoBackup" />
                <span class="slider"></span>
              </label>
            </label>
          </div>
          <div class="setting-item" v-if="settings.autoBackup">
            <label>自动备份接口 (GET/POST)</label>
            <div class="input-with-copy">
              <input type="text" :value="backupApiUrl" readonly />
              <button class="btn-icon" @click="copyToClipboard(backupApiUrl)" title="复制链接">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
              </button>
            </div>
            <small class="help-text warning-text">请在宝塔配置定时任务，若使用其他系统，请根据您设置的频率配置定时任务</small>
          </div>
          <div class="setting-item">
            <label>备份频率</label>
            <select v-model="settings.backupFrequency" :disabled="!settings.autoBackup">
              <option value="daily">每日</option>
              <option value="weekly">每周</option>
              <option value="monthly">每月</option>
            </select>
          </div>
          <div class="setting-item">
            <label>保留备份数量</label>
            <input type="number" v-model="settings.backupRetention" min="1" max="30" :disabled="!settings.autoBackup" />
          </div>
          <div class="setting-item">
            <label class="switch-label">
              <span>数据压缩</span>
              <label class="switch">
                <input type="checkbox" v-model="settings.dataCompression" />
                <span class="slider"></span>
              </label>
            </label>
          </div>
        </div>
      </div>

      <!-- 支付设置 -->
      <div class="settings-section" id="settings-payment">
        <div class="section-title">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
          <h3>支付设置 (易支付)</h3>
        </div>
        <div class="settings-grid">
          <div class="setting-item">
            <label class="switch-label">
              <span>启用支付</span>
              <label class="switch">
                <input type="checkbox" v-model="settings.payment_enabled" true-value="true" false-value="false" />
                <span class="slider"></span>
              </label>
            </label>
          </div>
          <div class="setting-item">
            <label>接口地址</label>
            <input type="text" v-model="settings.epay_api_url" placeholder="例如: https://pay.myzfw.com/submit.php" />
          </div>
          <div class="setting-item">
            <label>商户ID (PID)</label>
            <input type="text" v-model="settings.epay_pid" placeholder="请输入商户ID" />
          </div>
          <div class="setting-item">
            <label>商户密钥 (Key)</label>
            <input type="password" v-model="settings.epay_key" placeholder="请输入商户密钥" />
          </div>
        </div>
      </div>

      <!-- 登录验证 -->
      <div class="settings-section" id="settings-login">
        <div class="section-title">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
          <h3>登录验证</h3>
        </div>
        <div class="settings-grid">
          <div class="setting-item">
            <label class="switch-label">
              <span>QQ登录</span>
              <label class="switch">
                <input type="checkbox" v-model="settings.qqLogin" />
                <span class="slider"></span>
              </label>
            </label>
          </div>
          <div class="setting-item">
            <div class="switch-label">
              <span>Authenticator登录</span>
              <div class="switch-group">
                <button class="btn-text" @click="handleConfigureTotp">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                  配置
                </button>
                <label class="switch">
                  <input type="checkbox" v-model="settings.authenticatorLogin" />
                  <span class="slider"></span>
                </label>
              </div>
            </div>
          </div>
          <div class="setting-item">
            <div class="switch-label">
              <span>聚合登录</span>
              <div class="switch-group">
                <button class="btn-text" @click="handleConfigureOAuth">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                  配置
                </button>
                <label class="switch">
                  <input type="checkbox" v-model="settings.aggregatedLogin" />
                  <span class="slider"></span>
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 系统维护 -->
      <div class="settings-section" id="settings-maintenance">
        <div class="section-title">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 0-.6 1.5v2.12h2.12a2.12 2.12 0 0 0 1.5-.6l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.78z"></path></svg>
          <h3>系统维护</h3>
        </div>
        <div class="maintenance-actions">
          <div class="action-card">
            <div class="action-info">
              <h4>清理系统缓存</h4>
              <p>清理临时文件和缓存数据，释放存储空间</p>
            </div>
            <button class="btn-secondary" @click="clearCache">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
              清理缓存
            </button>
          </div>
          <div class="action-card">
            <div class="action-info">
              <h4>系统日志清理</h4>
              <p>清理过期的系统日志文件</p>
            </div>
            <button class="btn-secondary" @click="clearLogs">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
              清理日志
            </button>
          </div>
          <div class="action-card">
            <div class="action-info">
              <h4>手动备份</h4>
              <p>立即创建系统数据备份</p>
            </div>
            <button class="btn-primary" @click="createBackup">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
              创建备份
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 保存按钮 -->
    <div class="settings-footer">
      <button class="btn-secondary" @click="resetSettings">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"></path></svg>
        重置设置
      </button>
      <button class="btn-primary" @click="saveSettings">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
        保存设置
      </button>
    </div>

    <!-- Authenticator Setup Dialog -->
    <el-dialog
      v-model="showTotpDialog"
      title="配置 Authenticator"
      width="400px"
      append-to-body
    >
      <div v-if="totpStep === 'setup'" class="totp-setup">
        <p class="step-text">1. 请使用 Google Authenticator 或其他应用扫描下方二维码：</p>
        <div class="qr-code-container">
          <img :src="totpQrCode" alt="QR Code" v-if="totpQrCode" />
        </div>
        <div class="secret-text">
            <span>密钥:</span>
            <code>{{ totpSecret }}</code>
            <button class="btn-icon-small" @click="copyToClipboard(totpSecret)" title="复制密钥">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
            </button>
        </div>
        <p class="step-text">2. 输入应用生成的6位验证码：</p>
        <div class="code-input">
          <el-input v-model="totpCode" placeholder="请输入6位验证码" maxlength="6" />
        </div>
        <div class="dialog-footer">
            <el-button @click="showTotpDialog = false">取消</el-button>
            <el-button type="primary" @click="enableTotp" :loading="totpLoading" :disabled="totpCode.length !== 6">启用</el-button>
        </div>
      </div>
      <div v-else-if="totpStep === 'manage'" class="totp-manage">
        <el-result
          icon="success"
          title="已启用"
          sub-title="您的账户已启用 Authenticator 两步验证"
        >
          <template #extra>
            <el-button type="danger" @click="disableTotp" :loading="totpLoading">禁用 Authenticator</el-button>
          </template>
        </el-result>
      </div>
      <div v-else class="loading-container">
          <el-icon class="is-loading"><Loading /></el-icon> 加载中...
      </div>
    </el-dialog>
    <!-- OAuth Configuration Dialog -->
    <el-dialog
      v-model="showOAuthDialog"
      title="配置聚合登录"
      width="500px"
      append-to-body
    >
      <div class="settings-grid single-column">
          <div class="setting-item">
            <label>聚合登录网址</label>
            <input type="text" v-model="settings.oauth_url" placeholder="例如: https://baoxian18.com" />
          </div>
          <div class="setting-item">
            <label>AppID</label>
            <input type="text" v-model="settings.oauth_appid" placeholder="请输入AppID" />
          </div>
          <div class="setting-item">
            <label>AppKey</label>
            <input type="password" v-model="settings.oauth_appkey" placeholder="请输入AppKey" />
          </div>
          <div class="setting-item">
            <label>回调域名</label>
            <input type="text" v-model="settings.oauth_callback_domain" placeholder="例如: http://www.example.com" />
            <small class="help-text">请填写您的网站域名，用于接收登录回调。回调地址为：{{ settings.oauth_callback_domain }}/api/oauth/callback</small>
          </div>
          <div class="setting-item">
            <label>启用登录方式</label>
            <div class="checkbox-group">
              <label class="checkbox-label"><input type="checkbox" v-model="oauthTypes.qq" /> QQ</label>
              <label class="checkbox-label"><input type="checkbox" v-model="oauthTypes.wx" /> 微信</label>
              <label class="checkbox-label"><input type="checkbox" v-model="oauthTypes.alipay" /> 支付宝</label>
            </div>
          </div>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showOAuthDialog = false">取消</el-button>
          <el-button type="primary" @click="showOAuthDialog = false">确定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { settingsApi, maintenanceApi, authApi } from '../services/api.js'

const props = defineProps({
  userInfo: Object
})

const emit = defineEmits(['save-settings', 'clear-cache', 'clear-logs', 'create-backup'])

// TOTP State
const showTotpDialog = ref(false)
const showOAuthDialog = ref(false)

const handleConfigureOAuth = () => {
    showOAuthDialog.value = true;
}

const totpStep = ref('loading') // loading, setup, manage
const totpQrCode = ref('')
const totpSecret = ref('')
const totpCode = ref('')
const totpLoading = ref(false)

const handleConfigureTotp = async () => {
    showTotpDialog.value = true;
    totpStep.value = 'loading';
    totpCode.value = '';
    
    // Check if already enabled
    if (props.userInfo && props.userInfo.totpEnabled) {
        totpStep.value = 'manage';
    } else {
        await fetchTotpSetup();
    }
}

const fetchTotpSetup = async () => {
    try {
        if (!props.userInfo || !props.userInfo.id) {
             showToast('用户信息获取失败', 'error');
             // showTotpDialog.value = false; // Don't close, let user see error
             return;
        }
        const res = await authApi.setupTotp(props.userInfo.id);
        if (res.success) {
            totpSecret.value = res.data.secret;
            totpQrCode.value = res.data.qrCode;
            totpStep.value = 'setup';
        } else {
            showToast(res.message || '获取配置失败', 'error');
        }
    } catch (e) {
        console.error(e);
        showToast('获取配置失败', 'error');
    }
}

const enableTotp = async () => {
    if (!totpCode.value || totpCode.value.length !== 6) return;
    totpLoading.value = true;
    try {
        const res = await authApi.enableTotp(props.userInfo.id, totpSecret.value, totpCode.value);
        if (res.success) {
            showToast('Authenticator 已启用', 'success');
            totpStep.value = 'manage';
            // Update local user info
            if (props.userInfo) props.userInfo.totpEnabled = true;
        } else {
            showToast(res.message || '启用失败', 'error');
        }
    } catch (e) {
         showToast(e.message || '启用失败', 'error');
    } finally {
        totpLoading.value = false;
    }
}

const disableTotp = async () => {
    if (!confirm('确定要禁用 Authenticator 吗？这将降低您的账户安全性。')) return;
    totpLoading.value = true;
    try {
        const res = await authApi.disableTotp(props.userInfo.id);
        if (res.success) {
            showToast('Authenticator 已禁用', 'success');
            // Update local user info
            if (props.userInfo) props.userInfo.totpEnabled = false;
            // Switch to setup mode
             await fetchTotpSetup();
        } else {
             showToast(res.message || '禁用失败', 'error');
        }
    } catch (e) {
        showToast(e.message || '禁用失败', 'error');
    } finally {
        totpLoading.value = false;
    }
}

const settings = reactive({
  // 基本设置
  systemName: 'XXG卡密系统',
  systemDescription: '专业的卡密管理系统',
  defaultLanguage: 'zh-CN',
  timezone: 'Asia/Shanghai',
  site_url: '',
  
  // 数据库设置
  autoBackup: true,
  backupFrequency: 'daily',
  backupRetention: 7,
  dataCompression: true,

  // 支付设置
  payment_enabled: 'true',
  epay_api_url: 'https://pay.myzfw.com/',
  epay_pid: '',
  epay_key: '',
  epay_notify_url: '',
  epay_return_url: '',

  // 登录验证
  qqLogin: false,
  authenticatorLogin: false,
  aggregatedLogin: false,
  
  // 聚合登录设置
  oauth_url: 'https://baoxian18.com',
  oauth_appid: '',
  oauth_appkey: '',
  oauth_callback_domain: '',
  oauth_login_types: ''
})

const oauthTypes = reactive({
  qq: false,
  wx: false,
  alipay: false
})

const backupApiUrl = computed(() => {
  const baseUrl = import.meta.env.VITE_API_BASE_URL || '/api';
  let url;
  if (baseUrl.startsWith('http')) {
    url = `${baseUrl}/backup/create`;
  } else {
    url = `${window.location.origin}${baseUrl}/backup/create`;
  }
  // Ensure no double slashes if baseUrl ends with /
  return url.replace(/([^:]\/)\/+/g, "$1");
})

const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text);
    showToast('链接已复制到剪贴板', 'success');
  } catch (err) {
    console.error('Failed to copy: ', err);
    showToast('复制失败，请手动复制', 'error');
  }
}

const loadSettings = async () => {
  try {
    const res = await settingsApi.getAllSettings()
    if (res.success && res.data) {
      Object.keys(res.data).forEach(key => {
        if (key in settings) {
          if (res.data[key] === 'true') settings[key] = true
          else if (res.data[key] === 'false') settings[key] = false
          else settings[key] = res.data[key]
        }
      })
      
      // Parse oauth types
      if (settings.oauth_login_types) {
        const types = settings.oauth_login_types.split(',')
        Object.keys(oauthTypes).forEach(k => oauthTypes[k] = false)
        types.forEach(t => {
          if (t in oauthTypes) oauthTypes[t] = true
        })
      }
    }
  } catch (error) {
    console.error('Failed to load settings:', error)
  }
}

const saveSettings = async () => {
  try {
    if (!settings.site_url) {
        showToast('请填写站点地址', 'error');
        return;
    }
    // Convert booleans to strings for backend
    const payload = { ...settings }
    payload.autoBackup = String(payload.autoBackup)
    payload.dataCompression = String(payload.dataCompression)
    payload.qqLogin = String(payload.qqLogin)
    payload.authenticatorLogin = String(payload.authenticatorLogin)
    payload.aggregatedLogin = String(payload.aggregatedLogin)
    
    // Construct oauth_login_types string
    const types = []
    if (oauthTypes.qq) types.push('qq')
    if (oauthTypes.wx) types.push('wx')
    if (oauthTypes.alipay) types.push('alipay')

    payload.oauth_login_types = types.join(',')
    
    const res = await settingsApi.saveSettings(payload)
    if (res.success) {
      emit('save-settings', payload)
      showToast('设置已保存', 'success')
    } else {
      showToast(res.message || '保存失败', 'error')
    }
  } catch (error) {
    console.error('Failed to save settings:', error)
    showToast('保存失败: ' + (error.message || '未知错误'), 'error')
  }
}

const resetSettings = () => {
  if (confirm('确定要重置所有设置吗？这将恢复到默认配置。')) {
    // 重置到默认值
    Object.assign(settings, {
      systemName: 'XXG卡密系统',
      systemDescription: '专业的卡密管理系统',
      defaultLanguage: 'zh-CN',
      timezone: 'Asia/Shanghai',
      autoBackup: true,
      backupFrequency: 'daily',
      backupRetention: 7,
      dataCompression: true
    })
    showToast('设置已重置', 'info')
  }
}

const clearCache = async () => {
  try {
    await maintenanceApi.clearCache()
    showToast('缓存清理完成', 'success')
  } catch (error) {
    console.error('Clear cache failed:', error)
    showToast('缓存清理失败', 'error')
  }
}

const clearLogs = async () => {
  try {
    await maintenanceApi.clearLogs()
    showToast('日志清理完成', 'success')
  } catch (error) {
    console.error('Clear logs failed:', error)
    showToast('日志清理失败', 'error')
  }
}

const createBackup = async () => {
  try {
    // Call backend API directly instead of emitting event, or keep event if handled elsewhere?
    // Since we just implemented the API, let's call it here.
    // The previous implementation used emit('create-backup'), which implies the parent handles it.
    // But typically SettingsPage handles its own logic if it has the API.
    // Let's use the API directly for "Manual Backup".
    
    // Check if maintenanceApi has createBackup (we just added it)
    await maintenanceApi.createBackup();
    showToast('备份创建成功', 'success')
  } catch (error) {
    console.error('Backup failed:', error);
    showToast('备份创建失败', 'error')
  }
}

const showToast = (message, type = 'info') => {
  const colors = {
    success: '#28a745',
    info: '#17a2b8',
    warning: '#ffc107',
    error: '#dc3545'
  }
  
  const toast = document.createElement('div')
  toast.textContent = message
  toast.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    background: ${colors[type]};
    color: white;
    padding: 12px 20px;
    border-radius: 6px;
    z-index: 10000;
    animation: slideInRight 0.3s ease;
  `
  document.body.appendChild(toast)
  setTimeout(() => {
    toast.remove()
  }, 3000)
}

// 初始化数据
onMounted(async () => {
  await loadSettings()
})
</script>

<style scoped>

.settings-page {
  padding: 0;
  width: 100%;
  box-sizing: border-box;
  overflow-x: auto;
}

.settings-header {
  margin-bottom: 2rem;
}

.settings-header h2 {
  color: #333;
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
  font-weight: bold;
}

.settings-header p {
  color: #666;
  margin: 0;
  font-size: 0.9rem;
}

.settings-sections {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.settings-section {
  background: white;
  border-radius: 6px;
  padding: 1.5rem;
  border: 1px solid #eee;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid #f8f9fa;
}

.section-title svg {
  color: #667eea;
}

.section-title h3 {
  margin: 0;
  color: #333;
  font-size: 1.1rem;
  font-weight: bold;
}

.settings-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.setting-item {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.setting-item label {
  font-weight: bold;
  color: #333;
  font-size: 0.9rem;
}

.setting-item input,
.setting-item select,
.setting-item textarea {
  padding: 0.75rem;
  border: 1px solid #dcdfe6;
  border-radius: 6px;
  font-size: 0.9rem;
  transition: all 0.2s ease;
}

.setting-item input:focus,
.setting-item select:focus,
.setting-item textarea:focus {
  outline: none;
  border-color: #667eea;
}

.setting-item input:disabled,
.setting-item select:disabled {
  background: #f5f7fa;
  color: #909399;
  cursor: not-allowed;
}

.switch-label {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0;
}

.switch {
  position: relative;
  display: inline-block;
  width: 44px;
  height: 22px;
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
  transition: 0.3s;
  border-radius: 22px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 16px;
  width: 16px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: 0.3s;
  border-radius: 50%;
}

input:checked + .slider {
  background: #667eea;
}

input:checked + .slider:before {
  transform: translateX(22px);
}

.maintenance-actions {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1rem;
}

.action-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 6px;
  border: 1px solid #e9ecef;
}

.action-info h4 {
  margin: 0 0 0.25rem 0;
  color: #333;
  font-size: 0.95rem;
}

.action-info p {
  margin: 0;
  color: #666;
  font-size: 0.8rem;
}

.btn-primary,
.btn-secondary {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  transition: background-color 0.2s;
  font-size: 0.85rem;
  font-weight: 500;
  white-space: nowrap;
}

.btn-primary {
  background: #667eea;
  color: white;
}

.btn-primary:hover {
  background: #5a6fd6;
}

.btn-secondary {
  background: #f0f2f5;
  color: #606266;
}

.btn-secondary:hover {
  background: #e6e8eb;
}

.settings-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 2px solid #f8f9fa;
}

@media (max-width: 768px) {
  .settings-grid {
    grid-template-columns: 1fr;
  }
  
  .maintenance-actions {
    grid-template-columns: 1fr;
  }
  
  .action-card {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }
  
  .settings-footer {
    flex-direction: column;
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
  .required {
    color: #f56c6c;
    margin-left: 4px;
  }
  
  .help-text {
    font-size: 12px;
    color: #909399;
    margin-top: 4px;
    display: block;
  }
  
  .input-with-copy {
    display: flex;
    gap: 0.5rem;
    align-items: stretch;
  }
  
  .input-with-copy input {
    flex: 1;
    background-color: #f5f7fa;
    color: #606266;
  }
  
  .btn-icon {
    padding: 0 0.75rem;
    background: #f0f2f5;
    border: 1px solid #dcdfe6;
    border-radius: 6px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    color: #606266;
  }
  
  .btn-icon:hover {
    background: #e6e8eb;
    color: #667eea;
    border-color: #c6e2ff;
  }
  
  .warning-text {
    color: #e6a23c;
  }

  /* TOTP Styles */
  .totp-setup {
    text-align: center;
    padding: 10px;
  }
  
  .step-text {
    text-align: left;
    margin-bottom: 15px;
    font-weight: 500;
  }
  
  .qr-code-container {
    background: #fff;
    padding: 10px;
    border: 1px solid #eee;
    display: inline-block;
    border-radius: 8px;
    margin-bottom: 15px;
  }
  
  .qr-code-container img {
    width: 200px;
    height: 200px;
    display: block;
  }
  
  .secret-text {
    font-size: 14px;
    color: #666;
    margin-bottom: 25px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }
  
  .secret-text code {
    background: #f0f2f5;
    padding: 4px 8px;
    border-radius: 4px;
    font-family: monospace;
    font-weight: bold;
    color: #333;
  }
  
  .btn-icon-small {
    padding: 2px;
    background: none;
    border: none;
    cursor: pointer;
    color: #909399;
    display: flex;
    align-items: center;
  }
  
  .btn-icon-small:hover {
    color: #667eea;
  }
  
  .code-input {
    margin-bottom: 25px;
  }
  
  .dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
  }
  
  .loading-container {
    text-align: center;
    padding: 40px;
    color: #909399;
  }

  .switch-group {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  
  .btn-text {
    background: none;
    border: none;
    color: #667eea;
    cursor: pointer;
    font-size: 0.85rem;
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 4px 8px;
    border-radius: 4px;
    transition: all 0.2s;
  }
  
  .btn-text:hover {
    background-color: #f0f2f5;
    color: #5a6fd6;
  }

  .checkbox-group {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
    margin-top: 8px;
  }
  
  .checkbox-label {
    display: flex;
    align-items: center;
    gap: 6px;
    cursor: pointer;
    font-size: 0.9rem;
    color: #606266;
  }

  .settings-grid.single-column {
    grid-template-columns: 1fr;
  }
</style>
