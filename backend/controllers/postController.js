const db = require('../db');

exports.getAllPosts = (req, res) => {
  db.query('SELECT * FROM Post', (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
};

exports.getPostById = (req, res) => {
  const id = req.params.id;
  db.query('SELECT * FROM Post WHERE postID = ?', [id], (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results[0]);
  });
};
