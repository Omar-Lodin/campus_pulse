import 'package:festival_pocket/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double groupSize = 5;
  String? selectedInterest1;
  String? selectedInterest2;
  String? selectedInterest3;
  @override
  void initState() {
    super.initState();
    loadGroupSize();
    loadInterests();
  }

  Future<void> loadGroupSize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSize = prefs.getInt('groupSize') ?? 5;

    if (!mounted) return;
    setState(() {
      groupSize = savedSize.toDouble();
    });
  }

  Future<void> saveGroupSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('groupSize', value.round());
  }

  Future<void> saveInterests() async {
    final prefs = await SharedPreferences.getInstance();

    if (selectedInterest1 != null) {
      await prefs.setString('selectedInterest1', selectedInterest1!);
    }
    if (selectedInterest2 != null) {
      await prefs.setString('selectedInterest2', selectedInterest2!);
    }
    if (selectedInterest3 != null) {
      await prefs.setString('selectedInterest3', selectedInterest3!);
    }
  }

  Future<void> loadInterests() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      selectedInterest1 = prefs.getString('selectedInterest1');
      selectedInterest2 = prefs.getString('selectedInterest2');
      selectedInterest3 = prefs.getString('selectedInterest3');
    });
  }

  Future<void> resetInterests() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('selectedInterest1');
    await prefs.remove('selectedInterest2');
    await prefs.remove('selectedInterest3');

    if (!mounted) return;

    setState(() {
      selectedInterest1 = null;
      selectedInterest2 = null;
      selectedInterest3 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Make changes to your preferences',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),

                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: const Icon(Icons.dark_mode),
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Group Size', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Text('Default Group Size: ${groupSize.round()}'),
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
                    onChangeEnd: (value) async {
                      await saveGroupSize(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferred Interests',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: selectedInterest1,
                    hint: const Text('Select Interest'),
                    items: DatabaseHelper.eventCategories.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        selectedInterest1 = value;
                      });
                      await saveInterests();
                    },
                  ),

                  const SizedBox(height: 12),

                  DropdownButton<String>(
                    value: selectedInterest2,
                    hint: const Text('Select Interest'),
                    items: DatabaseHelper.eventCategories.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        selectedInterest2 = value;
                      });
                      await saveInterests();
                    },
                  ),

                  const SizedBox(height: 12),

                  DropdownButton<String>(
                    value: selectedInterest3,
                    hint: const Text('Select Interest'),
                    items: DatabaseHelper.eventCategories.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        selectedInterest3 = value;
                      });
                      await saveInterests();
                    },
                  ),
                  ElevatedButton(
                    onPressed: resetInterests,
                    child: const Text('Reset Interests'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
