<template>
  <div class="home-page">
    <!-- 导航栏 -->
    <nav class="navbar">
      <div class="nav-container">
        <div class="nav-brand">
          <div class="brand-logo">
            <img src="../assets/icon.png" alt="XXG-KAMI-PRO" class="logo-img">
            <div class="brand-text">
              <h1>XXG-KAMI-PRO</h1>
              <span class="version-badge">2.0</span>
            </div>
          </div>
        </div>
        <div class="nav-actions">
          <div class="nav-links">
            <a href="https://xiaoxiaoguai-yyds.github.io/xxgkami.github.io/" target="_blank" class="nav-link">
              <svg class="link-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <circle cx="12" cy="12" r="10"/>
                <path d="M2 12h20"/>
                <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
              </svg>
              官网
            </a>
            <a href="https://github.com/xiaoxiaoguai-yyds/xxgkami" target="_blank" class="nav-link">
              <svg class="link-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/>
              </svg>
              GitHub
            </a>
          </div>
          <button type="button" class="nav-link nav-link-btn" @click="goOnlineUnbind">
            <svg class="link-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
              <path d="M7 11V7a5 5 0 0 1 9.9-1"/>
            </svg>
            在线解绑
          </button>
          <button class="login-btn" @click="goToLogin">
            <svg class="login-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/>
              <polyline points="10,17 15,12 10,7"/>
              <line x1="15" y1="12" x2="3" y2="12"/>
            </svg>
            登录管理
          </button>
        </div>
      </div>
    </nav>

    <!-- 主要内容区域 -->
    <main class="main-content">
      <!-- 英雄区域 -->
      <section class="hero-section">
        <div class="hero-container">
          <div class="hero-content">
            <div class="hero-badge">
              <span class="badge-text">🚀 全新升级</span>
              <span class="badge-version">V2.0</span>
            </div>
            <h1 class="hero-title">
              XXG-KAMI-PRO
              <span class="title-highlight">2.0</span>
            </h1>
            <p class="hero-subtitle">
              全新架构重构，更强大的功能，更优雅的界面设计
              <br>
              为您的业务提供专业级的卡密管理解决方案
            </p>
            <div class="hero-features">
              <div class="feature-tag">
                <svg class="tag-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <polyline points="22,12 18,12 15,21 9,3 6,12 2,12"/>
                </svg>
                高性能
              </div>
              <div class="feature-tag">
                <svg class="tag-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                </svg>
                安全可靠
              </div>
              <div class="feature-tag">
                <svg class="tag-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
                </svg>
                快速部署
              </div>
            </div>
            <div class="hero-actions">
              <button class="cta-button primary" @click="goToLogin">
                开始使用
                <svg class="arrow-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <line x1="7" y1="17" x2="17" y2="7"/>
                  <polyline points="7,7 17,7 17,17"/>
                </svg>
              </button>
              <button class="cta-button secondary" @click="scrollToFeatures">
                了解更多
              </button>
              <div class="external-links">
                <a href="https://xiaoxiaoguai-yyds.github.io/xxgkami.github.io/" target="_blank" class="external-link">
                  <svg class="link-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <circle cx="12" cy="12" r="10"/>
                    <path d="M2 12h20"/>
                    <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
                  </svg>
                  官网
                </a>
                <a href="https://github.com/xiaoxiaoguai-yyds/xxgkami" target="_blank" class="external-link">
                  <svg class="link-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/>
                  </svg>
                  GitHub
                </a>
              </div>
            </div>
          </div>
          <div class="hero-visual">
            <div class="visual-container">
              <!-- 中心 Logo 展示 -->
              <div class="hero-center-logo">
                <img src="../assets/icon.png" alt="XXG-KAMI-PRO Logo" />
                <div class="logo-glow"></div>
              </div>


              
              <div class="background-elements">
                <div class="floating-element element-1"></div>
                <div class="floating-element element-2"></div>
                <div class="floating-element element-3"></div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 版本特性区域 -->
      <section class="version-features-section">
        <div class="version-container">
          <div class="section-header">
            <h2 class="section-title">2.0 版本亮点</h2>
            <p class="section-subtitle">全面升级，带来更强大的功能体验</p>
          </div>
          <div class="version-grid">
            <div class="version-item">
              <div class="version-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
                </svg>
              </div>
              <h3 class="version-title">性能提升 300%</h3>
              <p class="version-description">全新架构设计，卡密生成和查询速度大幅提升</p>
            </div>
            <div class="version-item">
              <div class="version-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                </svg>
              </div>
              <h3 class="version-title">全新UI设计</h3>
              <p class="version-description">现代化界面设计，更直观的用户体验</p>
            </div>
            <div class="version-item">
              <div class="version-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                </svg>
              </div>
              <h3 class="version-title">增强安全性</h3>
              <p class="version-description">多重加密保护，确保卡密数据绝对安全</p>
            </div>
            <div class="version-item">
              <div class="version-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <circle cx="12" cy="12" r="3"/>
                  <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/>
                </svg>
              </div>
              <h3 class="version-title">智能配置</h3>
              <p class="version-description">自动化配置管理，一键部署轻松上手</p>
            </div>
          </div>
        </div>
      </section>

      <!-- 技术栈区域 -->
      <section class="tech-stack-section">
        <div class="tech-container">
          <div class="section-header">
            <h2 class="section-title">技术架构</h2>
            <p class="section-subtitle">基于现代化技术栈构建的高性能系统</p>
          </div>
          <div class="tech-grid">
            <div class="tech-category">
              <h3 class="tech-category-title">前端技术</h3>
              <div class="tech-items">
                <div class="tech-item">
                  <div class="tech-logo vue">Vue</div>
                  <span>Vue 3</span>
                </div>
                <div class="tech-item">
                  <div class="tech-logo vite">Vite</div>
                  <span>Vite</span>
                </div>
                <div class="tech-item">
                  <div class="tech-logo js">JS</div>
                  <span>JavaScript</span>
                </div>
              </div>
            </div>
            <div class="tech-category">
              <h3 class="tech-category-title">后端技术</h3>
              <div class="tech-items">
                <div class="tech-item">
                  <div class="tech-logo spring">Spring</div>
                  <span>Spring Boot</span>
                </div>
                <div class="tech-item">
                  <div class="tech-logo java">Java</div>
                  <span>Java</span>
                </div>
                <div class="tech-item">
                  <div class="tech-logo mysql">MySQL</div>
                  <span>MySQL</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 功能特性区域 -->
      <section class="features-section" id="features">
        <div class="features-container">
          <div class="section-header">
            <h2 class="section-title">核心功能</h2>
            <p class="section-subtitle">为您提供全方位的卡密管理解决方案</p>
          </div>
          <div class="features-grid">
            <div class="feature-item">
              <div class="feature-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                  <line x1="16" y1="2" x2="16" y2="6"/>
                  <line x1="8" y1="2" x2="8" y2="6"/>
                  <line x1="3" y1="10" x2="21" y2="10"/>
                </svg>
              </div>
              <h3 class="feature-title">卡密生成</h3>
              <p class="feature-description">支持批量生成卡密，可自定义格式、有效期和使用次数，满足不同业务需求</p>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                </svg>
              </div>
              <h3 class="feature-title">安全管理</h3>
              <p class="feature-description">采用加密存储，支持权限控制，确保卡密数据安全，防止恶意访问和泄露</p>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M3 3v18h18"/>
                  <path d="M18.7 8l-5.1 5.2-2.8-2.7L7 14.3"/>
                </svg>
              </div>
              <h3 class="feature-title">数据统计</h3>
              <p class="feature-description">实时统计卡密使用情况，提供详细的数据报表和可视化图表分析</p>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                  <polyline points="14,2 14,8 20,8"/>
                  <line x1="16" y1="13" x2="8" y2="13"/>
                  <line x1="16" y1="17" x2="8" y2="17"/>
                  <polyline points="10,9 9,9 8,9"/>
                </svg>
              </div>
              <h3 class="feature-title">导出功能</h3>
              <p class="feature-description">支持多种格式导出卡密数据，方便与其他系统集成和数据备份</p>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                  <circle cx="9" cy="7" r="4"/>
                  <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                  <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                </svg>
              </div>
              <h3 class="feature-title">多用户管理</h3>
              <p class="feature-description">支持多用户协作，不同权限级别管理，满足团队协作需求</p>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
                  <polyline points="7.5,4.21 12,6.81 16.5,4.21"/>
                  <polyline points="7.5,19.79 7.5,14.6 3,12"/>
                  <polyline points="21,12 16.5,14.6 16.5,19.79"/>
                </svg>
              </div>
              <h3 class="feature-title">API接口</h3>
              <p class="feature-description">提供完整的RESTful API接口，方便第三方系统集成和自动化操作</p>
            </div>
          </div>
        </div>
      </section>

      <!-- 优势区域 -->
      <section class="advantages-section">
        <div class="advantages-container">
          <div class="section-header">
            <h2 class="section-title">为什么选择我们</h2>
            <p class="section-subtitle">专业、可靠、高效的卡密管理解决方案</p>
          </div>
          <div class="advantages-grid">
            <div class="advantage-item">
              <div class="advantage-number">01</div>
              <h3 class="advantage-title">简单易用</h3>
              <p class="advantage-description">直观的用户界面，简化的操作流程，无需复杂培训即可快速上手</p>
            </div>
            <div class="advantage-item">
              <div class="advantage-number">02</div>
              <h3 class="advantage-title">高性能</h3>
              <p class="advantage-description">优化的数据库设计，支持大量卡密的快速生成和查询操作</p>
            </div>
            <div class="advantage-item">
              <div class="advantage-number">03</div>
              <h3 class="advantage-title">可扩展</h3>
              <p class="advantage-description">模块化架构设计，支持功能扩展和定制开发，适应业务发展需求</p>
            </div>
          </div>
        </div>
      </section>
    </main>

    <!-- 底部动图 (白色区域) -->
    <div class="mascot-section">
      <div class="mascot-container">
        <img src="../assets/icon.gif" alt="XXG Mascot">
      </div>
    </div>

    <!-- 页脚 -->
    <footer class="footer">
      <div class="footer-container">
        <div class="footer-content">
            <div class="footer-brand">
              <div class="footer-logo">
                <img src="../assets/icon.png" alt="XXG-KAMI-PRO" class="logo-img">
                <div>
                  <h3>XXG-KAMI-PRO</h3>
                  <p>专业的卡密管理解决方案</p>
                </div>
              </div>
            </div>
            <div class="footer-links">
              <div class="footer-section">
                <h4>产品</h4>
                <ul>
                  <li><a href="#features">功能特性</a></li>
                  <li><a href="#tech">技术架构</a></li>
                  <li><a href="#version">版本更新</a></li>
                </ul>
              </div>
              <div class="footer-section">
                <h4>资源</h4>
                <ul>
                  <li><a href="https://xiaoxiaoguai-yyds.github.io/xxgkami.github.io/docx.html" target="_blank">官方文档</a></li>
                  <li><a href="https://github.com/xiaoxiaoguai-yyds/xxgkami" target="_blank">开源代码</a></li>
                  <li><a href="mailto:xxgyyds@vip.qq.com?subject=XXG-KAMI-PRO 2.0技术支持&body=请描述您遇到的问题：" target="_blank">技术支持</a></li>
                </ul>
              </div>
            </div>
            <div class="footer-info">
              <p>&copy; 2025 XXG-KAMI-PRO. 保留所有权利.</p>
              <div class="footer-social">
                <a href="https://github.com/xiaoxiaoguai-yyds/xxgkami" target="_blank" class="social-link">
                  <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                  </svg>
                </a>
              </div>
            </div>
          </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { defineEmits } from 'vue'

