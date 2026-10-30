import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double groupSize = 5;

  @override
  void initState() {
    super.initState();
    loadGroupSize();
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
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Group Size', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 12),
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

            const SizedBox(height: 20),

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
                  // Add interest controls here later.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
