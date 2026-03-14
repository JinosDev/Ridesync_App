const express  = require('express');
const router   = express.Router();
const axios    = require('axios');
const { DIALOGFLOW_PROJECT_ID } = require('../../config/dialogflow.config');
const { auth } = require('../../config/firebase.config');

/**
 * POST /api/chatbot/message
 * Proxies user message to Dialogflow ES REST API.
 * For production, use @google-cloud/dialogflow SDK instead.
 */
router.post('/message', async (req, res, next) => {
  try {
    const { text, sessionId } = req.body;
    if (!text) return res.status(400).json({ error: 'text is required' });

    // Get access token for Dialogflow
    const tokenClient = new auth.constructor();
    const accessToken = await admin.app().options.credential.getAccessToken();

    const dfRes = await axios.post(
      `https://dialogflow.googleapis.com/v2/projects/${DIALOGFLOW_PROJECT_ID}/agent/sessions/${sessionId || req.user.uid}:detectIntent`,
      {
        queryInput: {
          text: {
            text,
            languageCode: 'en',
          },
        },
      },
      {
        headers: {
          Authorization: `Bearer ${accessToken.access_token}`,
          'Content-Type': 'application/json',
        },
      }
    );

    const fulfillmentText = dfRes.data?.queryResult?.fulfillmentText || "I couldn't understand that.";
    res.json({ data: { reply: fulfillmentText } });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