const emit = defineEmits(['showLogin', 'goOnlineUnbind'])

const goToLogin = () => {
  emit('showLogin')
}

const goOnlineUnbind = () => {
  emit('goOnlineUnbind')
}

const scrollToFeatures = () => {
  const featuresSection = document.getElementById('features')
  if (featuresSection) {
    featuresSection.scrollIntoView({ behavior: 'smooth' })
  }
}
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.home-page {
  min-height: 100vh;
  background: #ffffff;
  color: #111827;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
}

/* 导航栏样式 */
.navbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(8px);
  border-bottom: 1px solid #e5e7eb;
  z-index: 1000;
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
  height: 64px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-brand {
  display: flex;
  align-items: center;
}

.brand-logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.logo-img {
  width: 28px;
  height: 28px;
  object-fit: contain;
}

.brand-text {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.brand-text h1 {
  font-size: 1.25rem;
  font-weight: 700;
  color: #111827;
  margin: 0;
  letter-spacing: -0.025em;
}

.version-badge {
  background: #f3f4f6;
  color: #4b5563;
  padding: 0.125rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
  border: 1px solid #e5e7eb;
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  color: #4b5563;
  text-decoration: none;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.2s ease;
}

.nav-link:hover {
  color: #111827;
  background: #f9fafb;
}

.nav-link-btn {
  border: none;
  background: transparent;
  font: inherit;
  font-size: inherit;
  font-family: inherit;
  cursor: pointer;
}

.link-icon {
  width: 1rem;
  height: 1rem;
}

.login-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: #111827;
  color: white;
  border: 1px solid #111827;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.login-btn:hover {
  background: #1f2937;
  transform: translateY(-1px);
}

