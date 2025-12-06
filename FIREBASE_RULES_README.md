# Firebase Security Rules Setup

## Overview
This document explains the Firebase Storage security rules configured for the Book My Spa app.

## Storage Rules (`storage.rules`)

### Spa Photos (`/spa_photos/`)
- **Read**: ✅ Authenticated users only
- **Write**: ✅ Authenticated users only
- **Constraints**:
  - Max file size: **5 MB** (prevents large file abuse)
  - File type: **Images only** (JPEG, PNG, WebP, GIF, etc.)
  - Pattern: `image/.*` (enforced at upload)

### Spa Documents (`/spa_documents/`)
- **Read**: ✅ Authenticated users only
- **Write**: ✅ Authenticated users only
- **Constraints**:
  - Max file size: **10 MB** (documents can be slightly larger)
  - File type: **Images only** (Aadhar, PAN, Business License scans)
  - Pattern: `image/.*` (enforced at upload)

### All Other Paths
- **Read/Write**: ❌ Denied by default (default-deny security posture)

## Firestore Rules (`firestore.rules`)

### Spa Collection (`/spas/{spaId}`)
- **Read/Write**: ✅ Authenticated users only
- Use this collection to store spa metadata if needed (e.g., spa name, owner, location data, uploaded file URLs)

## Deployment Steps

### 1. Install Firebase CLI (if not already installed)
```bash
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Initialize Firebase in your project (if not done)
```bash
firebase init
```
Select:
- ✅ Firestore
- ✅ Storage

### 4. Deploy Storage Rules
```bash
firebase deploy --only storage
```

### 5. Deploy Firestore Rules
```bash
firebase deploy --only firestore
```

### 6. Deploy Both (recommended)
```bash
firebase deploy
```

## Security Best Practices

1. **Authentication Required**: All uploads require Firebase Authentication (Google Sign-In in your app).
2. **File Size Limits**: Prevent DoS attacks via large file uploads.
3. **Content Type Validation**: Only images allowed; prevents script/malware uploads.
4. **Default-Deny Posture**: Any path not explicitly allowed is denied.
5. **No Deletion Rules**: Users cannot delete files (prevents accidental/malicious data loss).

## Future Enhancements

- Add per-user quota limits (e.g., max 50 MB total per user).
- Require metadata validation (e.g., spa ID as a custom claim in JWT).
- Add rules to allow admins to read/delete any spa data.
- Implement time-based expiry for temporary uploads.

## Testing Rules Locally

Before deploying to production, test rules locally:
```bash
firebase emulators:start
```
Then in your Flutter app, connect to the local emulator and test uploads.

## Troubleshooting

### "Upload failed: Permission denied"
- ✅ Ensure user is authenticated (check `firebase_auth` initialization).
- ✅ Verify file size is under limit (5MB for photos, 10MB for documents).
- ✅ Confirm file MIME type is an image type.

### "Rules deployment failed"
- ✅ Check Firebase CLI is logged in (`firebase login`).
- ✅ Ensure you're in the correct project directory.
- ✅ Run `firebase list` to verify your Firebase project is active.
