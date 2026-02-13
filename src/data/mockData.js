// 模拟数据文件
// 基于数据库结构创建的测试数据

// 管理员数据 (基于 admins 表)
export const mockAdmins = [
  {
    id: 1,
    username: '123',
    password: '123456', // 原始密码，实际应用中会加密
    create_time: '2025-05-06 09:13:25',
    last_login: '2025-05-20 08:18:44'
  },
  {
    id: 2,
    username: 'admin',
    password: 'admin123',
    create_time: '2025-01-01 10:00:00',
    last_login: '2025-01-15 14:30:00'
  }
]

// 普通用户数据 (基于 users 表)
export const mockUsers = [
  {
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    password: '123456', // 原始密码，实际应用中会加密
    nickname: '测试用户',
    avatar: null,
    phone: '13800138000',
    status: 1,
    email_verified: 1,
    last_login_time: '2025-01-10 15:30:00',
    last_login_ip: '127.0.0.1',
    login_count: 25,
    register_ip: '127.0.0.1',
    create_time: '2024-12-01 10:00:00',
    update_time: '2025-01-10 15:30:00'
  },
  {
    id: 2,
    username: 'demo',
    email: 'demo@example.com',
    password: '123456',
    nickname: '演示用户',
    avatar: null,
    phone: '13900139000',
    status: 1,
    email_verified: 0,
    last_login_time: '2025-01-08 09:15:00',
    last_login_ip: '192.168.1.100',
    login_count: 12,
    register_ip: '192.168.1.100',
    create_time: '2024-12-15 14:20:00',
    update_time: '2025-01-08 09:15:00'
  },
  {
    id: 3,
    username: 'user001',
    email: 'user001@example.com',
    password: '123456',
    nickname: '普通用户001',
    avatar: null,
    phone: '13700137000',
    status: 1,
    email_verified: 1,
    last_login_time: '2025-01-12 11:45:00',
    last_login_ip: '10.0.0.50',
    login_count: 8,
    register_ip: '10.0.0.50',
    create_time: '2025-01-01 16:30:00',
    update_time: '2025-01-12 11:45:00'
  }
]

