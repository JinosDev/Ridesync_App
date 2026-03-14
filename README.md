# RideSync 🚌

**Smart Public Bus Transportation Platform** — Sri Lanka

A multi-role public transport system with real-time GPS tracking, online seat booking, dynamic fare calculation, and push notifications.

## Project Structure

```
Ridesync_App/
├── firebase.json              # Firebase project config (Functions, Hosting, Firestore, RTDB, Storage)
├── firestore.rules            # Database security rules
├── firestore.indexes.json     # Composite indexes  
├── database.rules.json        # RTDB security rules
├── storage.rules              # Storage security rules
├── .github/workflows/         # CI/CD pipeline
│
├── mobile/                    # Flutter Mobile App (Passenger + Operator)
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── firebase_options.dart  ← run: flutterfire configure
│       ├── core/              # Constants, theme, utils, widgets
│       ├── features/
│       │   ├── auth/
│       │   ├── booking/
│       │   ├── tracking/
│       │   ├── fare/
│       │   ├── operator/
│       │   ├── notifications/
│       │   ├── chatbot/
│       │   ├── feedback/
│       │   └── profile/
│       ├── router/            # GoRouter config + route names
│       └── services/          # HiveService, ApiClient, FCM handler
│
└── functions/                 # Node.js Express REST API (Firebase Cloud Functions)
    ├── package.json
    ├── .env.example           ← copy to .env and fill in
    └── src/
        ├── app.js
        ├── index.js           # Firebase Functions entry point
        ├── config/            # Firebase, Maps, Twilio, Dialogflow
        ├── middleware/        # Auth, RBAC, Validate, ErrorHandler
        └── modules/
            ├── auth/
            ├── booking/       ⭐ Firestore transaction for atomic seat lock
            ├── route/
            ├── schedule/
            ├── fare/          ⭐ BASE(20) + km × 5 × classMultiplier
            ├── notification/
            ├── analytics/
            └── chatbot/
```

## Tech Stack

| Layer    | Technology |
|----------|-----------|
| Mobile   | Flutter + Riverpod + GoRouter + Firebase |
| Backend  | Node.js + Express + Firebase Cloud Functions |
| Database | Cloud Firestore + Firebase RTDB |
| Auth     | Firebase Authentication + Custom Claims |
| Maps     | Google Maps Flutter + Geolocator |
| Chat     | Dialogflow ES + WebView |
| Push     | Firebase Cloud Messaging |
| Cache    | Hive (offline) + node-cache (API) |

## Setup Guide

### 1. Firebase Project

```bash
npm install -g firebase-tools
firebase login
firebase init   # Select: Functions, Firestore, RTDB, Storage, Hosting, Emulators
```

### 2. Flutter Mobile App

```bash
cd mobile
flutter pub get

# Configure Firebase
dart pub global activate flutterfire_cli
flutterfire configure  # Generates firebase_options.dart

# Add google-services.json (Android) to: mobile/android/app/
# Add GoogleService-Info.plist (iOS) to: mobile/ios/Runner/

# Run in development
flutter run --dart-define=API_BASE_URL=http://localhost:5001/ridesync-prod/asia-southeast1/api \
            --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY
```

### 3. Node.js Backend

```bash
cd functions
npm install

# Copy and fill environment variables
cp .env.example .env

# Local development with Firebase emulators
firebase emulators:start --only functions,firestore,database,auth

# Run tests
npm test
```

### 4. Deploy to Firebase

```bash
firebase deploy --only functions,firestore,database,storage
```

## Roles & Access

| Role      | Capabilities |
|-----------|-------------|
| passenger | Search routes, book seats, track bus, view fare |
| operator  | View assigned schedules, start/end trip, GPS broadcast, report delays |
| admin     | Full access — set roles, manage routes/schedules/fares, view analytics |

## Admin Web Dashboard

The admin web interface is maintained in a **separate GitHub repository**.  
It connects to the same Firebase project using the same Firestore collections and API endpoints.  
Contact the admin team for the repository URL.

## Environment Variables

See `functions/.env.example` for all required backend environment variables.

## Key Architecture Decisions

- **Firestore transactions** for atomic seat locking — prevents double-booking
- **Firebase RTDB** for sub-second GPS location streaming
- **RTDB-triggered Cloud Function** for automatic ETA recalculation
- **Custom Claims** for RBAC (role + busId) — enforced on both client and server
- **Hive** for offline booking e-ticket access
- **Adaptive GPS interval** — 3s when moving, 10s when stationary (battery optimization)