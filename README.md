# Lemmy Handshake

Mobile tool to synchronize multiple accounts across instances

### What can be synced
- Communities subscribed across accounts
- Saved posts and comments
- Blocked users and communities

### What can't be synced
- Account posts
- Account comments
- Account votes

## Feedback
Feedbacks are welcome and feel free to create issues about any bugs found or recomendations

## Screenshots
<img alt="Home page" src="https://sh.itjust.works/pictrs/image/0c3afffa-c7cb-4c42-8c9d-d856ff7a17df.webp?format=webp" width="200"/>
<img alt="Sync page" src="https://sh.itjust.works/pictrs/image/c6170306-9625-4488-b5c7-f1211ebf21a2.webp" width="200"/>

## How to install
Soon I'll build the app and release an alpha version here, so you can download the APK and install in your phone.
Once the app is stable I'll also look forward to place it on store apps, like F-Droid and Play Store 

## Authors
- [@gusVLZ](https://www.github.com/gusVLZ)

### Build with flutter
I'm doing this with flutter because of the compatibility across plataforms, for now I'm targeting android devices but later I'll focus on release IPhone and Desktop versions

### Thanks to
 - Wescode who created the account migration tool that inspired this project [lemmy_migrate](https://github.com/wescode/lemmy_migrate)
 - Every lemmy user who supported me and provided feedback to improve the app, especially:
   - db2@sopuli.xyz who brought the idea to sync blocked users and communities
   - lemonadebunny@lemmy.ca who gave great UI advices when I was struggling over the app design
   - Oha@feddit.de who suggested using Material You 
   - naticus@lemmy.world and Rouxibeau@lemmy.world who suggested renaming the app from sync to handshake

---
---

## How to contribute:


### Prerequisites

Before you begin, ensure that you have the following software installed on your system:

1. **Flutter SDK**: Flutter is a requirement for building Android apps using Flutter. You can install it by following the instructions on the official Flutter website: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

2. **Android Studio**: Android Studio is the preferred IDE for Flutter development as it offers excellent tools for Android app development. Download and install Android Studio from the official website: [Android Studio Download](https://developer.android.com/studio)

3. **Device or Emulator**: You can use a physical Android device or an Android emulator provided by Android Studio for testing your Flutter app.

### Getting Started

1. **Clone the Repository**: Clone or download the Flutter Android project repository to your local machine.

   ```
   git clone https://github.com/gusVLZ/lemmy_handshake.git
   ```

2. **Open the Project**: Open Android Studio and select "Open an existing Android Studio project." Navigate to the directory where you cloned the repository and open the `android` subfolder as the project.

3. **Install Dependencies**: Flutter projects require external packages and dependencies. Open a terminal in the project's root directory and run:

   ```
   flutter pub get
   ```

### Running the Project

#### Using Android Studio

1. In Android Studio, ensure that you have a target device or emulator set up and running. You can create and configure virtual devices via the AVD Manager.

2. Click the "Run" button (green play icon) in the top menu or use the keyboard shortcut `Shift` + `F10` (Windows/Linux) or `Control` + `R` (macOS) to build and run the Flutter Android app on the selected device/emulator.

#### Using the Command Line

You can also run your Flutter Android project using the command line:

1. Open a terminal in the project's root directory.

2. To list available devices and emulators, run:

   ```
   flutter devices
   ```

3. Choose a device or emulator from the list and run the app:

   ```
   flutter run -d <device_name>
   ```
