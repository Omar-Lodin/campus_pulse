import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '/database_helper.dart';
import '/models/event.dart';
import '/pages/event_form_screen.dart';
import '/pages/event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';

  int attendedCount = 0;
  List<CampusEvent> events = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Pulse')),
      body: buildEventsPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Load saved events and attendance
  Future<void> loadData() async {
    final eventRows = await DatabaseHelper.getEvents();
    final count = await DatabaseHelper.getAttendanceCount();
    if (!mounted) return;

    setState(() {
      events = eventRows.map((row) => CampusEvent.fromMap(row)).toList();
      attendedCount = count;
    });
  }

  // Add a new event
  void addEvent() async {
    CampusEvent? newEvent = await Navigator.push<CampusEvent>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const EventFormScreen();
        },
      ),
    );

    if (newEvent != null) {
      await DatabaseHelper.addEvent(newEvent.toMap());
      await loadData();
    }
  }

  // Edit an event
  void editEvent(CampusEvent event) async {
    CampusEvent? updatedEvent = await Navigator.push<CampusEvent>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EventFormScreen(event: event);
        },
      ),
    );

    if (updatedEvent != null && event.id != null) {
      await DatabaseHelper.updateEvent(event.id!, updatedEvent.toMap());

      await loadData();
    }
  }

  // Delete an event
  void deleteEvent(CampusEvent event) async {
    if (event.id == null) return;

    await DatabaseHelper.deleteEvent(event.id!);
    await loadData();
  }

  // Record attendance
  Future<void> markAttendance(CampusEvent event) async {
    if (event.id == null) return;

    await DatabaseHelper.addAttendance(event.id!);
    await loadData();
  }

  // Open event details
  void openEventDetails(CampusEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EventDetailScreen(
            event: event,
            onTogglePlanned: () async {
              if (event.id == null) return;
              await DatabaseHelper.setEventPlanned(event.id!, !event.isPlanned);
              if (!mounted || !context.mounted) return;
              Navigator.pop(context);
              await loadData();
            },
            onAttend: () {
              markAttendance(event);
            },
            onEdit: () {
              Navigator.pop(context);
              editEvent(event);
            },
            onDelete: () {
              deleteEvent(event);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  // Events page
  Widget buildEventsPage() {
    List<CampusEvent> filteredEvents = [];

    for (int i = 0; i < events.length; i++) {
      if (selectedCategory == 'All' || events[i].category == selectedCategory) {
        filteredEvents.add(events[i]);
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Events Planned: ${events.where((event)=>event.isPlanned).length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Events Attended: $attendedCount',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', ...DatabaseHelper.eventCategories].map((
                category,
              ) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              CampusEvent event = filteredEvents[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(event.name)),
                      if (event.isPlanned) const Chip(label: Text('Planned')),
                    ],
                  ),
                  subtitle: Text(
                    '${event.category} - ${event.location}\n'
                    '${event.date.month}/${event.date.day}/${event.date.year}'
                    ' at ${TimeOfDay.fromDateTime(event.date).format(context)}',
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    openEventDetails(event);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Create page
  Widget buildCreatePage() {
    return Center(
      child: ElevatedButton(
        onPressed: addEvent,
        child: const Text('Create New Event'),
      ),
    );
  }
}
