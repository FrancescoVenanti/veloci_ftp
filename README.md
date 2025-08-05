# VelociFTP

A modern, zen-inspired FTP client built with Flutter, designed for simplicity and elegance across all platforms.

## Features

- Clean, minimalist interface with zen-inspired design
- Cross-platform support (iOS, Android, macOS, Windows, Linux, Web)
- Session management with saved connections
- File browsing and navigation
- Download functionality with progress tracking
- File operations (delete, properties)
- Secure credential storage
- Responsive design optimized for both mobile and desktop

## Installation

### Download Release
Download the latest release for your platform from the releases page.

### Windows
Run the `velociFTP.exe` file directly - no installation required.

### Development
```bash
git clone <repository-url>
flutter pub get
flutter run
```

## Why Choose VelociFTP?

**Minimal and Beautiful**: Unlike bloated FTP clients with overwhelming interfaces, VelociFTP focuses on essential functionality with a clean, zen-inspired design that reduces visual clutter and cognitive load.

**Session Management**: Save your frequently used connections with secure credential storage. No more typing server details repeatedly - just click and connect.

**Cross-Platform**: One beautiful interface across all your devices. Start on desktop, continue on mobile, with the same intuitive experience everywhere.

**Modern Technology**: Built with Flutter for smooth performance, responsive design, and native feel on every platform.

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
├── screens/                  # UI screens
├── services/                 # Business logic and API services
├── theme/                    # App theming and styling
├── utils/                    # Utility functions
└── widgets/                  # Reusable UI components
```

## FAQ

**Q: How do I save a connection for later use?**
A: Click the menu icon on the connection screen, then "Add Session" to save your server details. Your credentials are stored securely.

**Q: Can I use this with SFTP or secure connections?**
A: Currently supports standard FTP. FTPS and SFTP support are planned for future releases.

**Q: Where are my downloaded files saved?**
A: Files are saved to your system's default Downloads folder. Desktop versions will show the exact path after download.

**Q: Does this work offline?**
A: The app requires an internet connection to access FTP servers. Session management works offline.

**Q: Is my connection data secure?**
A: Yes, all saved credentials are encrypted and stored locally on your device using platform-specific secure storage.

**Q: Can I connect to multiple servers simultaneously?**
A: Currently, the app supports one active connection at a time. Multiple connections are planned for future updates.

## Dependencies

- `ftpconnect`: FTP connectivity
- `shared_preferences`: Local data persistence
- `path_provider`: File system access

## License

This project is licensed under the MIT License.
