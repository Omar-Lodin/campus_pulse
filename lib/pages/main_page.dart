import 'package:flutter/material.dart';
import '/pages/home_screen.dart';
import '/pages/history_page.dart';
import '/pages/settings_page.dart';

class MainPage extends StatefulWidget{
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;


  const MainPage ({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });
    
  @override
  State<MainPage> createState()=> _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPage = 0;
  

//creates and maintains navigation bar
@override
  Widget build(BuildContext context) {

    final pages = [
    const HomeScreen(),
    const HistoryPage(),
    SettingsPage(
      isDarkMode : widget.isDarkMode,
      onThemeChanged: widget.onThemeChanged,
    ),
  ];
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "History"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}