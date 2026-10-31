import 'package:festival_pocket/database_helper.dart';
import 'package:flutter/material.dart';

import '/models/event.dart';

class EventFormScreen extends StatefulWidget {
  final CampusEvent? event;

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() {
    return _EventFormScreenState();
  }
}

class _EventFormScreenState extends State<EventFormScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();
  final capacityController = TextEditingController();
  final monthController = TextEditingController();
  final dayController = TextEditingController();
  final yearController = TextEditingController();

  String category = 'Academic';

  TimeOfDay selectedTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  void initState() {
    super.initState();

    DateTime date = DateTime.now();

    if (widget.event != null) {
      nameController.text = widget.event!.name;
      descriptionController.text = widget.event!.description;
      locationController.text = widget.event!.location;
      category = widget.event!.category;
      date = widget.event!.date;
      notesController.text = widget.event!.notes;
      selectedTime = TimeOfDay.fromDateTime(widget.event!.date);
      capacityController.text = widget.event!.capacity?.toString() ?? '';
    }

    monthController.text = date.month.toString();
    dayController.text = date.day.toString();
    yearController.text = date.year.toString();
  }

  // Save event
  void saveEvent() {
    if (formKey.currentState!.validate()) {
      int month = int.parse(monthController.text.trim());
      int day = int.parse(dayController.text.trim());
      int year = int.parse(yearController.text.trim());

      DateTime eventDate = DateTime(
        year,
        month,
        day,
        selectedTime.hour,
        selectedTime.minute,
      );

      if (eventDate.month != month ||
          eventDate.day != day ||
          eventDate.year != year) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid date')),
        );
        return;
      }

      CampusEvent event = CampusEvent(
        id: widget.event?.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        category: category,
        date: eventDate,
        notes: notesController.text.trim(),
        capacity: int.tryParse(capacityController.text.trim()),
      );

      Navigator.pop(context, event);
    }
  }

  // Clear the form
  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    locationController.clear();
    notesController.clear();
    capacityController.clear();
    DateTime today = DateTime.now();

    monthController.text = today.month.toString();
    dayController.text = today.day.toString();
    yearController.text = today.year.toString();

    setState(() {
      category = 'Academic';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();

    monthController.dispose();
    dayController.dispose();
    yearController.dispose();
    notesController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  Future<void> selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (!mounted || pickedTime == null) return;

    setState(() {
      selectedTime = pickedTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Create Event' : 'Edit Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacity (optional)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if(text.isEmpty) return null;
                  final capacity = int.tryParse(text);

                  if (capacity == null || capacity < 1) {
                    return 'Only positive whole numbers allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text('Category'),
              DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: DatabaseHelper.eventCategories.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    category = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Event Date', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: monthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        int? month = int.tryParse((value ?? '').trim());

                        if (month == null || month < 1 || month > 12) {
                          return 'Invalid month';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: dayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Day',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        int? day = int.tryParse((value ?? '').trim());

                        if (day == null || day < 1 || day > 31) {
                          return 'Invalid day';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        int? year = int.tryParse((value ?? '').trim());

                        if (year == null || year < 2020 || year > 2100) {
                          return 'Invalid year';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: selectTime,
                child: Text(
                  'Event Start Time: ${selectedTime.format(context)}',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 200,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveEvent,
                child: const Text('Save Event'),
              ),
              TextButton(onPressed: resetForm, child: const Text('Reset')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