.login-icon {
  width: 1rem;
  height: 1rem;
}

/* 主要内容区域 */
.main-content {
  padding-top: 64px;
}

/* 英雄区域样式 */
.hero-section {
  padding: 6rem 0;
  background: #ffffff;
  color: #111827;
  position: relative;
  overflow: hidden;
  border-bottom: 1px solid #f3f4f6;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  padding: 0.375rem 0.75rem;
  margin-bottom: 1.5rem;
  animation: fadeInUp 0.5s ease-out;
}

.badge-text {
  font-size: 0.875rem;
  font-weight: 500;
  color: #4b5563;
}

.badge-version {
  background: #111827;
  color: white;
  padding: 0.125rem 0.375rem;
  border-radius: 2px;
  font-size: 0.75rem;
  font-weight: 600;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 800;
  line-height: 1.1;
  margin-bottom: 1.5rem;
  color: #111827;
  letter-spacing: -0.025em;
  animation: fadeInUp 0.5s ease-out 0.1s both;
}

.title-highlight {
  color: #4f46e5;
  background: none;
  -webkit-text-fill-color: initial;
}

.hero-subtitle {
  font-size: 1.25rem;
  line-height: 1.6;
  margin-bottom: 2.5rem;
  color: #4b5563;
  max-width: 600px;
  animation: fadeInUp 0.5s ease-out 0.2s both;
}