// 卡密数据 (基于 cards 表)
export const mockCards = [
  {
    id: 33,
    card_key: '5YuOiG1XqfI0WxMZTMki',
    encrypted_key: '06807a70b85a77746c3052067dec9c0091048edb',
    status: 0, // 0:未使用 1:已使用 2:已停用
    create_time: '2025-05-13 18:06:58',
    use_time: null,
    expire_time: null,
    duration: 30,
    verify_method: 'web',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 34,
    card_key: '2vGa8kN0Zy1S5uvGBxq9',
    encrypted_key: '8ae5443059f81cb79e437b315384ea175aa78e0f',
    status: 1,
    create_time: '2025-05-13 18:06:58',
    use_time: '2025-05-14 10:30:00',
    expire_time: '2025-06-13 10:30:00',
    duration: 30,
    verify_method: 'web',
    allow_reverify: 1,
    device_id: 'device_001',
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 35,
    card_key: 'XUensLpopa5vmkQYmPcS',
    encrypted_key: '5b87fc13a67d2c8d21816343877d4b8a33cdd28e',
    status: 0,
    create_time: '2025-05-13 18:06:58',
    use_time: null,
    expire_time: null,
    duration: 30,
    verify_method: 'web',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 36,
    card_key: '5AalGilBh2K41VysoorW',
    encrypted_key: '9a1e75a8ba87eef8c10bc735c6f76900e7d17656',
    status: 0,
    create_time: '2025-05-13 18:06:58',
    use_time: null,
    expire_time: null,
    duration: 30,
    verify_method: 'web',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 37,
    card_key: 'okvbwDm1av7dnBqaOfda',
    encrypted_key: 'f03670f414711057a31ae35d2661f8a4ac647fa3',
    status: 0,
    create_time: '2025-05-13 18:06:58',
    use_time: null,
    expire_time: null,
    duration: 30,
    verify_method: 'web',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 38,
    card_key: 'K9mN2pQ7rT4uV8wX1yZ5',
    encrypted_key: 'a1b2c3d4e5f6789012345678901234567890abcd',
    status: 1,
    create_time: '2025-05-10 14:20:30',
    use_time: '2025-05-11 09:15:45',
    expire_time: '2025-06-10 09:15:45',
    duration: 30,
    verify_method: 'post',
    allow_reverify: 0,
    device_id: 'device_002',
    encryption_type: 'rc4',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 39,
    card_key: 'B3cD6eF9gH2jK5lM8nP1',
    encrypted_key: 'fedcba0987654321abcdef1234567890abcdef12',
    status: 2,
    create_time: '2025-05-08 11:45:20',
    use_time: null,
    expire_time: null,
    duration: 60,
    verify_method: 'get',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 40,
    card_key: 'Q4rS7tU0vW3xY6zA9bC2',
    encrypted_key: '123456789abcdef0123456789abcdef012345678',
    status: 0,
    create_time: '2025-05-15 16:30:10',
    use_time: null,
    expire_time: null,
    duration: 7,
    verify_method: 'web',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'count',
    total_count: 100,
    remaining_count: 100
  },
  {
    id: 41,
    card_key: 'E5fG8hI1jK4lM7nO0pQ3',
    encrypted_key: 'abcdef123456789abcdef123456789abcdef1234',
    status: 1,
    create_time: '2025-05-12 13:25:40',
    use_time: '2025-05-13 08:45:15',
    expire_time: null,
    duration: 0,
    verify_method: 'post',
    allow_reverify: 1,
    device_id: 'device_003',
    encryption_type: 'rc4',
    card_type: 'count',
    total_count: 50,
    remaining_count: 35
  },
  {
    id: 42,
    card_key: 'R6sT9uV2wX5yZ8aB1cD4',
    encrypted_key: '9876543210abcdef9876543210abcdef98765432',
    status: 0,
    create_time: '2025-05-16 09:20:15',
    use_time: null,
    expire_time: null,
    duration: 15,
    verify_method: 'web',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 43,
    card_key: 'F7gH0iJ3kL6mN9oP2qR5',
    encrypted_key: 'def456789abc123def456789abc123def4567890',
    status: 1,
    create_time: '2025-05-14 16:45:30',
    use_time: '2025-05-15 12:20:45',
    expire_time: '2025-08-13 12:20:45',
    duration: 90,
    verify_method: 'get',
    allow_reverify: 0,
    device_id: 'device_004',
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 44,
    card_key: 'S8tU1vW4xY7zA0bC3dE6',
    encrypted_key: 'fedcba9876543210fedcba9876543210fedcba98',
    status: 2,
    create_time: '2025-05-05 14:30:20',
    use_time: null,
    expire_time: null,
    duration: 30,
    verify_method: 'post',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'rc4',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 45,
    card_key: 'G9hI2jK5lM8nO1pQ4rS7',
    encrypted_key: '147258369abcdef147258369abcdef14725836',
    status: 0,
    create_time: '2025-05-17 11:15:40',
    use_time: null,
    expire_time: null,
    duration: 0,
    verify_method: 'web',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'count',
    total_count: 200,
    remaining_count: 200
  },
  {
    id: 46,
    card_key: 'T0uV3wX6yZ9aB2cD5eF8',
    encrypted_key: '369258147abcdef369258147abcdef36925814',
    status: 1,
    create_time: '2025-05-11 08:30:25',
    use_time: '2025-05-12 14:15:30',
    expire_time: null,
    duration: 0,
    verify_method: 'post',
    allow_reverify: 1,
    device_id: 'device_005',
    encryption_type: 'rc4',
    card_type: 'count',
    total_count: 75,
    remaining_count: 45
  },
  {
    id: 47,
    card_key: 'H1iJ4kL7mN0oP3qR6sT9',
    encrypted_key: 'abcd1234efgh5678ijkl9012mnop3456qrst7890',
    status: 0,
    create_time: '2025-05-18 13:45:55',
    use_time: null,
    expire_time: null,
    duration: 60,
    verify_method: 'get',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 48,
    card_key: 'U2vW5xY8zA1bC4dE7fG0',
    encrypted_key: '987654321fedcba987654321fedcba9876543210',
    status: 1,
    create_time: '2025-05-09 10:20:10',
    use_time: '2025-05-10 16:45:20',
    expire_time: '2025-06-09 16:45:20',
    duration: 30,
    verify_method: 'web',
    allow_reverify: 0,
    device_id: 'device_006',
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 49,
    card_key: 'I3jK6lM9nO2pQ5rS8tU1',
    encrypted_key: '456789abcdef123456789abcdef123456789abc',
    status: 2,
    create_time: '2025-05-03 15:10:35',
    use_time: null,
    expire_time: null,
    duration: 7,
    verify_method: 'post',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'rc4',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 50,
    card_key: 'V4wX7yZ0aB3cD6eF9gH2',
    encrypted_key: 'cdef5678901234abcdef5678901234abcdef5678',
    status: 0,
    create_time: '2025-05-19 07:25:45',
    use_time: null,
    expire_time: null,
    duration: 0,
    verify_method: 'get',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'count',
    total_count: 150,
    remaining_count: 150
  },
  {
    id: 51,
    card_key: 'J5kL8mN1oP4qR7sT0uV3',
    encrypted_key: '789abcdef123456789abcdef123456789abcdef1',
    status: 1,
    create_time: '2025-05-07 12:40:20',
    use_time: '2025-05-08 09:30:15',
    expire_time: '2025-11-05 09:30:15',
    duration: 180,
    verify_method: 'web',
    allow_reverify: 1,
    device_id: 'device_007',
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 52,
    card_key: 'W6xY9zA2bC5dE8fG1hI4',
    encrypted_key: 'bcdef67890123456bcdef67890123456bcdef678',
    status: 0,
    create_time: '2025-05-20 14:55:30',
    use_time: null,
    expire_time: null,
    duration: 45,
    verify_method: 'post',
    allow_reverify: 0,
    device_id: null,
    encryption_type: 'rc4',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 53,
    card_key: 'K7lM0nO3pQ6rS9tU2vW5',
    encrypted_key: '012345678abcdef012345678abcdef0123456789',
    status: 1,
    create_time: '2025-05-06 11:20:40',
    use_time: '2025-05-07 15:45:25',
    expire_time: null,
    duration: 0,
    verify_method: 'get',
    allow_reverify: 1,
    device_id: 'device_008',
    encryption_type: 'sha1',
    card_type: 'count',
    total_count: 300,
    remaining_count: 180
  },
  {
    id: 54,
    card_key: 'X8yZ1aB4cD7eF0gH3iJ6',
    encrypted_key: 'efgh789012345678efgh789012345678efgh7890',
    status: 2,
    create_time: '2025-05-01 09:15:50',
    use_time: null,
    expire_time: null,
    duration: 14,
    verify_method: 'web',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'sha1',
    card_type: 'time',
    total_count: 0,
    remaining_count: 0
  },
  {
    id: 55,
    card_key: 'L9mN2oP5qR8sT1uV4wX7',
    encrypted_key: '345678901abcdef345678901abcdef3456789012',
    status: 0,
    create_time: '2025-05-21 16:30:15',
    use_time: null,
    expire_time: null,
    duration: 0,
    verify_method: 'post',
    allow_reverify: 1,
    device_id: null,
    encryption_type: 'rc4',
    card_type: 'count',
    total_count: 500,
    remaining_count: 500
  }
]

