# Task Management App

A beautiful task management app for gig workers built with Flutter, Firebase, and BLoC state management.

![Flutter](https://img.shields.io/badge/Flutter-3.8+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![BLoC](https://img.shields.io/badge/State-BLoC-purple.svg)

## Features

- **Authentication**: Email/password login with Firebase
- **Task Management**: Create, edit, delete, and complete tasks
- **Smart Organization**: Auto-group tasks by Today, Tomorrow, This Week
- **Priority Levels**: Color-coded badges (Low, Medium, High)
- **Real-time Sync**: Instant updates across all devices
- **Filtering**: Filter by priority and completion status
- **Material Design 3**: Beautiful, responsive UI

## Architecture

This app follows **Clean Architecture** principles with:

- **Domain Layer**: Business entities and logic
- **Data Layer**: Firebase integration and models
- **Presentation Layer**: UI with BLoC state management

## Quick Start


### Installation

1. **Clone the repository**

```bash
cd notes_assignment
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Firebase**

#### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

#### Option B: Manual Configuration

- Create a Firebase project
- Enable Email/Password authentication
- Create a Firestore database
- Replace placeholders in `lib/firebase_options.dart`

See [FIREBASE_SETUP.md](.gemini/antigravity/brain/944af0ce-04b4-496e-9f2f-47527f2ce6aa/FIREBASE_SETUP.md) for detailed instructions.

4. **Run the app**

```bash
flutter run
```

## Project Structure

```
lib/
├── core/                    # Shared utilities
│   ├── constants/          # Colors, strings
│   ├── theme/              # App theme
│   └── utils/              # Helper functions
├── features/
│   ├── auth/               # Authentication feature
│   │   ├── data/           # Firebase Auth repository
│   │   ├── domain/         # User entity
│   │   └── presentation/   # Auth screens & BLoC
│   └── tasks/              # Task management feature
│       ├── data/           # Firestore repository
│       ├── domain/         # Task entity
│       └── presentation/   # Task screens & BLoC
└── main.dart               # App entry point
```