.hero-features {
  display: flex;
  gap: 1rem;
  margin-bottom: 2.5rem;
  flex-wrap: wrap;
  animation: fadeInUp 0.5s ease-out 0.3s both;
}

.feature-tag {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  padding: 0.5rem 0.75rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: #374151;
  transition: all 0.2s ease;
}

.feature-tag:hover {
  border-color: #d1d5db;
  background: #f9fafb;
}

.tag-icon {
  width: 1rem;
  height: 1rem;
  color: #4f46e5;
}

.hero-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4rem;
  align-items: center;
}

.hero-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  align-items: center;
  animation: fadeInUp 0.5s ease-out 0.4s both;
}

.external-links {
  display: flex;
  gap: 1rem;
  margin-left: 1rem;
}

.external-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1rem;
  color: #4b5563;
  text-decoration: none;
  border: 1px solid transparent;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.2s ease;
}

.external-link:hover {
  color: #111827;
  background: #f3f4f6;
}

.external-link .link-icon {
  width: 1rem;
  height: 1rem;
}

.cta-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border: 1px solid transparent;
  border-radius: 4px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.cta-button.primary {
  background: #111827;
  color: white;
  border-color: #111827;
}

.cta-button.primary:hover {
  background: #1f2937;
  transform: translateY(-1px);
}

.cta-button.secondary {
  background: white;
  color: #111827;
  border: 1px solid #e5e7eb;
}

.cta-button.secondary:hover {
  background: #f9fafb;
  border-color: #d1d5db;
}

.arrow-icon {
  width: 1rem;
  height: 1rem;
}

/* 英雄区域视觉部分 */
.hero-visual {
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  animation: fadeInRight 0.5s ease-out 0.2s both;
}

.visual-container {
  position: relative;
  width: 100%;
  height: 400px;
  background: #f9fafb;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  overflow: hidden;
}

.hero-center-logo {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 1;
  display: flex;
  justify-content: center;
  align-items: center;
}