// 为卡密管理页面格式化的数据
export const mockKeysData = [
  {
    id: 1,
    keyCode: 'XXGK-BASIC-2025-001',
    type: 'basic',
    status: 'unused',
    createdAt: Date.now() - 86400000 * 2, // 2天前
    usedAt: null
  },
  {
    id: 2,
    keyCode: 'XXGK-PREMIUM-2025-002',
    type: 'premium',
    status: 'used',
    createdAt: Date.now() - 86400000 * 5, // 5天前
    usedAt: Date.now() - 86400000 * 1 // 1天前
  },
  {
    id: 3,
    keyCode: 'XXGK-ENTERPRISE-2025-003',
    type: 'enterprise',
    status: 'unused',
    createdAt: Date.now() - 86400000 * 1, // 1天前
    usedAt: null
  },
  {
    id: 4,
    keyCode: 'XXGK-BASIC-2025-004',
    type: 'basic',
    status: 'expired',
    createdAt: Date.now() - 86400000 * 40, // 40天前
    usedAt: null
  },
  {
    id: 5,
    keyCode: 'XXGK-PREMIUM-2025-005',
    type: 'premium',
    status: 'used',
    createdAt: Date.now() - 86400000 * 10, // 10天前
    usedAt: Date.now() - 86400000 * 3 // 3天前
  },
  {
    id: 6,
    keyCode: 'XXGK-BASIC-2025-006',
    type: 'basic',
    status: 'unused',
    createdAt: Date.now() - 86400000 * 0.5, // 12小时前
    usedAt: null
  },
  {
    id: 7,
    keyCode: 'XXGK-ENTERPRISE-2025-007',
    type: 'enterprise',
    status: 'unused',
    createdAt: Date.now() - 86400000 * 3, // 3天前
    usedAt: null
  },
  {
    id: 8,
    keyCode: 'XXGK-PREMIUM-2025-008',
    type: 'premium',
    status: 'expired',
    createdAt: Date.now() - 86400000 * 50, // 50天前
    usedAt: null
  }
]

