# 🎓 Student Grading Calculator

A **Flutter Desktop (Windows)** application for importing, processing, and exporting student grade sheets with automatic CA/Exam column detection and configurable grading systems.

---

## ✨ Features

| Feature | Details |
|---|---|
| **File Import** | CSV, Excel (.xlsx), Google Sheets CSV URL |
| **Auto-detection** | Automatically detects Name, CA, and Exam columns |
| **Grade Calculation** | Final Score = CA (max 30) + Exam (max 70) |
| **Grades** | A / B / C / D / F with configurable ranges |
| **Warning System** | Highlights rows with out-of-range scores |
| **Preview** | Paginated DataTable with search |
| **Statistics** | Class average, grade distribution, warning count |
| **Vault** | Persist sessions to local storage via Hive |
| **Export** | Export processed grades to CSV |
| **Settings** | Customisable grade boundaries, persisted locally |
| **Dark Mode** | Light / Dark theme toggle |

---

## 🗂️ Project Structure

```
lib/
├── core/
│   ├── app_theme.dart          # Material 3 light/dark themes, brand colors
│   ├── constants.dart          # Score constraints, column patterns, box names
│   └── processing_utils.dart  # Higher-order functions (map, filter, forEach)
├── models/
│   ├── student_record.dart    # StudentRecord data class + validateScores() + formatStudentName()
│   ├── grade_boundary.dart    # GradeBoundary config + resolveGrade()
│   └── vault_item.dart        # VaultItem persistence model
├── services/
│   ├── file_parser_service.dart  # CSV/Excel import + column detection
│   ├── export_service.dart       # CSV export to local storage
│   ├── vault_service.dart        # Hive persistence for vault sessions
│   └── settings_service.dart    # Hive persistence for settings
├── controllers/
│   ├── home_controller.dart      # Home view state (ChangeNotifier)
│   ├── vault_controller.dart     # Vault view state (ChangeNotifier)
│   └── settings_controller.dart # Settings state (ChangeNotifier)
├── views/
│   ├── app_shell.dart    # NavigationRail shell
│   ├── home_view.dart    # Import + process + preview
│   ├── vault_view.dart   # Saved sessions list + detail screen
│   └── settings_view.dart # Grade boundary editor
├── widgets/
│   ├── grade_badge.dart          # Colored letter grade chip
│   ├── warning_indicator.dart    # Row warning icon
│   ├── import_progress_panel.dart # Progress bar during file analysis
│   ├── student_data_table.dart   # PaginatedDataTable for records
│   └── stats_summary_bar.dart    # Summary statistics bar
└── main.dart   # Entry point + HOF demonstration
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.10.0  
- Dart SDK ≥ 3.0.0  
- Windows 10/11 (64-bit)  
- Visual Studio 2022 with **Desktop development with C++** workload

### Setup

```bash
# 1. Clone or extract the project
cd student_grading_calculator

# 2. Enable Windows desktop
flutter config --enable-windows-desktop

# 3. Generate Windows runner files
flutter create --platforms=windows .

# 4. Install dependencies
flutter pub get

# 5. Run on Windows
flutter run -d windows

# 6. Build release EXE
flutter build windows --release
```

The release binary will be at:
```
build/windows/x64/runner/Release/student_grading_calculator.exe
```

---

## 📄 Supported CSV Format

Your CSV must have at minimum a **CA column** and an **Exam column**.  
The app auto-detects headers using these patterns:

| Column Type | Detected Keywords |
|---|---|
| **Student Name** | name, student, full name, pupil |
| **CA Score** | ca, continuous assessment, coursework, internal, test |
| **Exam Score** | exam, examination, final exam, external, written |

### Example CSV

```csv
Student Name,CA Score,Exam Score
Alice Johnson,25,62
Bob Smith,18,55
Carol White,28,65
David Brown,20,58
Emma Davis,30,70
```

---

## 🧮 Grade Calculation

```
Final Score = CA Score + Exam Score
```

**Constraints:**
- CA Score ≤ 30
- Exam Score ≤ 70  
- Final Score ≤ 100

**Default Grade Boundaries:**

| Grade | Range |
|---|---|
| A | 80 – 100 |
| B | 70 – 79 |
| C | 60 – 69 |
| D | 50 – 59 |
| F | 0 – 49 |

All ranges are configurable in the **Settings** view.

---

## 🏗️ Architecture

The app follows **Clean Architecture** with:

- **Models** — pure data classes with no Flutter dependencies
- **Services** — I/O (file parsing, export, persistence)
- **Controllers** — `ChangeNotifier` state holders consumed via `Provider`
- **Views** — Flutter widgets that observe controllers
- **Widgets** — reusable, stateless/stateful UI components

### State Management

`Provider` (via `MultiProvider`) is used throughout. Each view consumes its controller via `Consumer<T>` or `context.read<T>()`.

---

## 🔧 Higher-Order Functions

The following HOFs are used (see `lib/core/processing_utils.dart`):

```dart
// map() — calculate final scores for all students
students.map((student) => student.finalScore).toList();

// where() — filter invalid rows
students.where((student) => !student.validateScores()).toList();

// forEach() — assign grades to each student
students.forEach((student) { /* assign grade */ });

// Custom HOF — processStudents accepts a lambda
processStudents(students, (student) {
  print(student.finalScore);
});
```

All of these are demonstrated at startup inside `main()`.

---

## 📦 Key Packages

| Package | Purpose |
|---|---|
| `provider` | State management |
| `file_picker` | Native file selection dialog |
| `csv` | CSV parsing |
| `excel` | Excel parsing |
| `hive_flutter` | Local persistence |
| `path_provider` | Platform file paths |
| `intl` | Date formatting |

---

## 🎨 Design

- **Material 3** design system
- **Primary:** Green (`#2E7D32`)
- **Secondary:** Blue (`#1565C0`)  
- **Accent:** Thick Orange (`#E65100`)
- Modern, clean, minimal aesthetic
- Full light / dark mode support
