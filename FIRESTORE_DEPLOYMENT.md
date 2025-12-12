# Firestore Security Rules Deployment

## Option 1: Deploy via Firebase CLI (Recommended)

### Prerequisites
Install Firebase CLI if you haven't already:
```bash
npm install -g firebase-tools
```

### Deploy Steps

1. **Login to Firebase**
```bash
firebase login
```

2. **Initialize Firebase (if not already done)**
```bash
firebase init firestore
```
- Select your project: `payservices-7827a`
- Accept default for rules file: `firestore.rules`
- Accept default for indexes file: `firestore.indexes.json`

3. **Deploy Firestore Rules**
```bash
firebase deploy --only firestore:rules
```

---

## Option 2: Manual Deployment via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **payservices-7827a**
3. Navigate to **Firestore Database** → **Rules** tab
4. Copy the contents from `firestore.rules` file
5. Paste into the Rules editor
6. Click **Publish**

---

## Security Rules Overview

The rules in `firestore.rules` provide:

- ✅ **Authentication Required**: Users must be logged in
- ✅ **Own Data Access**: Users can only access their own user document
- ✅ **Create Protection**: Users can create profiles with default security settings
- ✅ **Update Protection**: Users cannot modify security flags (`is_staff`, `is_superuser`)
- ✅ **Admin Access**: Superusers can access all documents

---

## Verify Rules are Active

After deployment, test the app:
1. Run: `flutter run`
2. Login with phone number + OTP
3. Complete profile
4. No permission errors should appear

---

## Troubleshooting

### Permission Denied Error
If you still see permission errors:
1. Wait 30-60 seconds after deployment (rules propagate)
2. Restart the app
3. Check Firebase Console → Firestore Database → Rules tab
4. Verify rules are published (green checkmark)

### Quick Test Rules (Development Only)
For quick testing, use these permissive rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
⚠️ **WARNING**: Replace with proper rules before production!
