# SmartOffice

![Smart House Banner](assets/images/smart_home_illustration.png)

SmartOffice is a modern, modular Flutter application designed for smart-home management. It features a sophisticated UI and a modular architecture, splitting core functionality into a dedicated `appbot` package.

## ?? Why this repo?
- **Modular Architecture**: Features a local package setup (`appbot`) for better code separation.
- **Firebase Integrated**: Cloud synchronization for real-time status updates and persistence.
- **Provider State Management**: Efficient handling of application state with `ChangeNotifier`.
- **Modern UI**: Material 3 design with responsive layouts and custom animations.

## ?? Features
- **Device Control**: One-tap control for lights, temperature, and security.
- **Smart Chatbot**: Integrated AI/Chat module (via `appbot`) for office automation.
- **Real-time Status**: Room-by-room monitoring.

## ?? Tech Stack
- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Auth, Firestore)
- **State Management**: Provider
- **Local Plugins**: Custom `appbot` package

## ?? Screenshots
*(Add your screenshots here later to show off the UI!)*

## ?? Getting Started
1. Clone the repo.
2. Run `flutter pub get` in the root.
3. (Optional) Run `flutter pub get` inside the `appbot/` folder.
4. Add your own `firebase_options.dart` or keep the template for UI testing.
5. Launch with `flutter run`.

---
*Developed by Sebei Yasmin, Benbrahim Nour, & Lahouar Ameni.*
