// lib/models/vault_item.dart
// Represents a saved grading session stored in the Vault.

import 'student_record.dart';

/// A saved grading session stored in the local Vault.
class VaultItem {
  /// Unique identifier
  final String id;

  /// Original file/sheet name
  final String fileName;

  /// Timestamp when this entry was created
  final DateTime createdAt;

  /// All student records for this session
  final List<StudentRecord> records;

  const VaultItem({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.records,
  });

  /// Total number of students in this session.
  int get studentCount => records.length;

  /// Number of students with valid scores.
  int get validCount => records.where((r) => r.validateScores()).length;

  /// Number of students with warnings.
  int get warningCount => records.where((r) => r.hasWarning).length;

  /// Class average final score.
  double get averageScore {
    if (records.isEmpty) return 0;
    final sum = records.fold(0.0, (acc, r) => acc + r.finalScore);
    return sum / records.length;
  }

  /// Serialise to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'records': records.map((r) => r.toMap()).toList(),
    };
  }

  /// Deserialise from a stored map.
  factory VaultItem.fromMap(Map<dynamic, dynamic> map) {
    final rawRecords = map['records'] as List<dynamic>? ?? [];
    return VaultItem(
      id: map['id'] as String,
      fileName: map['fileName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      records: rawRecords
          .map((r) => StudentRecord.fromMap(r as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() => 'VaultItem($fileName, ${records.length} students)';
}
