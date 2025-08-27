import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:my_app/features/attendance/attendance_state.dart';
import 'package:flutter/material.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit() : super(AttendanceInitial());

  final TimeOfDay standardWorkTime = const TimeOfDay(hour: 9, minute: 0);

  Future<void> pickAndImportExcel() async {
    emit(AttendanceLoading());

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        final file = result.files.first;
        if (file.bytes != null) {
          final excel = Excel.decodeBytes(file.bytes!);
          final attendanceData = _parseExcelData(excel);
          final lateEmployees = _identifyLateArrivals(attendanceData);
          emit(AttendanceLoaded(
            attendanceByDate: attendanceData,
            lateEmployees: lateEmployees,
          ));
        } else {
          emit(const AttendanceError(message: 'Failed to read file data'));
        }
      } else {
        // User canceled the picker
        emit(AttendanceInitial());
      }
    } catch (e) {
      emit(AttendanceError(
          message: 'Error importing Excel file: ${e.toString()}'));
    }
  }

  Map<DateTime, List<AttendanceRecord>> _parseExcelData(Excel excel) {
    final attendanceByDate = <DateTime, List<AttendanceRecord>>{};

    // Assuming data is in the first sheet
    final sheet = excel.tables[excel.tables.keys.first]!;

    // Skip header row (assuming first row is header)
    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      // Ensure we have enough columns
      if (row.length < 4) continue;

      try {
        // Parse employee ID (column 0)
        final employeeId = row[0]?.value?.toString() ?? '';

        // Parse employee name (column 1)
        final employeeName = row[1]?.value?.toString() ?? '';

        // Parse date (column 2) - assuming format: DD/MM/YYYY or similar
        final dateStr = row[2]?.value?.toString() ?? '';
        final date = _parseDate(dateStr);

        // Parse check-in time (column 3) - assuming format: HH:MM
        final timeStr = row[3]?.value?.toString() ?? '';
        final checkInTime = _parseTime(timeStr);

        if (date != null && checkInTime != null) {
          final record = AttendanceRecord(
            employeeId: employeeId,
            employeeName: employeeName,
            date: date,
            checkInTime: checkInTime,
          );

          if (attendanceByDate.containsKey(date)) {
            attendanceByDate[date]!.add(record);
          } else {
            attendanceByDate[date] = [record];
          }
        }
      } catch (e) {
        // Skip rows with parsing errors
        continue;
      }
    }

    return attendanceByDate;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // Handle different date formats
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } else if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          // Assuming DD-MM-YYYY format
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      // Return null for unparseable dates
    }
    return null;
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      // Handle time format HH:MM
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      // Return null for unparseable times
    }
    return null;
  }

  List<LateEmployee> _identifyLateArrivals(
      Map<DateTime, List<AttendanceRecord>> attendanceByDate) {
    final lateEmployees = <LateEmployee>[];

    for (final date in attendanceByDate.keys) {
      for (final record in attendanceByDate[date]!) {
        // Check if employee arrived after standard work time
        if (record.checkInTime.hour > standardWorkTime.hour ||
            (record.checkInTime.hour == standardWorkTime.hour &&
                record.checkInTime.minute > standardWorkTime.minute)) {
          lateEmployees.add(LateEmployee(
            employeeId: record.employeeId,
            employeeName: record.employeeName,
            date: record.date,
            checkInTime: record.checkInTime,
            standardTime: standardWorkTime,
          ));
        }
      }
    }

    return lateEmployees;
  }

  void loadSampleData() {
    emit(AttendanceLoading());

    try {
      final sampleData = <DateTime, List<AttendanceRecord>>{
        DateTime(2023, 6, 15): [
          AttendanceRecord(
            employeeId: 'EMP001',
            employeeName: 'John Smith',
            date: DateTime(2023, 6, 15),
            checkInTime: const TimeOfDay(hour: 8, minute: 45),
          ),
          AttendanceRecord(
            employeeId: 'EMP002',
            employeeName: 'Sarah Johnson',
            date: DateTime(2023, 6, 15),
            checkInTime: const TimeOfDay(hour: 9, minute: 15),
          ),
          AttendanceRecord(
            employeeId: 'EMP003',
            employeeName: 'Michael Brown',
            date: DateTime(2023, 6, 15),
            checkInTime: const TimeOfDay(hour: 8, minute: 55),
          ),
        ],
        DateTime(2023, 6, 16): [
          AttendanceRecord(
            employeeId: 'EMP001',
            employeeName: 'John Smith',
            date: DateTime(2023, 6, 16),
            checkInTime: const TimeOfDay(hour: 9, minute: 5),
          ),
          AttendanceRecord(
            employeeId: 'EMP002',
            employeeName: 'Sarah Johnson',
            date: DateTime(2023, 6, 16),
            checkInTime: const TimeOfDay(hour: 8, minute: 50),
          ),
          AttendanceRecord(
            employeeId: 'EMP004',
            employeeName: 'Emily Davis',
            date: DateTime(2023, 6, 16),
            checkInTime: const TimeOfDay(hour: 9, minute: 20),
          ),
        ],
      };

      final lateEmployees = _identifyLateArrivals(sampleData);

      emit(AttendanceLoaded(
        attendanceByDate: sampleData,
        lateEmployees: lateEmployees,
      ));
    } catch (e) {
      emit(AttendanceError(
          message: 'Error loading sample data: ${e.toString()}'));
    }
  }
}
