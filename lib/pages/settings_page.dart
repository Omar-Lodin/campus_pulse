import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  double groupSize = 5;

  @override
  Widget build(BuildContext context) {
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


}
