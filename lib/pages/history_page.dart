import 'package:flutter/material.dart';

import '/database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, Object?>> attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final historyRows = await DatabaseHelper.getAttendance();

    if (!mounted) return;

    setState(() {
      attendanceHistory = historyRows;
    });
  }

  @override
  // Attendance history page
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Attendance History', style: TextStyle(fontSize: 22)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: attendanceHistory.length,
            itemBuilder: (context, index) {
              Map<String, Object?> record = attendanceHistory[index];

              return ListTile(
                leading: const Icon(Icons.check_circle),
                title: Text(record['event_name'] as String),
                subtitle: const Text('Attended'),
              );
            },
          ),
        ),
      ],
    );
  }
}