.hero-center-logo img {
  width: 180px;
  height: 180px;
  object-fit: contain;
  animation: floatLogo 6s ease-in-out infinite;
  filter: drop-shadow(0 0 30px rgba(79, 70, 229, 0.15));
  position: relative;
  z-index: 2;
}

.logo-glow {
  position: absolute;
  width: 200px;
  height: 200px;
  background: radial-gradient(circle, rgba(79, 70, 229, 0.1) 0%, rgba(255, 255, 255, 0) 70%);
  border-radius: 50%;
  z-index: 1;
  animation: pulseGlow 4s ease-in-out infinite;
}

.floating-cards {
  position: relative;
  width: 100%;
  height: 100%;
}

.card {
  position: absolute;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  padding: 1.25rem;
  width: 260px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  transition: all 0.2s ease;
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  border-color: #d1d5db;
}

.card-1 {
  top: 5%;
  left: 2%;
  z-index: 2;
}

.card-2 {
  top: 60%;
  right: 2%;
  z-index: 3;
}

.card-3 {
  bottom: 5%;
  left: 2%;
  z-index: 1;
}




.background-elements {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  background-image: radial-gradient(#e5e7eb 1px, transparent 1px);
  background-size: 20px 20px;
  opacity: 0.5;
}

/* 版本特性区域 */
.version-features-section {
  padding: 5rem 0;
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}

.version-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

.version-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 2rem;
}

.version-item {
  background: white;
  padding: 2rem;
  border-radius: 4px;
  text-align: left;
  border: 1px solid #e5e7eb;
  transition: all 0.2s ease;
}

.version-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  border-color: #d1d5db;
}

.version-item::before {
  display: none;
}

.version-icon {
  width: 3rem;
  height: 3rem;
  background: #f3f4f6;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.25rem;
  color: #4f46e5;
}

.version-icon svg {
  width: 1.5rem;
  height: 1.5rem;
  stroke-width: 2;
}

.version-title {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
  color: #111827;
}

.version-description {
  color: #6b7280;
  line-height: 1.5;
  font-size: 0.9rem;
}

/* 技术栈区域 */
.tech-stack-section {
  padding: 5rem 0;
  background: #ffffff;
  color: #111827;
  border-bottom: 1px solid #e5e7eb;
}

.tech-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

.tech-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 4rem;
}

.tech-category {
  text-align: center;
}

.tech-category-title {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 2rem;
  color: #111827;
}

.tech-items {
  display: flex;
  justify-content: center;
  gap: 1.5rem;
  flex-wrap: wrap;
}

.tech-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  padding: 1.5rem;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  transition: all 0.2s ease;
  min-width: 100px;
}

.tech-item:hover {
  background: white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  border-color: #d1d5db;
  transform: translateY(-2px);
}

.tech-logo {
  width: 3rem;
  height: 3rem;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.875rem;
  color: white;
}