// 卡密管理相关的API函数
export const mockGetKeys = () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({
        success: true,
        data: mockCards,
        total: mockCards.length
      })
    }, 300)
  })
}

export const mockCreateKeys = (keyData) => {
  return new Promise((resolve) => {
    setTimeout(() => {
      const newKeys = []
      for (let i = 0; i < keyData.count; i++) {
        const newKey = {
          id: Date.now() + i,
          keyCode: `XXGK-${keyData.type.toUpperCase()}-2025-${String(Date.now() + i).slice(-6)}`,
          type: keyData.type,
          status: 'unused',
          createdAt: Date.now(),
          usedAt: null
        }
        newKeys.push(newKey)
        mockKeysData.push(newKey)
      }
      resolve({
        success: true,
        data: newKeys,
        message: `成功生成 ${keyData.count} 个卡密`
      })
    }, 500)
  })
}

export const mockDeleteKey = (keyId) => {
  return new Promise((resolve) => {
    setTimeout(() => {
      const index = mockCards.findIndex(key => key.id === keyId)
      if (index !== -1) {
        mockCards.splice(index, 1)
        resolve({
          success: true,
          message: '卡密删除成功'
        })
      } else {
        resolve({
          success: false,
          message: '卡密不存在'
        })
      }
    }, 300)
  })
}

// API密钥数据 (基于 api_keys 表)
export const mockApiKeys = [
  {
    id: 3,
    key_name: '123',
    api_key: '8WAD3TN9YCUZivmDAdicvYs5Q7Hj0zcB',
    status: 1,
    create_time: '2025-05-13 15:44:55',
    last_use_time: '2025-05-13 17:42:27',
    use_count: 5,
    description: '123'
  },
  {
    id: 4,
    key_name: '456',
    api_key: '1jTQXXpBBRMgdPjv63QpU29k4tUwCY78',
    status: 1,
    create_time: '2025-05-13 16:56:51',
    last_use_time: null,
    use_count: 0,
    description: '456'
  }
]

