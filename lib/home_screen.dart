
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'event.dart';
import 'event_form_screen.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedPage = 0;
  String selectedCategory = 'All';
  double groupSize = 5;

  List<CampusEvent> events = [];
  List<Map<String, Object?>> attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Load saved events and attendance
  Future<void> loadData() async {
    List<Map<String, Object?>> eventRows =
        await DatabaseHelper.getEvents();

    List<Map<String, Object?>> historyRows =
        await DatabaseHelper.getAttendance();

    if (!mounted) return;

    setState(() {
      events = eventRows.map(
        (row) => CampusEvent.fromMap(row),
      ).toList();

      attendanceHistory = historyRows;
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
      await DatabaseHelper.updateEvent(
        event.id!,
        updatedEvent.toMap(),
      );

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
  void markAttendance(CampusEvent event) async {
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
      if (selectedCategory == 'All' ||
          events[i].category == selectedCategory) {
        filteredEvents.add(events[i]);
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = 'All';
                  });
                },
                child: const Text('All'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = 'Academic';
                  });
                },
                child: const Text('Academic'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = 'Social';
                  });
                },
                child: const Text('Social'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = 'Sports';
                  });
                },
                child: const Text('Sports'),
              ),
            ],
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
                  title: Text(event.name),
                  subtitle: Text(
                    '${event.category} - ${event.location}',
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

  // Attendance history page
  Widget buildHistoryPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Attendance History',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: attendanceHistory.length,
            itemBuilder: (context, index) {
              Map<String, Object?> record =
                  attendanceHistory[index];

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

  // Settings page
  Widget buildSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Text(
            'Default Group Size: ${groupSize.round()}',
          ),
          Slider(
            value: groupSize,
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (value) {
              setState(() {
                groupSize = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    if (selectedPage == 0) {
      currentPage = buildEventsPage();
    } else if (selectedPage == 1) {
      currentPage = buildCreatePage();
    } else if (selectedPage == 2) {
      currentPage = buildHistoryPage();
    } else {
      currentPage = buildSettingsPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Pulse'),
      ),
      body: currentPage,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedPage = 0;
                  });
                },
                child: const Text('Events'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedPage = 1;
                  });
                },
                child: const Text('Create'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedPage = 2;
                  });
                },
                child: const Text('History'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedPage = 3;
                  });
                },
                child: const Text('Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
