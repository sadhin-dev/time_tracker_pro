import 'package:equatable/equatable.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final Map<DateTime, List<AttendanceRecord>> attendanceByDate;
  final List<LateEmployee> lateEmployees;

  const AttendanceLoaded({
    required this.attendanceByDate,
    required this.lateEmployees,
  });

  @override
  List<Object?> get props => [attendanceByDate, lateEmployees];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AttendanceRecord {
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final TimeOfDay checkInTime;

  AttendanceRecord({
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkInTime,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceRecord &&
        other.employeeId == employeeId &&
        other.employeeName == employeeName &&
        other.date == date &&
        other.checkInTime == checkInTime;
  }

  @override
  int get hashCode {
    return employeeId.hashCode ^
        employeeName.hashCode ^
        date.hashCode ^
        checkInTime.hashCode;
  }
}

class LateEmployee {
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final TimeOfDay checkInTime;
  final TimeOfDay standardTime;

  LateEmployee({
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkInTime,
    required this.standardTime,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LateEmployee &&
        other.employeeId == employeeId &&
        other.employeeName == employeeName &&
        other.date == date &&
        other.checkInTime == checkInTime &&
        other.standardTime == standardTime;
  }

  @override
  int get hashCode {
    return employeeId.hashCode ^
        employeeName.hashCode ^
        date.hashCode ^
        checkInTime.hashCode ^
        standardTime.hashCode;
  }
}
