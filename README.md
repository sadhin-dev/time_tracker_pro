# Time Tracker Pro

A sophisticated attendance tracking application built with Flutter, utilizing Bloc/Cubit architecture to create a modular mobile experience. This application focuses on attendance tracking with dynamic data import from Excel files and comprehensive state management for tracking employee attendance and late arrivals.

## Features ✨

- **Excel Data Import**: Import attendance records directly from Excel files
- **Attendance Tracking**: Monitor employee check-in times and attendance patterns
- **Late Arrival Detection**: Automatically identifies and reports late employee arrivals
- **State Management**: Implemented using Flutter Bloc/Cubit pattern with Equatable for efficient state comparisons
- **Responsive UI**: Modern, adaptive interface with reusable shared components
- **Multi-Environment Support**: Development and production flavor configurations
- **Splash Screen**: Branded startup experience with automatic navigation

## Getting Started 🛠️

### Prerequisites

- Flutter SDK 3.0+
- Dart 2.17+
- Android Studio or Xcode for mobile development

### Installation

```bash
flutter pub get
```

### Running the App

**Development Mode:**
```bash
flutter run --flavor development --target lib/main/main_development.dart
```

**Production Mode:**
```bash
flutter run --flavor production --target lib/main/main_production.dart
```

## Architecture 🏗️

### Project Structure

```markdown
lib/
├── app/
│   └── app.dart                 # Main application entry point
├── features/
│   ├── attendance/              # Attendance tracking functionality
│   │   ├── attendance_cubit.dart
│   │   ├── attendance_state.dart
│   │   └── attendance_view.dart
│   ├── home/                    # Home screen (template)
│   │   ├── home_cubit.dart
│   │   ├── home_state.dart
│   │   └── home_view.dart
│   └── startup/                 # Splash screen and initial routing
│       └── startup_view.dart
├── main/
│   ├── bootstrap.dart           # Application bootstrapping
│   ├── main_development.dart
│   └── main_production.dart
├── models/
│   └── enums/
│       └── flavor.dart          # Environment configuration
├── services/                    # Template services (commented out)
├── shared/                      # Reusable UI components and utilities
│   ├── app_colors.dart
│   ├── button.dart
│   ├── card.dart
│   ├── tab_bar.dart
│   ├── text_style.dart
│   └── ui_helpers.dart
└── utils/
    └── flavors.dart             # Flavor management utilities
```

### Key Patterns

- **Bloc/Cubit Architecture**: State management using flutter_bloc package
- **Equatable**: Efficient state comparisons to prevent unnecessary rebuilds
- **Dependency Injection**: Centralized bootstrapping through bootstrap.dart
- **Flavor Management**: Environment-specific configurations for development/production

### Major Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | sdk | Flutter framework |
| flutter_bloc | ^8.1.3 | State management using Bloc/Cubit pattern |
| equatable | ^2.0.5 | Efficient state comparison for Bloc states |

## Development 🛠️

### Testing

```bash
flutter test
```

### Code Formatting

```bash
flutter format .
```

### Building

**Android:**
```bash
flutter build apk --flavor production --target lib/main/main_production.dart
```

**iOS:**
```bash
flutter build ios --flavor production --target lib/main/main_production.dart
```

## Contributing & License 📄

### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

### License

This project is proprietary software. All rights reserved.

---

*Time Tracker Pro - Modern attendance tracking solution*