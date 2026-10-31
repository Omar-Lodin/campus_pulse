
import 'package:flutter/material.dart';
import '/models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final CampusEvent event;
  final VoidCallback onAttend;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.onAttend,
    required this.onEdit,
    required this.onDelete,
  });

  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text(
            'Are you sure you want to delete this event?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text('Description: ${event.description}'),
            const SizedBox(height: 8),
            Text('Location: ${event.location}'),
            const SizedBox(height: 8),
            Text('Category: ${event.category}'),
            const SizedBox(height: 8),
            
            Text(
              'Date: ${event.date.month}/'
              '${event.date.day}/${event.date.year}',
            ),
            const SizedBox(height: 8),
            if(event.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Personal Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(event.notes),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAttend,
              child: const Text('Mark Attended'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onEdit,
              child: const Text('Edit Event'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                confirmDelete(context);
              },
              child: const Text('Delete Event'),
            ),
          ],
        ),
      ),
    );
  }
}
