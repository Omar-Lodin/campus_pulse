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
          children: [
            const Text(
              'Make changes to your preferences',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
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
    );
  }
}
