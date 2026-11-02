## - - Campus Pulse - - ##
# - Team Members - #
- Omar Lodin
- Brandon Walker

## - - Team Responsibilities - - ##
- Development: Omar & Brandon
- Testing: Omar

## - - Project Overview - - # # 

- Campus Pulse is an offline Flutter app that helps students organize campus events, plan attendance, and review events they have attended. 
- It suggests events using attendance history and preferred interests. Records and settings are stored locally using SQLite and SharedPreferences.
--------------------------------------------------------------------------------------------------------------------------------------------------

## - - Implemented Features
- Create, view, edit, and delete events.
- Navigate between Home, event editor, event details, History, and Settings.
- Save event dates, start times, locations, categories, optional notes, and capacity.
- Filter the Home catalog by category.
- Mark events planned or cancel their planned status.
- Mark events attended and view them in History.
- Cancel attendance or permanently delete an event and its attendance records.
- Display planned and attended event counts.
- Suggest eligible events using local smart helper.
- Save preferred interests and light/dark theme settings.

## - - Dependencies - - ##
- Dart
- Flutter
- Material Design : used for theme selection
- SQLite : allows flutter app to perform CRUD on sqlite records
- path : required for constructing local database file path
- shared_preferences : saves the theme, group size, and preferred interest settings to persist   after closing app

## - - User guide - - ##
- Use the following commands to clone and run the project repository:
- 
- git clone https://github.com/Omar-Lodin/campus_pulse.git
- cd campus_pulse
- flutter pub get
- open your android emulator, Pixel 9a and Medium phone emulator used for tests
- flutter run
- Note: make sure all dependencies are resolved before running to avoid issues.

## - - Development tools - - ## 
- VS code
- Android Studio with Android 36.1 version emulator devices
- Github
- ClickUp
