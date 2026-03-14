const express = require('express');
const router  = express.Router();
const { auth }     = require('../../config/firebase.config');
const { db }       = require('../../config/firebase.config');
const validate = require('../../middleware/validate.middleware');
const Joi = require('joi');

// POST /api/auth/register — Called after Firebase client SDK creates the user
router.post('/register', async (req, res, next) => {
  try {
    const { name, email, phone } = req.body;
    const uid = req.user.uid;

    // Create Firestore user document
    await db.collection('users').doc(uid).set({
      uid,
      name,
      email,
      phone,
      role:      'passenger',
      createdAt: new Date(),
    });

    // Set custom claim role = passenger
    await auth.setCustomUserClaims(uid, { role: 'passenger' });

    res.status(201).json({ message: 'User registered successfully', uid });
  } catch (err) {
    next(err);
  }
});

// POST /api/auth/set-role — Admin only: assign operator role + busId claim
router.post('/set-role', async (req, res, next) => {
  try {
    const requesterRole = req.user?.role;
    if (requesterRole !== 'admin') return res.status(403).json({ error: 'Admin only' });

    const { uid, role, busId } = req.body;
    const claims = { role };
    if (busId) claims.busId = busId;

    await auth.setCustomUserClaims(uid, claims);
    await db.collection('users').doc(uid).update({ role, ...(busId && { busId }) });

    res.json({ message: `Role '${role}' assigned to user ${uid}` });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
