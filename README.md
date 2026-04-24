# Poultry Path 🐔

Poultry Path is a high-performance, offline-first farm management system designed for poultry farmers. It provides deep visibility into production, financials, and health metrics, enabling data-driven decisions at the shed level.

## Key Features
- **Batch Lifecycle Management**: Track birds from day 1 to harvest.
- **Advanced Calculation Engine**: Real-time ROI, FCR (Feed Conversion Ratio), Mortality Rates, and Break-even analysis.
- **Automated Decision Engine**: Smart alerts for health and productivity anomalies.
- **Task Scheduling & Notifications**: Auto-generated daily tasks and vaccination reminders.
- **Interactive Analytics**: Rich visualizers for profit trends and cost distributions.
- **PDF Reporting**: Export professional performance reports.
- **Offline-First Architecture**: Powered by Hive for ultra-fast, local-first data access.

## Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (2.0)
- **Local Storage**: Hive (NoSQL)
- **Charts**: fl_chart
- **Routing**: go_router
- **Theming**: Brutalist-inspired Dark-Tech (Optimized for Light Mode)

## Project Structure
- `lib/core`: Design system, constants, theme, and common utilities.
- `lib/data`: Hive models (Adapters 0–11) and Repositories.
- `lib/features`: Feature-based modules (Dashboard, Batch, Analytics, Tasks, Settings).
- `lib/services`: Business logic (CalculationEngine, NotificationService, PDFService).

## Setup Instructions
1. Ensure Flutter is installed.
2. Run `flutter pub get`.
3. Run `dart run build_runner build` to generate Hive adapters.
4. Run `flutter run` (supports Android/iOS/Web).

## Design System
Poultry Path utilizes a "Precision Brutalist" design system:
- **Typography**: Inter (Modern/Clean)
- **Colors**: High-contrast, accessibility-focused light palette.
- **Interactions**: Haptic feedback, smooth transitions, and loading skeletons.

## Production Checklist
- [x] Package Name: `com.poultrypath.app`
- [x] Min SDK: 26 (Android)
- [x] Encrypted/Typed Hive Boxes
- [x] Automated Integration Tests
- [x] 0 Compilation Warnings
