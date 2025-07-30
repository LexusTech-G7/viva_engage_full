const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all questions of a post
router.get('/:postID', async (req, res) => {
  const [rows] = await db.query('SELECT * FROM Question WHERE postID = ?', [req.params.postID]);
  res.json(rows);
});

// Add a question
router.post('/', async (req, res) => {
  const { postID, questionText } = req.body;
  const [result] = await db.query(
    `INSERT INTO Question (postID, questionText, isResolved)
     VALUES (?, ?, 0)`,
    [postID, questionText]
  );
  res.status(201).json({ questionID: result.insertId });
});

module.exports = router;
