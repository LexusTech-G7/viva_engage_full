const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all users
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT userID, name, email, role, department, avatarURL, createdAt, status 
       FROM User`
    );

    // Đảm bảo không null field quan trọng
    const users = rows.map(u => ({
      ...u,
      avatarURL: u.avatarURL || '',
      department: u.department || '',
      createdAt: u.createdAt || new Date()
    }));

    res.json(users);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi lấy danh sách user', error: err });
  }
});

// Register user
router.post('/register', async (req, res) => {
  const { name, email, password, role, department, avatarURL } = req.body;

  try {
    // Check email tồn tại
    const [exist] = await db.query(`SELECT userID FROM User WHERE email = ?`, [email]);
    if (exist.length > 0) {
      return res.status(400).json({ message: 'Email đã tồn tại' });
    }

    const [result] = await db.query(
      `INSERT INTO User (name, email, password, role, department, avatarURL, createdAt, status)
       VALUES (?, ?, ?, ?, ?, ?, NOW(), 'active')`,
      [name, email, password, role, department || '', avatarURL || '']
    );

    res.status(201).json({
      userID: result.insertId,
      name,
      email,
      role,
      department: department || '',
      avatarURL: avatarURL || '',
      status: 'active',
      createdAt: new Date().toISOString()
    });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi tạo user', error: err });
  }
});



// Login user
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  console.log("📩 Login body:", { email, password });

  try {
    const [rows] = await db.query(
      `SELECT userID, name, email, role, department, avatarURL, createdAt, status 
       FROM User 
       WHERE email = ? AND password = ? AND status = 'active'`,
      [email, password]
    );

    if (rows.length === 0) {
      return res.status(401).json({ message: 'Sai email hoặc mật khẩu' });
    }

    // Tránh null ở các field Flutter yêu cầu
    const user = rows[0];
    user.avatarURL = user.avatarURL || '';
    user.department = user.department || '';
    user.createdAt = user.createdAt || new Date();

    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error });
  }
});

// Get user by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query(
      `SELECT userID, name, email, role, department, avatarURL, createdAt, status 
       FROM User WHERE userID = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Đảm bảo không trả null
    const user = rows[0];
    user.avatarURL = user.avatarURL || '';
    user.department = user.department || '';
    user.createdAt = user.createdAt || new Date();

    res.json(user);
  } catch (err) {
    console.error('❌ Error fetching user:', err);
    res.status(500).json({ message: 'Lỗi lấy thông tin user' });
  }
});


module.exports = router;
