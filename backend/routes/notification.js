const express = require('express');
const router = express.Router();
const db = require('../db');

// 📌 Get all notifications (public)
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT n.notificationID,
            u.name AS senderName,
            n.notificationText,
            n.targetType,
            n.targetID,
            n.createdAt
      FROM Notification n
      JOIN User u ON n.senderID = u.userID
      ORDER BY n.createdAt DESC`
    );
    res.json(rows);
  } catch (err) {
    console.error('❌ Error fetching notifications:', err);
    res.status(500).json({ message: 'Failed to fetch notifications' });
  }
});


// 📌 Tạo thông báo mới
router.post('/', async (req, res) => {
  try {
    const { senderID, notificationText } = req.body;

    if (!senderID || !notificationText) {
      return res.status(400).json({ message: 'senderID và notificationText là bắt buộc' });
    }

    const [result] = await db.query(
      `INSERT INTO Notification (senderID, notificationText, createdAt)
       VALUES (?, ?, NOW())`,
      [senderID, notificationText]
    );

    res.status(201).json({ notificationID: result.insertId });
  } catch (err) {
    console.error('❌ Error creating notification:', err);
    res.status(500).json({ message: 'Failed to create notification' });
  }
});

module.exports = router;
