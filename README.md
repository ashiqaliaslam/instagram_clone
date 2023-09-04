# instantgram_clone

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```CEL
rules_version = '2';
service cloud.firestore {
    match /databases/{database}/documents {
        match /{collectionName}/{document=**} {
            allow read, update: if request.auth != null;
            allow create: if request.auth != null;
            allow delete: if request.auth != null && ((collectionName == "likes" || collectionName == "comments") || request.auth.uid == resource.data.uid);
        }
    }
}
```
