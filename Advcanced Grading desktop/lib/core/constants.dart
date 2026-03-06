// lib/core/constants.dart
// Central place for all application-wide constants.

/// Score constraint constants
class ScoreConstraints {
  static const double maxCaScore = 30.0;
  static const double maxExamScore = 70.0;
  static const double maxFinalScore = 100.0;
  static const double minScore = 0.0;
}

/// Default grade boundary ranges
class DefaultGradeBoundaries {
  static const Map<String, List<double>> ranges = {
    'A': [80.0, 100.0],
    'B': [70.0, 79.99],
    'C': [60.0, 69.99],
    'D': [50.0, 59.99],
    'F': [0.0, 49.99],
  };
}

/// Hive box names for local persistence
class HiveBoxes {
  static const String vaultBox = 'vault_box';
  static const String settingsBox = 'settings_box';
}

/// Hive type IDs
class HiveTypeIds {
  static const int vaultItem = 0;
  static const int studentRecord = 1;
  static const int gradeBoundary = 2;
}

/// Common column name patterns for auto-detection
class ColumnPatterns {
  static const List<String> caPatterns = [
    'ca', 'continuous assessment', 'coursework', 'ca score',
    'continuous_assessment', 'ca_score', 'test', 'internal',
  ];

  static const List<String> examPatterns = [
    'exam', 'examination', 'exam score', 'final exam',
    'exam_score', 'external', 'written',
  ];

  static const List<String> namePatterns = [
    'name', 'student', 'student name', 'full name',
    'student_name', 'fullname', 'pupil',
  ];
}

/// Navigation indices
class NavIndex {
  static const int home = 0;
  static const int vault = 1;
  static const int settings = 2;
}