// 系统设置数据 (基于 settings 表)
export const mockSettings = {
  site_title: '小小怪卡密验证系统',
  site_subtitle: '专业的卡密验证解决方案',
  copyright_text: '小小怪卡密系统 - All Rights Reserved',
  contact_qq_group: '123456789',
  contact_wechat_qr: 'assets/images/wechat-qr.jpg',
  contact_email: 'support@example.com',
  api_enabled: '1',
  api_key: 'c3d01e574865a180a20f71c4a0e41c07'
}

// 轮播图数据 (基于 slides 表)
export const mockSlides = [
  {
    id: 1,
    title: '安全可靠的验证系统',
    description: '采用先进的加密技术，确保您的数据安全',
    image_url: 'assets/images/slide1.jpg',
    sort_order: 1,
    status: 1,
    create_time: '2025-05-06 09:13:25'
  },
  {
    id: 2,
    title: '便捷高效的验证流程',
    description: '支持多种验证方式，快速响应',
    image_url: 'assets/images/slide2.jpg',
    sort_order: 2,
    status: 1,
    create_time: '2025-05-06 09:13:25'
  },
  {
    id: 3,
    title: '完整的API接口',
    description: '提供丰富的接口，便于集成',
    image_url: 'assets/images/slide3.jpg',
    sort_order: 3,
    status: 1,
    create_time: '2025-05-06 09:13:25'
  }
]

// 功能特性数据 (基于 features 表)
export const mockFeatures = [
  {
    id: 1,
    icon: 'fas fa-shield-alt',
    title: '安全可靠',
    description: '采用先进的加密技术，确保卡密数据安全\n数据加密存储\n防暴力破解\n安全性验证',
    sort_order: 1,
    status: 1
  },
  {
    id: 2,
    icon: 'fas fa-code',
    title: 'API接口',
    description: '提供完整的API接口，支持多种验证方式\nRESTful API\n多种验证方式\n详细接口文档',
    sort_order: 2,
    status: 1
  },
  {
    id: 3,
    icon: 'fas fa-tachometer-alt',
    title: '高效稳定',
    description: '系统运行稳定，响应迅速\n快速响应\n稳定运行\n性能优化',
    sort_order: 3,
    status: 1
  },
  {
    id: 4,
    icon: 'fas fa-chart-line',
    title: '数据统计',
    description: '详细的数据统计和分析功能\n实时统计\n数据分析\n图表展示',
    sort_order: 4,
    status: 1
  }
]

// 卡密价格配置数据
export const mockCardPrices = {
  timeCards: [
    { id: 1, duration: 7, price: 9.9, description: '7天时间卡' },
    { id: 2, duration: 15, price: 18.8, description: '15天时间卡' },
    { id: 3, duration: 30, price: 35.0, description: '30天时间卡' },
    { id: 4, duration: 60, price: 65.0, description: '60天时间卡' },
    { id: 5, duration: 90, price: 90.0, description: '90天时间卡' },
    { id: 6, duration: 180, price: 168.0, description: '180天时间卡' }
  ],
  countCards: [
    { id: 1, count: 50, price: 12.0, description: '50次使用卡' },
    { id: 2, count: 100, price: 22.0, description: '100次使用卡' },
    { id: 3, count: 200, price: 40.0, description: '200次使用卡' },
    { id: 4, count: 500, price: 95.0, description: '500次使用卡' },
    { id: 5, count: 1000, price: 180.0, description: '1000次使用卡' }
  ]
}