.tech-logo.vue { background: #4fc08d; }
.tech-logo.vite { background: #646cff; }
.tech-logo.js { background: #f7df1e; color: #000; }
.tech-logo.spring { background: #6db33f; }
.tech-logo.java { background: #ed8b00; }
.tech-logo.mysql { background: #4479a1; }

.tech-item span {
  font-size: 0.875rem;
  font-weight: 500;
  color: #4b5563;
}

.features-section {
  padding: 5rem 0;
  background: #f9fafb;
}

.features-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

.section-header {
  text-align: center;
  margin-bottom: 3rem;
}

.section-title {
  font-size: 2.25rem;
  font-weight: 800;
  margin-bottom: 1rem;
  color: #111827;
  letter-spacing: -0.025em;
}

.section-subtitle {
  font-size: 1.125rem;
  color: #6b7280;
  max-width: 600px;
  margin: 0 auto;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 2rem;
}

.feature-item {
  padding: 2rem;
  background: white;
  border-radius: 4px;
  border: 1px solid #e5e7eb;
  transition: all 0.2s ease;
}

.feature-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  border-color: #d1d5db;
}

.feature-icon {
  width: 3rem;
  height: 3rem;
  background: #f3f4f6;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.25rem;
  color: #4f46e5;
}

.feature-icon svg {
  width: 1.5rem;
  height: 1.5rem;
  stroke-width: 2;
}

.feature-title {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
  color: #111827;
}

.feature-description {
  color: #6b7280;
  line-height: 1.5;
  font-size: 0.9rem;
}

/* 优势区域 */
.advantages-section {
  padding: 5rem 0;
  background: white;
  border-top: 1px solid #e5e7eb;
}

.advantages-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

.advantages-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 3rem;
}

.advantage-item {
  text-align: center;
  padding: 2rem;
  background: #f9fafb;
  border-radius: 4px;
  border: 1px solid #e5e7eb;
}

.advantage-number {
  font-size: 2.5rem;
  font-weight: 800;
  color: #e5e7eb;
  margin-bottom: 1rem;
  line-height: 1;
}

.advantage-title {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
  color: #111827;
}

.advantage-description {
  color: #6b7280;
  line-height: 1.5;
}

/* 页脚样式 */
.footer {
  background: #111827;
  color: white;
  padding: 4rem 0 2rem;
}

.footer-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

.footer-content {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  gap: 3rem;
  margin-bottom: 3rem;
}

.footer-logo {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.footer-logo .logo-img {
  width: 2rem;
  height: 2rem;
  object-fit: contain;
}

.footer-brand h3 {
  font-size: 1.25rem;
  margin-bottom: 0.5rem;
  font-weight: 700;
}

.footer-brand p {
  color: #9ca3af;
  font-size: 0.9rem;
}

.footer-links {
  display: flex;
  gap: 4rem;
}

.footer-section h4 {
  font-size: 0.875rem;
  font-weight: 600;
  margin-bottom: 1.25rem;
  color: #f3f4f6;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.footer-section ul {
  list-style: none;
  padding: 0;
}

.footer-section li {
  margin-bottom: 0.75rem;
}

.footer-section a {
  color: #9ca3af;
  text-decoration: none;
  transition: color 0.2s ease;
  font-size: 0.9rem;
}

.footer-section a:hover {
  color: white;
}

.footer-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 2rem;
  border-top: 1px solid #374151;
}

.footer-info p {
  color: #6b7280;
  font-size: 0.875rem;
}

.footer-social {
  display: flex;
  gap: 1rem;
}

.social-link {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  background: #374151;
  border-radius: 4px;
  color: #9ca3af;
  transition: all 0.2s ease;
}

.social-link:hover {
  background: #4b5563;
  color: white;
}

.social-link svg {
  width: 1rem;
  height: 1rem;
}

/* 动画效果 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeInRight {
  from {
    opacity: 0;
    transform: translateX(20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes floatLogo {
  0% { transform: translateY(0); }
  50% { transform: translateY(-15px); }
  100% { transform: translateY(0); }
}

@keyframes pulseGlow {
  0% { transform: scale(1); opacity: 0.5; }
  50% { transform: scale(1.2); opacity: 0.8; }
  100% { transform: scale(1); opacity: 0.5; }
}

@media (max-width: 1024px) {
  .hero-container {
    grid-template-columns: 1fr;
    gap: 3rem;
    text-align: center;
  }

  .hero-visual {
    order: -1;
  }
  
  .hero-actions {
    justify-content: center;
  }
  
  .external-links {
    margin-left: 0;
  }

  .features-grid, .advantages-grid, .version-grid {
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  }

  .tech-grid {
    grid-template-columns: 1fr;
    gap: 3rem;
  }

  .footer-content {
    grid-template-columns: 1fr;
    gap: 2rem;
    text-align: center;
  }
  
  .footer-logo {
    justify-content: center;
  }
  
  .footer-links {
    justify-content: center;
  }

  .footer-info {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }
}

/* 底部动图区域 (白色背景) */
.mascot-section {
  background: white;
  padding: 2rem 0;
  border-top: 1px solid #e5e7eb;
}

.mascot-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: center;
  align-items: center;
}

.mascot-container img {
  height: 80px; /* 稍微放大一点使其更明显 */
  width: auto;
  display: block;
}

@media (max-width: 768px) {
    .nav-container {
      padding: 0 1rem;
    }
  
    .nav-links {
      display: none;
    }
  
    .hero-section {
      padding: 4rem 0;
    }

  .hero-title {
    font-size: 2.5rem;
  }

  .hero-visual {
    height: 300px;
  }
  
  .card {
    width: 200px;
    padding: 1rem;
  }
}
</style>