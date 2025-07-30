const express = require('express');
const router = express.Router();
const db = require('../db');

function convertDriveLink(url) {
  const match = url.match(/\/d\/([a-zA-Z0-9_-]+)/);
  if (match && match[1]) {
    return `https://drive.google.com/uc?export=view&id=${match[1]}`;
  }
  return url; // nếu không phải link drive thì trả về nguyên gốc
}

// 📌 Lấy tất cả attachments của 1 post
router.get('/post/:postID', async (req, res) => {
  try {
    const { postID } = req.params;
    const [rows] = await db.query(
      'SELECT * FROM Attachment WHERE postID = ?',
      [postID]
    );
    res.json(rows);
  } catch (err) {
    console.error('❌ Error fetching attachments:', err);
    res.status(500).json({ message: 'Failed to fetch attachments' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { postID, name, type, url, uploadedBy } = req.body;

    if (!postID || !name || !type || !url || !uploadedBy) {
      return res.status(400).json({ message: 'Thiếu thông tin attachment' });
    }

    const finalUrl = convertDriveLink(url);

    const [result] = await db.query(
      `INSERT INTO Attachment (postID, name, type, url, uploadedBy, uploadedAt)
       VALUES (?, ?, ?, ?, ?, NOW())`,
      [postID, name, type, finalUrl, uploadedBy]
    );

    res.status(201).json({ attachmentID: result.insertId, finalUrl });
  } catch (err) {
    console.error('❌ Error creating attachment:', err);
    res.status(500).json({ message: 'Failed to create attachment' });
  }
});

module.exports = router;
