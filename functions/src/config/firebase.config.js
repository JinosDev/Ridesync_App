const admin = require('firebase-admin');

let initialized = false;

function initFirebase() {
  if (initialized) return;

  if (process.env.NODE_ENV === 'production') {
    // In Cloud Functions, use Application Default Credentials
    admin.initializeApp();
  } else {
    // Local development — use service account env vars
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId:   process.env.FIREBASE_PROJECT_ID,
        privateKey:  process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      }),
      databaseURL: `https://${process.env.FIREBASE_PROJECT_ID}-default-rtdb.asia-southeast1.firebasedatabase.app`,
    });
  }
  initialized = true;
}

initFirebase();

module.exports = { admin, db: admin.firestore(), rtdb: admin.database(), auth: admin.auth(), messaging: admin.messaging() };
