# 📌 Viva Engage - Nền tảng Mạng xã hội Nội bộ

**Viva Engage** là một ứng dụng mạng xã hội nội bộ được phát triển mô phỏng theo Yammer/Viva Engage của Microsoft. Dự án được xây dựng với mục đích học tập và demo các công nghệ liên quan.

* **Backend**: Node.js, Express.js, MySQL
* **Frontend**: Flutter (sử dụng Material 3)

Ứng dụng cung cấp các tính năng cốt lõi như: đăng nhập, đăng ký, tạo bài viết, bình luận, tương tác, tham gia cộng đồng, đính kèm tệp (demo qua link Google Drive), và quản lý thông báo.

---

## 📂 Cấu trúc thư mục

```

.
├── backend/                 \# Source code Backend (Node.js + Express)
│   ├── db.js                \# Cấu hình kết nối MySQL
│   ├── index.js             \# Khởi tạo server và các middleware
│   ├── routes/              \# Định tuyến các API endpoints
│   │   ├── user.js
│   │   ├── post.js
│   │   ├── comment.js
│   │   ├── attachment.js
│   │   ├── reaction.js
│   │   └── notification.js
│   └── ...
│
├── frontend/                \# Source code Frontend (Flutter)
│   ├── lib/
│   │   ├── models/          \# Các data models
│   │   ├── services/        \# Logic gọi API
│   │   ├── screens/         \# Các màn hình của ứng dụng
│   │   ├── widgets/         \# Các UI component tái sử dụng
│   │   └── main.dart        \# Điểm khởi đầu của ứng dụng
│   └── pubspec.yaml         \# Quản lý dependencies
│
└── README.md                \# Tài liệu hướng dẫn dự án

````

---

## ⚙️ Backend Setup (Node.js + MySQL)

### 1. Cài đặt Dependencies

Điều hướng đến thư mục `backend` và cài đặt các package cần thiết.

```bash
cd backend
npm install
````

### 2\. Cấu hình Cơ sở dữ liệu

  * Tạo một database mới trong MySQL với tên `viva_engage`.
  * Import schema cho các bảng. Dưới đây là ví dụ cho bảng `User`.

<!-- end list -->

```sql
CREATE DATABASE viva_engage;
USE viva_engage;

-- Bảng người dùng (User)
CREATE TABLE User (
  userID INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'user',
  department VARCHAR(100),
  avatarURL TEXT,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) DEFAULT 'active'
);

-- (Thực thi các script SQL khác để tạo bảng Post, Comment, Reaction, etc.)
```

  * Cập nhật thông tin kết nối database trong file `backend/db.js`:

<!-- end list -->

```javascript
// backend/db.js
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '', // Mật khẩu của bạn
  database: 'viva_engage'
});

module.exports = pool;
```

### 3\. Chạy Backend Server

```bash
npm start
```

> ✅ Server sẽ chạy mặc định tại địa chỉ: `http://localhost:3000`

-----

## 📱 Frontend Setup (Flutter)

### 1\. Cài đặt Dependencies

Điều hướng đến thư mục `frontend` và cài đặt các package.

```bash
cd frontend
flutter pub get
```

### 2\. Cấu hình API URL

Mở các file service trong `lib/services/` và cập nhật biến `baseUrl` để trỏ đến địa chỉ backend của bạn.

```dart
// Ví dụ: lib/services/api_service.dart
class ApiService {
  // Mặc định cho iOS Simulator/Web/Desktop
  static const String baseUrl = 'http://localhost:3000/api';

  // 💡 Lưu ý quan trọng cho Android Emulator:
  // static const String baseUrl = '[http://10.0.2.2:3000/api](http://10.0.2.2:3000/api)';
}
```

> **Lưu ý:** Khi chạy trên **Android Emulator**, bạn phải sử dụng địa chỉ `10.0.2.2` thay cho `localhost` để kết nối đến máy chủ local của bạn.

### 3\. Chạy Ứng dụng

```bash
flutter run
```

-----

## 🌟 Các Tính Năng Chính

  * ✅ **Xác thực**: Đăng nhập, Đăng ký (hỗ trợ phân quyền `Role` và phòng ban `Department`).
  * ✅ **Bảng tin (Feed)**: Hiển thị các bài viết mới nhất từ những người bạn theo dõi hoặc trong cộng đồng.
  * ✅ **Bài viết (Post)**: Tạo bài viết mới với nội dung văn bản, có thể ghim (Pin) bài viết quan trọng.
  * ✅ **Tương tác**: Bình luận (Comment) và bày tỏ cảm xúc (Reaction: Like, Love, Haha...).
  * ✅ **Cộng đồng (Communities)**: Tham gia và đăng bài trong các nhóm chuyên đề.
  * ✅ **Thông báo (Notification)**: Nhận thông báo thời gian thực về các tương tác mới.
  * ✅ **Đính kèm (Attachment)**: Demo đính kèm tệp qua link Google Drive.
  * ✅ **Trang cá nhân (Profile)**: Xem và chỉnh sửa thông tin cá nhân.

-----

## 🔗 API Endpoints Tiêu Biểu

| Method | Endpoint | Mô tả |
| :--- | :--- | :--- |
| `POST` | `/api/users/register` | Đăng ký tài khoản người dùng mới. |
| `POST` | `/api/users/login` | Đăng nhập vào hệ thống. |
| `GET` | `/api/posts` | Lấy danh sách tất cả bài viết. |
| `GET` | `/api/posts/:id` | Lấy chi tiết một bài viết. |
| `POST` | `/api/posts` | Tạo một bài viết mới. |
| `GET` | `/api/comments/:postID` | Lấy tất cả bình luận của bài viết. |
| `POST` | `/api/comments` | Thêm một bình luận mới. |
| `POST` | `/api/reactions/:postID` | Thêm/thay đổi reaction cho bài viết. |
| `GET` | `/api/attachments/:postID` | Lấy danh sách tệp đính kèm. |

-----

## 📝 Ghi chú

  * Tính năng **Attachment** được demo bằng cách sử dụng link Google Drive. Link cần được chuyển đổi sang định dạng xem trực tiếp (`uc?export=view&id=...`) để ứng dụng có thể tải và hiển thị.
  * Dự án này được xây dựng cho mục đích học tập, vì vậy phần backend **chưa triển khai cơ chế xác thực bằng JWT** hoặc các biện pháp bảo mật nâng cao.
  * Để có trải nghiệm tốt nhất, hãy chạy thử nghiệm trên môi trường `localhost` hoặc trong cùng một mạng LAN.

-----

## 👨‍💻 Tác giả

  * **Backend & Database**: Node.js, Express.js, MySQL
  * **Frontend**: Flutter (Provider for State Management, Material 3)
  * **Người thực hiện**: LexusTech G7

<!-- end list -->

```
```