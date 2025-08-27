import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/features/attendance/attendance_cubit.dart';
import 'package:my_app/features/attendance/attendance_state.dart';
import 'package:my_app/shared/app_colors.dart';
import 'package:my_app/shared/text_style.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttendanceCubit(),
      child: const AttendancePage(),
    );
  }
}

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Tracker',
            style: heading1Style(context).copyWith(color: Colors.white)),
        backgroundColor: kcPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AttendanceCubit>().loadSampleData(),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceInitial) {
              return _buildInitialView(context);
            } else if (state is AttendanceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AttendanceLoaded) {
              return _buildAttendanceView(context, state);
            } else if (state is AttendanceError) {
              return _buildErrorView(context, state);
            }
            return Container();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<AttendanceCubit>().pickAndImportExcel(),
        backgroundColor: kcPrimaryColor,
        child: const Icon(Icons.file_upload, color: Colors.white),
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 80,
            color: kcPrimaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Attendance Tracker',
            style: heading2Style(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Import an Excel file to get started with attendance tracking',
            style: bodyStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<AttendanceCubit>().pickAndImportExcel(),
            icon: const Icon(Icons.file_upload),
            label: Text('Import Excel File', style: buttonStyle(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kcPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<AttendanceCubit>().loadSampleData(),
            child: Text('Load Sample Data', style: bodyStyle(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceView(BuildContext context, AttendanceLoaded state) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: kcPrimaryGradient,
            ),
            child: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'Attendance'),
                Tab(text: 'Late Reports'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAttendanceList(context, state.attendanceByDate),
                _buildLateList(context, state.lateEmployees),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(BuildContext context,
      Map<DateTime, List<AttendanceRecord>> attendanceByDate) {
    if (attendanceByDate.isEmpty) {
      return Center(
        child: Text('No attendance records found', style: bodyStyle(context)),
      );
    }

    final sortedDates = attendanceByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final records = attendanceByDate[date]!;

        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: heading3Style(context),
                ),
                const SizedBox(height: 12),
                ...records.map((record) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: kcSecondaryTextColor.withOpacity(0.2)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.employeeName,
                            style: bodyStyle(context),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: record.checkInTime.hour < 9 ||
                                    (record.checkInTime.hour == 9 &&
                                        record.checkInTime.minute <= 0)
                                ? kcSuccessColor.withOpacity(0.1)
                                : kcErrorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${record.checkInTime.hour.toString().padLeft(2, '0')}:${record.checkInTime.minute.toString().padLeft(2, '0')}',
                            style: bodyStyle(context).copyWith(
                              color: record.checkInTime.hour < 9 ||
                                      (record.checkInTime.hour == 9 &&
                                          record.checkInTime.minute <= 0)
                                  ? kcSuccessColor
                                  : kcErrorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLateList(
      BuildContext context, List<LateEmployee> lateEmployees) {
    if (lateEmployees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 60,
              color: kcSuccessColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No late arrivals recorded',
              style: bodyStyle(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: lateEmployees.length,
      itemBuilder: (context, index) {
        final lateEmployee = lateEmployees[index];

        return Card(
          margin: const EdgeInsets.all(12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: kcSecondaryColor.withOpacity(0.1),
              child: Text(
                lateEmployee.employeeName[0],
                style: const TextStyle(color: kcSecondaryColor),
              ),
            ),
            title: Text(
              lateEmployee.employeeName,
              style: bodyStyle(context),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${lateEmployee.date.day}/${lateEmployee.date.month}/${lateEmployee.date.year}',
                  style: bodySmallStyle(context),
                ),
                Text(
                  '${lateEmployee.minutesLate} minutes late',
                  style: bodySmallStyle(context).copyWith(
                    color: kcSecondaryColor,
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kcSecondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${lateEmployee.checkInTime.hour.toString().padLeft(2, '0')}:${lateEmployee.checkInTime.minute.toString().padLeft(2, '0')}',
                style: bodyStyle(context).copyWith(
                  color: kcSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, AttendanceError state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 80,
            color: kcErrorColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Error Loading Data',
            style: heading2Style(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: bodyStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<AttendanceCubit>().pickAndImportExcel(),
            icon: const Icon(Icons.refresh),
            label: Text('Try Again', style: buttonStyle(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kcPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
