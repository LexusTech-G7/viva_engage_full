const express = require('express');
const router = express.Router();
const db = require('../db');

// 📝 Lấy tất cả post của community user đã tham gia
router.get('/user/:userID', async (req, res) => {
  const { userID } = req.params;
  try {
    const [rows] = await db.query(
      `SELECT 
         p.postID,
         p.userID,
         p.communityID,
         p.postType,
         p.title,
         p.body,
         p.tagList,
         CAST(p.isPinned AS UNSIGNED) AS isPinned,
         CAST(p.viewCount AS UNSIGNED) AS viewCount,
         p.createdAt,
         u.name AS author,
         c.name AS community
       FROM Post p
       JOIN Community c ON p.communityID = c.communityID
       JOIN UserCommunity uc ON c.communityID = uc.communityID
       JOIN User u ON p.userID = u.userID
       WHERE uc.userID = ?
       ORDER BY p.isPinned DESC, p.createdAt DESC`,
      [userID]
    );

    // 🔄 Format createdAt thành ISO string
    const formattedRows = rows.map(row => ({
      ...row,
      createdAt: row.createdAt ? new Date(row.createdAt).toISOString() : null
    }));

    res.json(formattedRows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch posts for user' });
  }
});

// 📌 Lấy post theo postID
router.get('/:postID', async (req, res) => {
  try {
    const { postID } = req.params;
    const [rows] = await db.query(
      `SELECT 
         p.postID,
         p.userID,
         p.communityID,
         p.postType,
         p.title,
         p.body,
         p.tagList,
         CAST(p.isPinned AS UNSIGNED) AS isPinned,
         CAST(p.viewCount AS UNSIGNED) AS viewCount,
         p.createdAt,
         u.name AS author,
         c.name AS community
       FROM Post p
       JOIN Community c ON p.communityID = c.communityID
       JOIN User u ON p.userID = u.userID
       WHERE p.postID = ?`,
      [postID]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Format createdAt
    const post = {
      ...rows[0],
      createdAt: rows[0].createdAt ? new Date(rows[0].createdAt).toISOString() : null
    };

    res.json(post);
  } catch (err) {
    console.error('❌ Error fetching post by ID:', err);
    res.status(500).json({ message: 'Failed to fetch post' });
  }
});

// 📝 Tạo post mới
router.post('/', async (req, res) => {
  console.log('📩 Create Post Body:', req.body);
  const { userID, communityID, postType, title, body, tagList, isPinned = 0, viewCount = 0 } = req.body;

  try {
    const [result] = await db.query(
      `INSERT INTO Post (userID, communityID, postType, title, body, tagList, isPinned, viewCount, createdAt)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
      [userID, communityID, postType, title, body, tagList || null, isPinned, viewCount]
    );

    const newPostID = result.insertId;

    // 🔔 Notification broadcast: thêm targetType và targetID
    await db.query(`
      INSERT INTO Notification (senderID, notificationText, targetType, targetID, createdAt)
      SELECT ?, CONCAT(u.name, ' đã đăng bài trong cộng đồng ', c.name, ': ', ?), 'post', ?, NOW()
      FROM User u
      JOIN Community c ON c.communityID = ?
      WHERE u.userID = ?
    `, [userID, title, newPostID, communityID, userID]);

    res.status(201).json({ postID: newPostID });

  } catch (err) {
    console.error('❌ Error creating post:', err);
    res.status(500).json({ error: 'Failed to create post' });
  }
});



module.exports = router;
