// lib/main.dart
// Application entry point.
//
// Demonstrates required higher-order function usage in main():
//   1. Create a list of StudentRecord objects
//   2. Filter students with invalid scores using where()
//   3. Pass a lambda to processStudents() custom HOF
//
// Then bootstraps the Flutter desktop application.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/app_theme.dart';
import 'core/processing_utils.dart';
import 'models/student_record.dart';
import 'models/grade_boundary.dart';
import 'services/file_parser_service.dart';
import 'services/export_service.dart';
import 'services/vault_service.dart';
import 'services/settings_service.dart';
import 'controllers/home_controller.dart';
import 'controllers/vault_controller.dart';
import 'controllers/settings_controller.dart';
import 'views/app_shell.dart';
import 'views/home_view.dart';

// =============================================================================
// MAIN() — includes required HOF demonstration block
// =============================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Initialise local storage
  // ---------------------------------------------------------------------------
  await Hive.initFlutter();
  await VaultService.init();
  await SettingsService.init();

  // ---------------------------------------------------------------------------
  // HOF DEMONSTRATION (Spec §11)
  // ---------------------------------------------------------------------------

  // 1. Create a list of StudentRecord objects with sample data
  final defaultBoundaries = buildDefaultBoundaries();
  final sampleStudents = <StudentRecord>[
    StudentRecord.fromRaw(
      name: 'Alice Johnson',
      caScore: 25,
      examScore: 62,
      rowIndex: 0,
      gradeResolver: (s) => resolveGrade(s, defaultBoundaries),
    ),
    StudentRecord.fromRaw(
      name: 'BOB SMITH',
      caScore: 18,
      examScore: 55,
      rowIndex: 1,
      gradeResolver: (s) => resolveGrade(s, defaultBoundaries),
    ),
    // Invalid: CA score exceeds 30
    StudentRecord.fromRaw(
      name: 'carol white',
      caScore: 35, // ← exceeds max of 30
      examScore: 50,
      rowIndex: 2,
      gradeResolver: (s) => resolveGrade(s, defaultBoundaries),
    ),
    // Invalid: Exam score exceeds 70
    StudentRecord.fromRaw(
      name: 'David Brown',
      caScore: 20,
      examScore: 75, // ← exceeds max of 70
      rowIndex: 3,
      gradeResolver: (s) => resolveGrade(s, defaultBoundaries),
    ),
    StudentRecord.fromRaw(
      name: 'Emma Davis',
      caScore: 28,
      examScore: 68,
      rowIndex: 4,
      gradeResolver: (s) => resolveGrade(s, defaultBoundaries),
    ),
  ];

  // 2. Filter students with invalid scores using where() (functional HOF)
  final invalidStudents = sampleStudents
      .where((student) => !student.validateScores())
      .toList();

  debugPrint('\n=== HOF Demo: Invalid Students (${invalidStudents.length}) ===');
  for (final s in invalidStudents) {
    debugPrint(
        '  ⚠ ${s.formatStudentName()} — CA:${s.caScore} Exam:${s.examScore}');
  }

  // 3. Use map() HOF to extract final scores
  final finalScores = sampleStudents.map((s) => s.finalScore).toList();
  debugPrint('\n=== HOF Demo: Final Scores via map() ===');
  debugPrint('  Scores: $finalScores');

  // 4. Pass a lambda to the custom processStudents() higher-order function
  debugPrint('\n=== HOF Demo: processStudents() with lambda ===');
  processStudents(sampleStudents, (student) {
    debugPrint(
        '  ${student.formatStudentName()}: ${student.finalScore} → ${student.grade}');
  });

  // 5. Assign grades and display results
  final graded = assignGrades(sampleStudents, defaultBoundaries);
  debugPrint('\n=== HOF Demo: assignGrades() results ===');
  for (final s in graded) {
    debugPrint('  ${s.formatStudentName()}: Grade = ${s.grade}');
  }

  debugPrint('\n=== HOF Demo complete. Launching app… ===\n');

  // ---------------------------------------------------------------------------
  // Run the Flutter application
  // ---------------------------------------------------------------------------
  runApp(const StudentGradingApp());
}

// =============================================================================
// ROOT APP WIDGET
// =============================================================================

class StudentGradingApp extends StatelessWidget {
  const StudentGradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate singleton services
    final fileParser = FileParserService();
    final exporter = ExportService();
    final vaultService = VaultService();
    final settingsService = SettingsService();

    return MultiProvider(
      providers: [
        // Settings controller (loaded first so others can read boundaries)
        ChangeNotifierProvider(
          create: (_) => SettingsController(settings: settingsService),
        ),

        // Home controller
        ChangeNotifierProxyProvider<SettingsController, HomeController>(
          create: (ctx) => HomeController(
            parser: fileParser,
            exporter: exporter,
            vault: vaultService,
            boundaries: buildDefaultBoundaries(),
          ),
          update: (ctx, settings, previous) {
            // Keep boundaries in sync with settings
            previous?.updateBoundaries(settings.boundaries);
            return previous ??
                HomeController(
                  parser: fileParser,
                  exporter: exporter,
                  vault: vaultService,
                  boundaries: settings.boundaries,
                );
          },
        ),

        // Vault controller
        ChangeNotifierProvider(
          create: (_) =>
              VaultController(vault: vaultService, exporter: exporter),
        ),

        // Cross-view refresh notifier
        ChangeNotifierProvider(create: (_) => VaultRefreshNotifier()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Student Grading Calculator',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode:
                settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
