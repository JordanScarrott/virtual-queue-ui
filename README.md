# Red Duck - Virtual Queuing App

Red Duck is a Flutter application for a Virtual Queuing system. It allows users to join a business's queue and track their position in real-time.

## Prerequisites

Before running this application, ensure you have the following installed:

1.  **Flutter SDK:** Follow the official installation guide for your operating system: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
2.  **Code Editor:** VS Code (recommended) or Android Studio with Flutter/Dart plugins installed.
3.  **Git:** To clone the repository.

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd red_duck
    ```

2.  **Install dependencies:**
    Open a terminal in the project root and run:
    ```bash
    flutter pub get
    ```

## Running the Application

You can run the application on your desktop (macOS, Windows, Linux) or a mobile emulator/physical device.

### Run on Desktop (macOS/Windows/Linux)

1.  Ensure your desktop environment is set up for Flutter development (see the installation guide above).
2.  Run the following command:
    ```bash
    flutter run -d macos  # or windows, or linux
    ```

### Run on Mobile (Android/iOS)

1.  Start your Android Emulator or iOS Simulator, or connect a physical device via USB.
2.  Run the following command:
    ```bash
    flutter run
    ```
    If multiple devices are connected, list them with `flutter devices` and specify the device ID:
    ```bash
    flutter run -d <device-id>
    ```

## Network Configuration for Testing

The app communicates with a backend service.

*   **Default Behavior (Localhost):** By default, the app tries to connect to `http://localhost:8080`. This works well when running the app on a Desktop simulator or Android Emulator (which maps localhost correctly often, but see note below).
*   **Physical Devices:** If you are testing on a real phone connected to the same Wi-Fi as your backend, `localhost` will refer to the phone itself, not your computer. You need to point the app to your computer's local IP address.

**To change the Network Settings:**
1.  On the "Join Queue" screen, tap the **Settings (Gear)** icon in the top right corner.
2.  Toggle "Use Localhost" **OFF**.
3.  The app will now use the configured physical device IP (default is `192.168.1.5:8080`).
    *   *Note:* You may need to update the `_physicalDeviceUrl` constant in `lib/core/network/dio_client.dart` to match your actual computer's local IP address.

## Project Structure

This project follows **Clean Architecture** principles:

*   `lib/core`: Core utilities (Networking, etc.).
*   `lib/features/queue`: The main feature module.
    *   `data`: Repositories implementation and API models.
    *   `domain`: Business entities and repository interfaces.
    *   `presentation`: BLoC (State Management) and UI Pages.
