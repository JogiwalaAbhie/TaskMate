import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:taskmate/changepassword.dart';
import 'package:taskmate/theme_provider.dart';

class setting extends StatefulWidget {


  const setting({super.key});

  @override
  State<setting> createState() => _settingState();
}

class _settingState extends State<setting> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool _notificationsEnabled = true;
  bool darkmode =true;

  @override
  void initState() {
    super.initState();
    //loadNotificationPreference();
    //initializeNotifications();
    //monitorTaskStartTimes();
  }

  // void loadNotificationPreference() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     // Ensure the value is retrieved properly, with default as false
  //     _notificationsEnabled = prefs.getBool('notification') ?? false;
  //   });
  // }
  //
  // // Save the notification preference whenever it's toggled
  // void saveNotificationPreference(bool value) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('notification', value);
  // }
  //
  // // Toggle switch and save state to prevent it from resetting
  // void toggleNotificationSwitch(bool value) {
  //   setState(() {
  //     _notificationsEnabled = value;
  //   });
  //   // Save the new value in SharedPreferences
  //   saveNotificationPreference(value);
  // }

  // Future<void> initializeNotifications() async {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //   AndroidInitializationSettings('@mipmap/ic_launcher'); // Replace with your app icon
  //
  //   const InitializationSettings initializationSettings =
  //   InitializationSettings(
  //     android: initializationSettingsAndroid,
  //   );
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }
  //
  //
  // Future<void> scheduleNotification(DateTime scheduledTime, String title, String body) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //   AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     channelDescription: 'your_channel_description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //
  //   const NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //   );
  //
  //   await flutterLocalNotificationsPlugin.schedule(
  //     0,  // Notification ID
  //     title,
  //     body,
  //     scheduledTime,
  //     platformChannelSpecifics,
  //   );
  // }
  //
  // void monitorTaskStartTimes() {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection('tasks')
  //       .get()
  //       .then((QuerySnapshot querySnapshot){
  //     querySnapshot.docs.forEach((doc) {
  //       Timestamp startTimeTimestamp = doc['startTime']; // Fetch startTime as a Firestore Timestamp
  //       DateTime startTime = startTimeTimestamp.toDate(); // Convert Timestamp to DateTime
  //
  //       // Schedule a notification for the start time
  //       scheduleNotification(
  //         startTime,
  //         'Task Reminder',
  //         'Your task "${doc['title']}" is about to start!',
  //       );
  //     });
  //   });
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black
            )),
        elevation: 50, // Shadow under the AppBar
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          ListTile(
            title: Text('Notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                _notificationsEnabled = value;
              },
            ),
          ),
          ListTile(
            title: Text('Dark Mode'),
            trailing: Switch(
              value: Provider.of<ThemeProvider>(context).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ),
          ListTile(
            title: Text('Account'),
            onTap: () {
              // Navigate to account settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => changepass()),
              );
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              // Show about dialog or navigate to about page
              showAboutDialog(
                context: context,
                applicationName: 'Task Manager',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Task Manager Inc.',
              );
            },
          ),
        ],
      ),
    );
  }
}


