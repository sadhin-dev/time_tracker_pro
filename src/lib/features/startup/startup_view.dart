import 'package:flutter/material.dart';
import 'package:my_app/features/attendance/attendance_view.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    _navigateToAttendance();
  }

  void _navigateToAttendance() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AttendanceView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Attendance Tracker',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Initializing...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
