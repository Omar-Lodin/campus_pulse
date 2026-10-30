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

  Future<void> confirmDeleteAttendance(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Attendance'),
          content: const Text('Remove selected record from History?'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await DatabaseHelper.deleteAttendance(id);

    if (!mounted) return;
    await loadHistory();
  }

  Future<void> permanentlyDeleteEvent(int eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Permanently Delete Event'),
          content: const Text(
            'This will delete the event and attendance record.'
            'Deleted records are removed permanently.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await DatabaseHelper.deleteEvent(eventId);
    if (!mounted) return;
    await loadHistory();
  }

  @override
  // Attendance history page
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: ListView.builder(
        itemCount: attendanceHistory.length,
        itemBuilder: (context, index) {
          Map<String, Object?> record = attendanceHistory[index];

          return ListTile(
            leading: const Icon(Icons.check_circle),
            title: Text(record['event_name'] as String),
            subtitle: const Text('Attended'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Cancel attendance',
                  onPressed: () {
                    confirmDeleteAttendance(record['id'] as int);
                  },
                ),
                const SizedBox(width: 16),

                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  tooltip: 'Permanently delete event',
                  onPressed: () {
                    permanentlyDeleteEvent(record['event_id'] as int);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
