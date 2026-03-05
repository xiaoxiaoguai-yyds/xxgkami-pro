# Android 客户端 API 接口文档

本文档描述了 Android 客户端与后端服务器交互的完整 API 接口。

## 1. 基础信息

*   **Base URL**: `http://<服务器IP>:8080/api` (开发环境) 或 `https://<域名>/api` (生产环境)
*   **认证方式**: Bearer Token
    *   登录成功后获取 `token`。
    *   后续请求在 Header 中添加: `Authorization: Bearer <token>`
*   **数据格式**: JSON

---

## 2. 用户认证 (Auth)

### 2.1 发送邮箱验证码
用于注册或重置密码时验证邮箱。

*   **接口**: `POST /auth/email-code`
*   **参数**:
    ```json
    {
      "email": "user@example.com",
      "type": "register"  // "register" (注册) 或 "reset" (重置密码)
    }
    ```
*   **响应**:
    ```json
    {
      "success": true,
      "message": "验证码已发送",
      "data": null
    }
    ```

### 2.2 用户注册
*   **接口**: `POST /auth/register`
*   **参数**:
    ```json
    {
      "username": "myuser",
      "password": "mypassword",
      "email": "user@example.com",
      "code": "123456" // 邮箱收到的验证码
    }
    ```
*   **响应**:
    ```json
    {
      "success": true,
      "message": "注册成功",
      "data": null
    }
    ```

### 2.3 用户登录
*   **接口**: `POST /auth/user/login`
*   **参数**:
    ```json
    {
      "username": "myuser",
      "password": "mypassword"
    }
    ```
*   **响应**:
    ```json
    {
      "success": true,
      "message": "登录成功",
      "data": {
        "token": "eyJhbGciOiJIUzI1NiJ9...",
        "refreshToken": "...",
        "userInfo": {
          "id": 1,
          "username": "myuser",
          "role": "user",
          "email": "user@example.com",
          "nickname": "Nick",
          "avatar": "...",
          "createTime": "..."
        }
      }
    }
    ```

### 2.4 获取绑定 Token (Web端生成二维码)
此接口通常由 Web 端调用以生成绑定二维码，App 端扫码获取 Token。

*   **接口**: `GET /auth/bind/token`
*   **Header**: `Authorization: Bearer <token>`
*   **响应**:
    ```json
    {
      "success": true,
      "message": "获取成功",
      "data": {
        "token": "uuid-token-string"
      }
    }
    ```

### 2.5 验证绑定 Token (App端扫码绑定)
App 扫码获取二维码中的 `userId` 和 `token` 后调用此接口验证绑定。
注意：此 Token 为一次性使用，验证成功后即失效。生成新 Token 会导致旧 Token 失效。

*   **接口**: `POST /auth/bind/validate`
*   **参数**:
    ```json
    {
      "userId": 1,
      "token": "uuid-token-string"
    }
    ```
*   **响应**:
    ```json
    {
      "success": true, // true 表示绑定/验证成功
      "message": "验证成功", // 或 "验证失败或Token已过期"
      "data": null
    }
    ```

---

## 3. 用户信息 (User)

### 3.1 获取个人资料
*   **接口**: `GET /user/profile`
*   **Header**: `Authorization: Bearer <token>`
*   **响应**:
    ```json
    {
      "id": 1,
      "username": "myuser",
      "nickname": "Nick",
      "email": "user@example.com",
      "phone": "13800000000",
      "avatar": "url",
      "createTime": "2023-01-01T12:00:00",
      "hasPassword": true
    }
    ```

### 3.2 更新个人资料
*   **接口**: `PUT /user/profile`
*   **Header**: `Authorization: Bearer <token>`
*   **参数**:
    ```json
    {
      "nickname": "NewNick",
      "email": "new@example.com",
      "phone": "13900000000"
    }
    ```
*   **响应**:
    ```json
    {
      "success": true,
      "message": "个人信息更新成功"
    }
    ```

### 3.3 修改密码
*   **接口**: `POST /user/password`
*   **Header**: `Authorization: Bearer <token>`
*   **参数**:
    ```json
    {
      "oldPassword": "oldpass",
      "newPassword": "newpass"
    }
    ```
*   **响应**:
    ```json
    {
      "success": true,
      "message": "密码修改成功"
    }
    ```

---

## 4. 卡密管理 (Card)

### 4.1 获取我的卡密
*   **接口**: `GET /cards/user/{userId}`
*   **Header**: `Authorization: Bearer <token>`
*   **路径参数**:
    *   `userId`: 用户ID
*   **响应**:
    ```json
    {
      "success": true,
      "data": [
        {
          "id": 1,
          "cardNo": "CARD123456",
          "cardType": "monthly",
          "status": "active", // active, used, expired
          "createTime": "...",
          "useTime": "..."
        },
        ...
      ]
    }
    ```

---

## 5. 订单管理 (Order)

### 5.1 创建订单
*   **接口**: `POST /orders`
*   **Header**: `Authorization: Bearer <token>`
*   **参数**:
    ```json
    {
      "userId": 1,
      "username": "myuser",
      "cardType": "monthly",
      "cardSpec": "standard",
      "quantity": 1,
      "paymentMethod": "alipay", // alipay, wechat, usdt
      "email": "user@example.com", // 接收卡密邮箱
      "pricingId": 1 // 价格配置ID
    }
    ```
*   **响应**:
    ```json
    {
      "success": true,
      "message": "下单成功",
      "paymentUrl": "http://payment.url...", // 如果需要支付
      "data": {
        "id": 1001,
        "orderNo": "ORD2023...",
        "status": "pending",
        "amount": 10.00
      }
    }
    ```

### 5.2 获取我的订单
*   **接口**: `GET /orders`
*   **Header**: `Authorization: Bearer <token>`
*   **URL 参数**:
    *   `userId`: 用户ID
*   **响应**:
    ```json
    [
      {
        "id": 1001,
        "orderNo": "ORD2023...",
        "status": "paid",
        "amount": 10.00,
        "createTime": "...",
        "cardType": "monthly"
      },
      ...
    ]
    ```
