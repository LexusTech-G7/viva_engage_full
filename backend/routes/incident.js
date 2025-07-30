const express = require('express');
const router = express.Router();
const db = require('../db');

// GET incident by postID
router.get('/post/:postID', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT i.*, 
              u1.name AS openedByName, 
              u2.name AS closedByName
       FROM Incident i
       JOIN User u1 ON i.openedBy = u1.userID
       LEFT JOIN User u2 ON i.closedBy = u2.userID
       WHERE i.postID = ?`,
      [req.params.postID]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Incident not found' });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error('❌ Error fetching incident:', err);
    res.status(500).json({ message: 'Failed to fetch incident' });
  }
});



// 📌 Tạo mới incident
router.post('/', async (req, res) => {
    try {
        const { postID, openedBy, severity, location, status } = req.body;

        const [result] = await db.query(
            `INSERT INTO Incident (postID, severity, location, status, openedBy, openedAt)
       VALUES (?, ?, ?, ?, ?, NOW())`,
            [postID, severity, location, status, openedBy]
        );

        res.status(201).json({ incidentID: result.insertId });
    } catch (err) {
        console.error('❌ Error creating incident:', err);
        res.status(500).json({ message: 'Failed to create incident' });
    }
});

// 📌 Đóng incident
router.put('/close/:incidentID', async (req, res) => {
    try {
        const { closedBy } = req.body;

        // Lấy thời gian mở để tính secondsToClose
        const [incident] = await db.query(
            `SELECT openedAt FROM Incident WHERE incidentID = ?`,
            [req.params.incidentID]
        );

        if (incident.length === 0) {
            return res.status(404).json({ message: 'Incident not found' });
        }

        const openedAt = new Date(incident[0].openedAt);
        const closedAt = new Date();
        const secondsToClose = Math.floor((closedAt - openedAt) / 1000);

        // Update status và thông tin đóng
        await db.query(
            `UPDATE Incident 
       SET status = 'closed', closedBy = ?, closedAt = NOW(), secondsToClose = ?
       WHERE incidentID = ?`,
            [closedBy, secondsToClose, req.params.incidentID]
        );

        res.json({ message: 'Incident closed successfully', secondsToClose });
    } catch (err) {
        console.error('❌ Error closing incident:', err);
        res.status(500).json({ message: 'Failed to close incident' });
    }
});


module.exports = router;
