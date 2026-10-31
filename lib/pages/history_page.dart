import 'package:festival_pocket/models/event.dart';
import 'package:festival_pocket/pages/event_detail_screen.dart';
import 'package:festival_pocket/pages/event_form_screen.dart';
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

  Future<void> viewEventDetails(int eventId) async {
    final eventMap = await DatabaseHelper.getEventById(eventId);

    if (!mounted || eventMap == null) return;

    final event = CampusEvent.fromMap(eventMap);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (detailsContext) {
          return EventDetailScreen(
            event: event,
            onAttend: () {
              ScaffoldMessenger.of(detailsContext).showSnackBar(
                const SnackBar(
                  content: Text('This event is already marked as attended'),
                ),
              );
            },
            onEdit: () async {
              final updatedEvent = await Navigator.push<CampusEvent>(
                detailsContext,
                MaterialPageRoute(
                  builder: (context) => EventFormScreen(event: event),
                ),
              );
              if (updatedEvent == null) return;

              await DatabaseHelper.updateEvent(eventId, updatedEvent.toMap());
              if (!detailsContext.mounted) return;
              Navigator.pop(detailsContext);
            },
            onDelete: () async {
              await DatabaseHelper.deleteEvent(eventId);
              if (!detailsContext.mounted) return;
              Navigator.pop(detailsContext);
            },
          );
        },
      ),
    );
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
          final record = attendanceHistory[index];
          final eventDate = DateTime.parse(record['event_date'] as String);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.check_circle),
              title: Text(record['event_name'] as String),
              subtitle: Text(
                'Attended\n'
                '${eventDate.month}/${eventDate.day}/${eventDate.year} '
                'at ${TimeOfDay.fromDateTime(eventDate).format(context)}',
              ),
              onTap: () {
                viewEventDetails(record['event_id'] as int);
              },
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
            ),
          );
        },
      ),
    );
  }
}
