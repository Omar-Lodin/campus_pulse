import 'package:festival_pocket/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CampusPulseApp());
}

class CampusPulseApp extends StatefulWidget {
  const CampusPulseApp({super.key});

  @override
  State<CampusPulseApp> createState() => _CampusPulseAppState();
}
class _CampusPulseAppState extends State<CampusPulseApp>{
  bool isDarkMode = false;

  @override void initState() {
    super.initState();
    loadTheme();
  }
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if(!mounted ) return;
    setState((){
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> changeTheme(bool value) async {
    setState(() {
      isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Pulse',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light,)
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor:Colors.deepOrange, brightness: Brightness.dark,)
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainPage(
        isDarkMode: isDarkMode,
        onThemeChanged: changeTheme,
      ),
    );
  }
}