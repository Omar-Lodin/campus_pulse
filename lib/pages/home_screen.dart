import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  CampusEvent? suggestedEvent;
  int suggestedCategoryCount = 0;
  bool suggestedMatches = false;

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
    final categoryCounts = await DatabaseHelper.getAttendedCategoryCounts();
    final prefs = await SharedPreferences.getInstance();
    final preferredInterests = [
      prefs.getString('selectedInterest1'),
      prefs.getString('selectedInterest2'),
      prefs.getString('selectedInterest3'),
    ].whereType<String>().where((value) => value.isNotEmpty).toSet();
    final loadedEvents = eventRows
        .map((row) => CampusEvent.fromMap(row))
        .toList();
    final suggestion = selectSuggestedEvent(
      loadedEvents,
      categoryCounts,
      preferredInterests,
    );
    if (!mounted) return;

    setState(() {
      events = loadedEvents;
      attendedCount = count;
      suggestedEvent = suggestion;
      suggestedCategoryCount = suggestion == null
          ? 0
          : categoryCounts[suggestion.category] ?? 0;

      suggestedMatches =
          suggestion != null &&
          preferredInterests.contains(suggestion.category);
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

  CampusEvent? selectSuggestedEvent(
    List<CampusEvent> availableEvents,
    Map<String, int> categoryCounts,
    Set<String> preferredInterests,
  ) {
    int score(CampusEvent event) {
      final attendScore = categoryCounts[event.category] ?? 0;
      final interestScore = preferredInterests.contains(event.category) ? 2 : 0;
      return attendScore + interestScore;
    }

    final candidates = availableEvents.where((event) {
      return !event.isPlanned && score(event) > 0;
    }).toList();
    candidates.sort((a, b) {
      final comparison = score(b).compareTo(score(a));

      if (comparison != 0) return comparison;
      return a.date.compareTo(b.date);
    });
    return candidates.isEmpty ? null : candidates.first;
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
                'Events Planned: ${events.where((event) => event.isPlanned).length}',
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
        const SizedBox(height: 6),
        buildSuggestedEventCard(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 3),
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
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget buildSuggestedEventCard() {
    final event = suggestedEvent;

    if (event == null) {
      return const Padding(
        padding: EdgeInsets.all(6),
        child: Text('No events to suggest.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          child: ListTile(
            leading: const Icon(Icons.auto_awesome_motion_outlined),
            title: Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(event.name)),
                const Chip(label: Text('Suggested')),
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (suggestedCategoryCount > 0)
                Text(
                  'You\'ve already attended $suggestedCategoryCount event(s) in ${event.category}.',
                ),
              if (suggestedMatches)
                const Text('This event matches a preferred interest.'),
            ],
          ),
        ),
      ],
    );
  }
}
