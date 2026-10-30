import 'package:flutter/material.dart';
import '/pages/home_screen.dart';
import '/pages/history_page.dart';
import '/pages/settings_page.dart';

class MainPage extends StatefulWidget{
  const MainPage ({super.key});

  @override
  State<MainPage> createState()=> _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPage = 0;
  final List<Widget> pages = [
    HomeScreen(),
    HistoryPage(),
    SettingsPage(),
  ];


@override
  Widget build(BuildContext context) {
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