// 购买记录模拟数据
export const mockPurchaseHistory = [
  {
    id: 1,
    orderNo: 'ORD202501150001',
    cardType: 'time',
    specification: '30天',
    quantity: 2,
    unitPrice: 35.0,
    totalPrice: 70.0,
    purchaseTime: '2025-01-15 14:30:00',
    status: 'paid',
    paymentMethod: 'alipay'
  },
  {
    id: 2,
    orderNo: 'ORD202501120002',
    cardType: 'count',
    specification: '100次',
    quantity: 1,
    unitPrice: 22.0,
    totalPrice: 22.0,
    purchaseTime: '2025-01-12 09:15:00',
    status: 'paid',
    paymentMethod: 'wechat'
  },
  {
    id: 3,
    orderNo: 'ORD202501100003',
    cardType: 'time',
    specification: '7天',
    quantity: 5,
    unitPrice: 9.9,
    totalPrice: 49.5,
    purchaseTime: '2025-01-10 16:45:00',
    status: 'pending',
    paymentMethod: 'alipay'
  }
]

// 模拟购买卡密API
export const mockPurchaseCard = (cardType, optionId, quantity) => {
  return new Promise((resolve) => {
    setTimeout(() => {
      const orderNo = 'ORD' + Date.now()
      let specification, unitPrice
      
      if (cardType === 'time') {
        const option = mockCardPrices.timeCards.find(item => item.id === optionId)
        specification = `${option.duration}天`
        unitPrice = option.price
      } else {
        const option = mockCardPrices.countCards.find(item => item.id === optionId)
        specification = `${option.count}次`
        unitPrice = option.price
      }
      
      const totalPrice = unitPrice * quantity
      
      // 模拟生成卡密
      const generatedCards = []
      for (let i = 0; i < quantity; i++) {
        const cardKey = generateRandomCardKey()
        generatedCards.push({
          id: Date.now() + i,
          card_key: cardKey,
          card_type: cardType,
          status: 0,
          create_time: new Date().toLocaleString(),
          ...(cardType === 'time' ? 
            { duration: mockCardPrices.timeCards.find(item => item.id === optionId).duration } :
            { total_count: mockCardPrices.countCards.find(item => item.id === optionId).count, remaining_count: mockCardPrices.countCards.find(item => item.id === optionId).count }
          )
        })
      }
      
      // 添加到购买记录
      const newRecord = {
        id: Date.now(),
        orderNo,
        cardType,
        specification,
        quantity,
        unitPrice,
        totalPrice,
        purchaseTime: new Date().toLocaleString(),
        status: 'paid',
        paymentMethod: 'alipay',
        cards: generatedCards
      }
      
      mockPurchaseHistory.unshift(newRecord)
      
      resolve({
        success: true,
        message: `成功购买 ${quantity} 张${cardType === 'time' ? '时间' : '次数'}卡`,
        data: {
          orderNo,
          cards: generatedCards,
          totalPrice
        }
      })
    }, 1500) // 模拟支付处理时间
  })
}

// 生成随机卡密
function generateRandomCardKey() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  let result = ''
  for (let i = 0; i < 20; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return result
}

// 模拟登录验证函数
export const mockLogin = (username, password, userType) => {
  return new Promise((resolve) => {
    // 模拟网络延迟
    setTimeout(() => {
      let user = null
      
      if (userType === 'admin') {
        // 验证管理员
        user = mockAdmins.find(admin => 
          admin.username === username && admin.password === password
        )
        
        if (user) {
          resolve({
            success: true,
            message: '管理员登录成功',
            token: 'mock_admin_token_' + Date.now(),
            userInfo: {
              id: user.id,
              username: user.username,
              email: null,
              nickname: user.username,
              role: 'admin', // 修改为role字段
              userType: 'admin'
            }
          })
        } else {
          resolve({
            success: false,
            message: '管理员用户名或密码错误'
          })
        }
      } else {
        // 验证普通用户 (支持用户名或邮箱登录)
        user = mockUsers.find(u => 
          (u.username === username || u.email === username) && 
          u.password === password &&
          u.status === 1 // 只允许启用的用户登录
        )
        
        if (user) {
          resolve({
            success: true,
            message: '用户登录成功',
            token: 'mock_user_token_' + Date.now(),
            userInfo: {
              id: user.id,
              username: user.username,
              email: user.email,
              nickname: user.nickname,
              role: 'user', // 修改为role字段
              userType: 'user'
            }
          })
        } else {
          resolve({
            success: false,
            message: '用户名/邮箱或密码错误，或账户已被禁用'
          })
        }
      }
    }, 800) // 模拟800ms的网络延迟
  })
}

