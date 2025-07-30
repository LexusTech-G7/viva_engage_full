const express = require('express');
const router = express.Router();
const db = require('../db');

// 📌 Get comments for a post
router.get('/:postID', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT c.commentID, c.userID, c.postID, c.commentText, c.createdAt, 
              u.name AS author, u.avatarURL
       FROM Comment c
       JOIN User u ON c.userID = u.userID
       WHERE c.postID = ? 
       ORDER BY c.createdAt ASC`,
      [req.params.postID]
    );
    res.json(rows);
  } catch (err) {
    console.error('❌ Error fetching comments:', err);
    res.status(500).json({ message: 'Failed to fetch comments' });
  }
});

// 📌 Add comment + tạo Notification broadcast
router.post('/', async (req, res) => {
  const { userID, postID, commentText } = req.body;
  try {
    // Thêm comment
    const [result] = await db.query(
      `INSERT INTO Comment (userID, postID, commentText, createdAt)
       VALUES (?, ?, ?, NOW())`,
      [userID, postID, commentText]
    );

    // 🔔 Notification broadcast
    await db.query(`
      INSERT INTO Notification (senderID, notificationText, targetType, targetID, createdAt)
      SELECT ?, CONCAT(u.name, ' đã bình luận vào bài: ', p.title), 'post', p.postID, NOW()
      FROM Post p
      JOIN User u ON u.userID = ?
      WHERE p.postID = ? AND p.userID != ?
    `, [userID, userID, postID, userID]);

    res.status(201).json({ commentID: result.insertId });

  } catch (err) {
    console.error('❌ Error creating comment:', err);
    res.status(500).json({ message: 'Failed to create comment' });
  }
});


module.exports = router;
