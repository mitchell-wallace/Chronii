# chronii-time

A simple task management tool, with task timers and todos. Supports cloud syncing 
as well as anonymous use. Currently supports web and Windows, with Android coming
soon.

## Getting Started

To build, make sure Flutter is installed. Run with

```bash
flutter run -d chrome
```

or

```bash
flutter run -d windows
```

or use equivalent build commands. Note that currently this project requires Firebase
to be set up in order to run.

## Firebase Setup

### 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a 
new project
2. Give your project a name (e.g., "chronii-time")
3. Enable Google Analytics if desired and follow the setup steps

### 2. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 3. Configure Firebase for Your App

1. In your project directory, run:

```bash
flutterfire configure --project=your-firebase-project-id
```

2. Select the platforms you want to support (Android, Web, Windows)
3. This will generate `firebase_options.dart` and `firebase.json` files

### 4. Enable Firebase Services

1. Authentication:
   - In the Firebase Console, go to Authentication → Sign-in methods
   - Enable Email/Password authentication
   - Enable Anonymous authentication

2. Firestore Database:
   - Go to Firestore Database and create a database
   - Start in production mode or test mode
   - Choose a location for your database
   - Set up security rules for your database:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /todos/{todoId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /timers/{timerId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Known Issues

* Currently, anonymous mode isn't working correctly.