// 模拟检查登录状态
export const mockCheckLoginStatus = () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      const userInfo = localStorage.getItem('userInfo')
      const isLoggedIn = localStorage.getItem('isLoggedIn')
      
      if (userInfo && isLoggedIn === 'true') {
        resolve({
          success: true,
          userInfo: JSON.parse(userInfo)
        })
      } else {
        resolve({
          success: false,
          message: '未登录'
        })
      }
    }, 200)
  })
}

// 模拟登出
export const mockLogout = () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      localStorage.removeItem('userInfo')
      localStorage.removeItem('isLoggedIn')
      resolve({
        success: true,
        message: '登出成功'
      })
    }, 300)
  })
}

// 订单管理模拟数据
export const mockOrdersData = [
  {
    id: 1,
    order_id: 'ORD20250101001',
    user_id: 1001,
    username: 'user001',
    card_type: 'time',
    card_spec: '30天',
    quantity: 2,
    unit_price: 29.99,
    total_price: 59.98,
    purchase_time: '2025-01-01 10:30:15',
    status: 'completed',
    payment_method: '支付宝',
    card_keys: ['ABC123DEF456', 'GHI789JKL012'],
    remark: '正常购买'
  },
  {
    id: 2,
    order_id: 'ORD20250101002',
    user_id: 1002,
    username: 'user002',
    card_type: 'count',
    card_spec: '100次',
    quantity: 1,
    unit_price: 19.99,
    total_price: 19.99,
    purchase_time: '2025-01-01 14:22:30',
    status: 'completed',
    payment_method: '微信支付',
    card_keys: ['MNO345PQR678'],
    remark: '首次购买'
  },
  {
    id: 3,
    order_id: 'ORD20250102001',
    user_id: 1003,
    username: 'user003',
    card_type: 'time',
    card_spec: '7天',
    quantity: 5,
    unit_price: 9.99,
    total_price: 49.95,
    purchase_time: '2025-01-02 09:15:45',
    status: 'pending',
    payment_method: '支付宝',
    card_keys: [],
    remark: '批量购买，待处理'
  },
  {
    id: 4,
    order_id: 'ORD20250102002',
    user_id: 1001,
    username: 'user001',
    card_type: 'count',
    card_spec: '50次',
    quantity: 3,
    unit_price: 12.99,
    total_price: 38.97,
    purchase_time: '2025-01-02 16:45:20',
    status: 'completed',
    payment_method: '银行卡',
    card_keys: ['STU901VWX234', 'YZA567BCD890', 'EFG123HIJ456'],
    remark: '重复购买用户'
  },
  {
    id: 5,
    order_id: 'ORD20250103001',
    user_id: 1004,
    username: 'user004',
    card_type: 'time',
    card_spec: '90天',
    quantity: 1,
    unit_price: 79.99,
    total_price: 79.99,
    purchase_time: '2025-01-03 11:30:10',
    status: 'failed',
    payment_method: '支付宝',
    card_keys: [],
    remark: '支付失败'
  },
  {
    id: 6,
    order_id: 'ORD20250103002',
    user_id: 1005,
    username: 'user005',
    card_type: 'count',
    card_spec: '200次',
    quantity: 2,
    unit_price: 35.99,
    total_price: 71.98,
    purchase_time: '2025-01-03 15:20:35',
    status: 'completed',
    payment_method: '微信支付',
    card_keys: ['KLM789NOP012', 'QRS345TUV678'],
    remark: '大客户订单'
  },
  {
    id: 7,
    order_id: 'ORD20250104001',
    user_id: 1002,
    username: 'user002',
    card_type: 'time',
    card_spec: '15天',
    quantity: 4,
    unit_price: 15.99,
    total_price: 63.96,
    purchase_time: '2025-01-04 08:45:25',
    status: 'refunded',
    payment_method: '支付宝',
    card_keys: [],
    remark: '用户申请退款'
  },
  {
    id: 8,
    order_id: 'ORD20250104002',
    user_id: 1006,
    username: 'user006',
    card_type: 'count',
    card_spec: '25次',
    quantity: 6,
    unit_price: 8.99,
    total_price: 53.94,
    purchase_time: '2025-01-04 13:10:50',
    status: 'completed',
    payment_method: '银行卡',
    card_keys: ['WXY901ZAB234', 'CDE567FGH890', 'IJK123LMN456', 'OPQ789RST012', 'UVW345XYZ678', 'ABC901DEF234'],
    remark: '小额多次购买'
  }
]

