import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmate/completed_task.dart';
import 'package:taskmate/splash.dart';
import 'package:taskmate/theme_provider.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid?
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBWBa3lJIOWpLhUh4MN_cxplvlhcgHepDA",
        appId: "1:259124250494:android:44fe06a88efa80cfcc152f",
        messagingSenderId: "259124250494",
        projectId: "taskmate-ec08c")
  )
  :await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: MyApp(),
  ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {



  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'TaskMate',
          routes: {
            '/completedTasks': (context) => complete_task(),
          },
          debugShowCheckedModeBanner: false,
          theme: themeProvider.isDarkMode? ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            // colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            useMaterial3: true,
          ) : ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            useMaterial3: true,
          ),
          home: splashscreen(),
        );
      },
    );
  }
}

