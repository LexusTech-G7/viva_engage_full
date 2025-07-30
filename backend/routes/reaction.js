const express = require('express');
const router = express.Router();
const db = require('../db');

// 📌 GET reactions của 1 post
router.get('/:postID', async (req, res) => {
  const { postID } = req.params;
  try {
    const [rows] = await db.query(
      `SELECT emoji, COUNT(*) AS count
       FROM Reaction
       WHERE postID = ?
       GROUP BY emoji`,
      [postID]
    );
    const reactions = {};
    rows.forEach(r => { reactions[r.emoji] = r.count });
    res.json(reactions);
  } catch (err) {
    console.error('❌ Error fetching reactions:', err);
    res.status(500).json({ error: 'Failed to fetch reactions' });
  }
});

// 📌 POST add reaction (trả count mới)
router.post('/:postID', async (req, res) => {
  const { postID } = req.params;
  const { emoji, userID } = req.body;

  try {
    // Kiểm tra đã có reaction này chưa
    const [existing] = await db.query(
      `SELECT * FROM Reaction 
       WHERE postID = ? AND userID = ? AND emoji = ?`,
      [postID, userID, emoji]
    );

    if (existing.length > 0) {
      return res.status(409).json({ message: 'Reaction already exists' });
    }

    // Thêm reaction mới
    await db.query(
      `INSERT INTO Reaction (userID, targetType, postID, emoji, createAt)
       VALUES (?, 'post', ?, ?, NOW())`,
      [userID, postID, emoji]
    );

    // Lấy count mới cho emoji này
    const [[countRow]] = await db.query(
      `SELECT COUNT(*) AS count 
       FROM Reaction 
       WHERE postID = ? AND emoji = ?`,
      [postID, emoji]
    );

    res.status(201).json({ emoji, count: countRow.count });
  } catch (err) {
    console.error('❌ Error adding reaction:', err);
    res.status(500).json({ error: 'Failed to add reaction' });
  }
});

// 📌 DELETE remove reaction (trả count mới)
router.delete('/:postID', async (req, res) => {
  const { postID } = req.params;
  const { emoji, userID } = req.body;

  try {
    // Xoá reaction
    await db.query(
      `DELETE FROM Reaction 
       WHERE postID = ? AND userID = ? AND emoji = ?`,
      [postID, userID, emoji]
    );

    // Lấy count mới cho emoji này
    const [[countRow]] = await db.query(
      `SELECT COUNT(*) AS count 
       FROM Reaction 
       WHERE postID = ? AND emoji = ?`,
      [postID, emoji]
    );

    res.json({ emoji, count: countRow.count });
  } catch (err) {
    console.error('❌ Error removing reaction:', err);
    res.status(500).json({ error: 'Failed to remove reaction' });
  }
});

module.exports = router;