// 模拟获取订单列表
export const mockGetOrders = (params = {}) => {
  return new Promise((resolve) => {
    setTimeout(() => {
      let filteredOrders = [...mockOrdersData]
      
      // 按状态筛选
      if (params.status && params.status !== 'all') {
        filteredOrders = filteredOrders.filter(order => order.status === params.status)
      }
      
      // 按卡密类型筛选
      if (params.cardType && params.cardType !== 'all') {
        filteredOrders = filteredOrders.filter(order => order.card_type === params.cardType)
      }
      
      // 按用户名搜索
      if (params.username) {
        filteredOrders = filteredOrders.filter(order => 
          order.username.toLowerCase().includes(params.username.toLowerCase())
        )
      }
      
      // 按订单号搜索
      if (params.orderId) {
        filteredOrders = filteredOrders.filter(order => 
          order.order_id.toLowerCase().includes(params.orderId.toLowerCase())
        )
      }
      
      // 按时间范围筛选
      if (params.startDate && params.endDate) {
        filteredOrders = filteredOrders.filter(order => {
          const orderDate = new Date(order.purchase_time)
          const start = new Date(params.startDate)
          const end = new Date(params.endDate)
          return orderDate >= start && orderDate <= end
        })
      }
      
      // 分页处理
      const page = params.page || 1
      const pageSize = params.pageSize || 10
      const startIndex = (page - 1) * pageSize
      const endIndex = startIndex + pageSize
      const paginatedOrders = filteredOrders.slice(startIndex, endIndex)
      
      resolve({
        success: true,
        data: {
          orders: paginatedOrders,
          total: filteredOrders.length,
          page: page,
          pageSize: pageSize,
          totalPages: Math.ceil(filteredOrders.length / pageSize)
        }
      })
    }, 500)
  })
}

// 模拟获取订单详情
export const mockGetOrderDetail = (orderId) => {
  return new Promise((resolve) => {
    setTimeout(() => {
      const order = mockOrdersData.find(order => order.order_id === orderId)
      if (order) {
        resolve({
          success: true,
          data: order
        })
      } else {
        resolve({
          success: false,
          message: '订单不存在'
        })
      }
    }, 300)
  })
}

// 模拟更新订单状态
export const mockUpdateOrderStatus = (orderId, status, remark = '') => {
  return new Promise((resolve) => {
    setTimeout(() => {
      const orderIndex = mockOrdersData.findIndex(order => order.order_id === orderId)
      if (orderIndex !== -1) {
        mockOrdersData[orderIndex].status = status
        if (remark) {
          mockOrdersData[orderIndex].remark = remark
        }
        resolve({
          success: true,
          message: '订单状态更新成功'
        })
      } else {
        resolve({
          success: false,
          message: '订单不存在'
        })
      }
    }, 400)
  })
}