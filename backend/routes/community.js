const express = require('express');
const router = express.Router();
const db = require('../db');

// 📌 Lấy danh sách tất cả community và trạng thái joined theo user
router.get('/:userID', async (req, res) => {
  const { userID } = req.params;
  try {
    const [rows] = await db.query(`
      SELECT c.*, 
             CASE WHEN uc.userID IS NOT NULL THEN 1 ELSE 0 END AS joined
      FROM Community c
      LEFT JOIN UserCommunity uc 
        ON c.communityID = uc.communityID 
       AND uc.userID = ?
    `, [userID]);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch communities' });
  }
});

// 📌 Tạo community mới
router.post('/', async (req, res) => {
  const { name, desc, createBy, visibility = 1 } = req.body;
  try {
    const [result] = await db.query(
      `INSERT INTO Community (name, \`desc\`, createBy, createAt, visibility)
       VALUES (?, ?, ?, NOW(), ?)`,
      [name, desc, createBy, visibility]
    );
    res.status(201).json({ communityID: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create community' });
  }
});

// 📌 Join community
router.post('/:communityID/join', async (req, res) => {
  const { communityID } = req.params;
  const { userID } = req.body;

  try {
    await db.query(
      'INSERT IGNORE INTO UserCommunity (userID, communityID, joinedAt) VALUES (?, ?, NOW())',
      [userID, communityID]
    );
    res.sendStatus(200);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to join community' });
  }
});

// 📌 Leave community
router.post('/:communityID/leave', async (req, res) => {
  const { communityID } = req.params;
  const { userID } = req.body;

  try {
    await db.query(
      'DELETE FROM UserCommunity WHERE userID = ? AND communityID = ?',
      [userID, communityID]
    );
    res.sendStatus(200);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to leave community' });
  }
});

// 📌 Lấy các community mà user đã join
router.get('/user/:userID', async (req, res) => {
  const { userID } = req.params;
  try {
    const [rows] = await db.query(`
      SELECT c.* FROM Community c
      JOIN UserCommunity uc ON c.communityID = uc.communityID
      WHERE uc.userID = ?
    `, [userID]);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch user communities' });
  }
});

module.exports = router;
