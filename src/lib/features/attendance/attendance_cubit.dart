import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:my_app/features/attendance/attendance_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit() : super(AttendanceInitial());

  final TimeOfDay standardWorkTime = const TimeOfDay(hour: 9, minute: 0);
  final int lateThresholdMinutes =
      15; // Configurable late threshold (default 15 minutes)

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

        // Parse date (column 2) - supporting multiple formats
        final dateStr = row[2]?.value?.toString() ?? '';
        final date = _parseDate(dateStr);

        // Parse check-in time (column 3) - supporting multiple formats
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
      // Try DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD formats
      final formats = [
        'dd/MM/yyyy',
        'MM/dd/yyyy',
        'yyyy-MM-dd',
        'dd-MM-yyyy',
        'MM-dd-yyyy',
        'yyyy/MM/dd'
      ];

      for (final format in formats) {
        try {
          final date = DateFormat(format).parseStrict(dateStr);
          return date;
        } catch (e) {
          // Try next format
          continue;
        }
      }
    } catch (e) {
      // Return null for unparseable dates
    }
    return null;
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      // Handle time formats HH:MM, HH:MM:SS, H:MM, etc.
      final formats = ['HH:mm', 'H:mm', 'HH:mm:ss', 'H:mm:ss'];

      for (final format in formats) {
        try {
          final time = DateFormat(format).parseStrict(timeStr);
          return TimeOfDay(hour: time.hour, minute: time.minute);
        } catch (e) {
          // Try next format
          continue;
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
        // Calculate minutes late
        final standardDateTime = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
          standardWorkTime.hour,
          standardWorkTime.minute,
        );

        final checkInDateTime = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
          record.checkInTime.hour,
          record.checkInTime.minute,
        );

        final difference = checkInDateTime.difference(standardDateTime);
        final minutesLate = difference.inMinutes;

        // Check if employee arrived after standard work time + threshold
        if (minutesLate > lateThresholdMinutes) {
          lateEmployees.add(LateEmployee(
            employeeId: record.employeeId,
            employeeName: record.employeeName,
            date: record.date,
            checkInTime: record.checkInTime,
            standardTime: standardWorkTime,
            minutesLate: minutesLate,
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
