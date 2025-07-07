# Deployment Guide

## Deploying to Web (Firebase Hosting Example)

1. Build the web app:
   ```sh
   flutter build web
   ```
2. Install Firebase CLI (if not already):
   ```sh
   npm install -g firebase-tools
   ```
3. Login to Firebase:
   ```sh
   firebase login
   ```
4. Initialize Firebase in your project (if not already):
   ```sh
   firebase init
   ```
5. Deploy:
   ```sh
   firebase deploy
   ```

See the [Firebase Hosting documentation](https://firebase.google.com/docs/hosting) for more details. 