const express = require('express');
const router = express.Router();
const db = require('../db');

// 📌 Get poll by postID
router.get('/post/:postID', async (req, res) => {
  try {
    // 1️⃣ Lấy poll
    const [pollRows] = await db.query(
      'SELECT * FROM Poll WHERE postID = ?',
      [req.params.postID]
    );

    if (pollRows.length === 0) {
      return res.status(404).json({ message: 'Poll not found' });
    }

    const poll = pollRows[0];

    // Parse options JSON
    try {
      poll.options = poll.options ? JSON.parse(poll.options) : [];
    } catch {
      poll.options = [];
    }

    // 2️⃣ Lấy votes từ PollVote
    const [voteRows] = await db.query(
      'SELECT userID, optionID FROM PollVote WHERE pollID = ?',
      [poll.pollID]
    );

    // Build voterMap: { userID: optionID }
    const voterMap = {};
    const voteCountMap = {};

    voteRows.forEach(v => {
      voterMap[v.userID] = v.optionID;
      voteCountMap[v.optionID] = (voteCountMap[v.optionID] || 0) + 1;
    });

    // 3️⃣ Gắn số lượng votes vào options
    poll.options = poll.options.map(o => ({
      ...o,
      votes: voteCountMap[o.id] || 0
    }));

    // 4️⃣ Trả về poll + voterMap
    res.json({
      ...poll,
      voterMap
    });

  } catch (err) {
    console.error('❌ Error fetching poll:', err);
    res.status(500).json({ message: 'Failed to fetch poll' });
  }
});

// 📌 Create poll
router.post('/', async (req, res) => {
  try {
    const { postID, title, options, duration } = req.body;

    const [result] = await db.query(
      `INSERT INTO Poll (postID, title, options, duration)
       VALUES (?, ?, ?, ?)`,
      [postID, title, JSON.stringify(options || []), duration]
    );

    res.status(201).json({ pollID: result.insertId });
  } catch (err) {
    console.error('❌ Error creating poll:', err);
    res.status(500).json({ message: 'Failed to create poll' });
  }
});

// 📌 Vote
router.post('/:pollID/vote', async (req, res) => {
  try {
    const { userID, optionID } = req.body;

    await db.query(
      `INSERT INTO PollVote (pollID, userID, optionID)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE optionID = VALUES(optionID)`,
      [req.params.pollID, userID, optionID]
    );

    // 🔔 Notification: broadcast từ người vote (kèm targetType và targetID)
    await db.query(`
      INSERT INTO Notification (senderID, notificationText, targetType, targetID, createdAt)
      SELECT ?, CONCAT(u.name, ' đã vote trong poll: ', p.title), 'poll', p.pollID, NOW()
      FROM Poll p
      JOIN Post post ON p.postID = post.postID
      JOIN User u ON u.userID = ?
      WHERE p.pollID = ?
    `, [userID, userID, req.params.pollID]);

    res.json({ message: 'Vote recorded' });
  } catch (err) {
    console.error('❌ Error voting:', err);
    res.status(500).json({ message: 'Failed to vote' });
  }
});


module.exports = router;
