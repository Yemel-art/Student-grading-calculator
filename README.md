# Student Grader — Flutter App

A production-ready Flutter app for teachers to upload Excel (.xlsx) grade sheets and automatically calculate, display, and export student grades.

---

## Features

| Feature | Details |
|---|---|
| **File Upload** | Native file picker for `.xlsx` files |
| **Smart Detection** | Auto-detects Name & Marks columns (fuzzy header matching) |
| **Grade Calculation** | A (90+) · B (80–89) · C (70–79) · D (60–69) · F (<60) |
| **Sortable Table** | Sort by name, marks, or grade — tap column headers |
| **Progress Bar** | Per-row mark bar with colour coding |
| **Stats Dashboard** | Class average, top score, pass rate |
| **Grade Distribution** | Visual badges showing count per grade |
| **Export to Excel** | Styled .xlsx with summary row — shared via OS sheet |
| **Export to PDF** | A4 report with header, stats, striped table, colour-coded grades |
| **Error Handling** | Corrupted files, missing columns, invalid data, out-of-range marks |
| **Warnings** | Skipped rows listed in a bottom sheet with reasons |
| **Animated Loading** | Step-by-step processing feedback |
| **Material 3** | Clean navy + teal theme with `Outfit` font |

---

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── theme/
│   └── app_theme.dart           # All colours, text styles, component themes
├── models/
│   └── student_record.dart      # StudentRecord + GradeSummary data models
├── providers/
│   └── grader_provider.dart     # ChangeNotifier — all state & Excel parsing
├── services/
│   └── export_service.dart      # Excel + PDF export logic
├── widgets/
│   └── common_widgets.dart      # GradeChip, DistBadge, StatCard, ExportButton, etc.
└── screens/
    ├── home_screen.dart          # AnimatedSwitcher orchestrating all states
    ├── upload_screen.dart        # Drop zone + format guide
    ├── loading_screen.dart       # Animated step indicator
    ├── results_screen.dart       # Sortable table + export + stats
    └── error_screen.dart         # User-friendly error display
```

---

## Setup

### Prerequisites
- Flutter SDK ≥ 3.2.0 ([flutter.dev](https://flutter.dev/docs/get-started/install))
- Dart SDK ≥ 3.2.0
- Android Studio or Xcode for device/simulator

### 1. Create a new Flutter project

```bash
flutter create student_grader
cd student_grader
```

### 2. Replace generated files

Copy the following from this package into your project:
- `pubspec.yaml` → replace the root `pubspec.yaml`
- `lib/` → replace the entire `lib/` directory
- `android/app/src/main/AndroidManifest.xml` → replace the Android manifest
- Merge `ios/Runner/Info.plist` keys into your existing Info.plist

### 3. Add fonts (optional but recommended)

Download the **Outfit** font from [Google Fonts](https://fonts.google.com/specimen/Outfit) and place the `.ttf` files at:
```
assets/
  fonts/
    Outfit-Regular.ttf
    Outfit-Medium.ttf
    Outfit-SemiBold.ttf
    Outfit-Bold.ttf
    Outfit-ExtraBold.ttf
```

Or remove the `fonts` section from `pubspec.yaml` and remove `fontFamily: 'Outfit'` from `app_theme.dart` to fall back to the system font.

### 4. Install dependencies

```bash
flutter pub get
```

### 5. Android — set minimum SDK

In `android/app/build.gradle`:
```groovy
android {
    defaultConfig {
        minSdkVersion 21      // Required by file_picker
        targetSdkVersion 34
    }
}
```

### 6. Run

```bash
# List available devices
flutter devices

# Run on a connected device or emulator
flutter run

# Release build
flutter build apk --release
flutter build ios --release
```

---

## Excel File Format

| Student Name | Total Marks |
|---|---|
| Alice Johnson | 92 |
| Bob Martinez | 75 |
| Clara Chen | 58 |

**Column detection rules (case-insensitive):**
- Name column: header must contain `name` or `student`
- Marks column: header must contain `marks`, `score`, `total`, or `point`
- Marks values must be numeric and between 0–100

---

## Grading Scale

| Grade | Range |
|---|---|
| A | 90 – 100 |
| B | 80 – 89 |
| C | 70 – 79 |
| D | 60 – 69 |
| F | below 60 |

To change the scale, edit `StudentRecord.computeGrade()` in `lib/models/student_record.dart`.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.2 | State management |
| `file_picker` | ^6.1.1 | Native file selection |
| `excel` | ^4.0.2 | Read/write .xlsx files |
| `pdf` | ^3.10.7 | PDF generation |
| `printing` | ^5.12.0 | Share/print PDFs |
| `path_provider` | ^2.1.2 | Temp directory for exports |
| `share_plus` | ^7.2.2 | OS share sheet |
| `permission_handler` | ^11.3.0 | Runtime permissions |
