import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:taskmate/completed_task.dart';
import 'package:taskmate/firestore.dart';
import 'package:taskmate/pending_task.dart';
import 'package:taskmate/register.dart';
import 'package:taskmate/settingpage.dart';
import 'package:taskmate/user_profile.dart';
import 'dart:async';


class home extends StatefulWidget {

  const home({super.key});

  @override
  State<home> createState() => _homeState();


}

class _homeState extends State<home> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool show = true;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String searchQuery = '';
  Stream<QuerySnapshot>? searchResults;

  String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    deleteTasksOlderThan24Hours();
    getUsername();
    initializeNotifications();
    monitorTaskStartTimes();
  }

  // NOTIFICATION CODE START

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Replace with your app icon

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  Future<void> scheduleNotification(String title) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      icon: 'mainicon',
      importance: Importance.max,
      priority: Priority.high,
        showWhen: false
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
        0,
        'Task Reminder',  // Notification Title
        'Your task "$title" is about to start.',
        platformChannelSpecifics,
        );
  }

  Future<void> monitorTaskStartTimes() async {
    // Create a Timer that checks every minute
    Timer.periodic(Duration(minutes: 1), (timer) async {
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('tasks')
          .get();
      for (var doc in tasksSnapshot.docs) {
        final taskTime = (doc['startTime'] as Timestamp).toDate();
        final notified = doc['notified'] ?? false;

        // Check if the current time is equal to or after the task time
        if (taskTime.isBefore(DateTime.now()) && !notified ) {
          // Show notification
          await scheduleNotification(doc['title']);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('tasks')
              .doc(doc.id)
              .update({'notified': true});
        }
      }
    });
  }

  // NOTIFICATION CODE END


  Future<void> deleteTasksOlderThan24Hours() async {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(hours: 12));
    Timestamp cutoffTimestamp = Timestamp.fromDate(cutoff);

    // Query tasks older than 24 hours since their start time
    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .where('startTime',isLessThanOrEqualTo: cutoffTimestamp)
        .where('isDone',isEqualTo: true)
        .get();

    // Loop through and delete each task
    for (var taskDoc in tasksSnapshot.docs) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('tasks')
          .doc(taskDoc.id)
          .delete();
      print('Deleted task: ${taskDoc.id}');
    }
  }


  void SearchQuery(String query) {
    setState(() {
      searchQuery = query;
      if (searchQuery.isNotEmpty) {
        searchResults = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('tasks')
            .where('title', isGreaterThanOrEqualTo: searchQuery)
            .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff')
            .snapshots();
      } else {
        searchResults = null;
      }
    });
  }

  Future<String?> getUsername() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (userDoc.exists) {
      return userDoc['username'];
    } else {
      return null; // Or handle this case as needed
    }
  }



  Future<void> deleteTask(String documentID) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('tasks')
          .doc(documentID);

      // Delete the document
      await docRef.delete();
      Fluttertoast.showToast(
        msg: "Task Deleted Successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color(0xFF0C1A38),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  void _showConfirmationDialog(BuildContext context,String documentId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Completion'),
          content: Text('Are you sure you want to mark this task as complete?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _markTaskAsCompleted(context,documentId);
      Navigator.pushReplacementNamed(context, 'completedTasks');
    }
  }



  Future<void> _markTaskAsCompleted(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('tasks')
          .doc(documentId)
          .update({
        'isDone': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task marked as completed.')),
      );
    } catch (e) {
      print("Error marking task as completed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark task as completed.')),
      );
    }
  }

  Future<void> pendingtask(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('tasks')
          .where('isDone', isEqualTo: false)
          .snapshots();
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Task Mate",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.menu),
          color: Colors.black,
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        elevation: 50, // Shadow under the AppBar
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        elevation: 16,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: [
                  GestureDetector(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                          'assets/image/man.png'),
                    ),
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => user_profile()));
                      }
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<String?>(
                      future: getUsername(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Text('No username found');
                        }
                        return Text(
                          'Hello, ${snapshot.data}!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => home()));
                }),
            ListTile(
              leading: Icon(Icons.pending_actions),
              title: Text('Pending Tasks'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => pending_task()));
              },
            ),
            ListTile(
              leading: Icon(Icons.task),
              title: Text('Completed Tasks'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => complete_task()));
              },
            ),
            ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text('Calendar'),
                onTap: () {
                  showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2005),
                      lastDate: DateTime(2025));
                }),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => setting()));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => register()));
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              onChanged: SearchQuery,
              obscureText: false,
              autocorrect: true,
              enableSuggestions: true,
              onFieldSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
              style: TextStyle(fontSize: 14,),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                  ),
                  hintText: "Search : ",
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.2), width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.black, width: 0),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15,8,15,8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("All Task",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),),
                    Text("$formattedDate",
                    style: TextStyle(
                      color: Colors.grey
                    ),)
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade800,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    )
                  ),
                  onPressed: () {
                    return addtask();
                  },
                    child: const Text("+ New Task",
                    style: TextStyle(fontWeight: FontWeight.bold),)
                )
              ],
            ),
          ),
          Flexible(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('tasks')
                          .where('title', isGreaterThanOrEqualTo: searchQuery)
                          .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No Task Found'));
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                        final tasks = snapshot.data!.docs;

                        return ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              var task = tasks[index];

                              var documentId = task['id'];
                              bool isDone = task['isDone'] ?? false;
                              Timestamp taskTimestamp = task['startTime'];
                              DateTime taskTime = taskTimestamp.toDate();

                              String formattedTime =
                                  DateFormat('HH:mm').format(taskTime);

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: GestureDetector(
                                  onLongPress: (){
                                    deleteConfirmationDialog(context,documentId);
                                  },
                                  child: Container(
                                    height: 130,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: CupertinoColors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,2))
                                        ],
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      child: Row(
                                        children: [
                                            Container(
                                              height: 120,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/image/taskimage.jpeg'),
                                                    fit: BoxFit.fitWidth,
                                                  )),
                                            ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      task['title'] ?? 'no title',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Checkbox(
                                                        value: isDone,
                                                        onChanged: isDone
                                                          ? null
                                                          : (bool? newValue) {
                                                          if (newValue != null) {
                                                            _showConfirmationDialog(context, documentId);
                                                          }
                                                        })
                                                  ],
                                                ),
                                                Text(task['subtitle'] ?? 'no subtitle',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black12
                                                            .withOpacity(0.5))),
                                                SizedBox(height: 6),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 10, 0, 8),
                                                  child: Container(
                                                    height: 32,
                                                    width: 220,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          width: 95,
                                                          height: 32,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.blueAccent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(5),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 6),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .access_time_sharp,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 15,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "$formattedTime",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        GestureDetector(
                                                          child: Container(
                                                            width: 60,
                                                            height: 32,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .lightBlueAccent
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          6),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Icon(
                                                                    Icons.edit,
                                                                    color: Colors
                                                                        .blue,
                                                                    size: 15,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    "Edit",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w800,
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .blue),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            edittask(context,documentId);
                                                          },
                                                        ),
                                                        SizedBox(width:5,),
                                                        GestureDetector(
                                                            child: Icon(
                                                                Icons.delete,
                                                                color: Color(0xFF0C1A38)
                                                            ),
                                                          onTap: (){
                                                            deleteConfirmationDialog(context,documentId);

                                                          }
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      }),
                ),
            ),
          )
        ],
      ),
    );
  }

  void addtask() {
    TextEditingController title = TextEditingController();
    TextEditingController subtitle = TextEditingController();

    final formkey = GlobalKey<FormState>();

    TimeOfDay? selectedTime;

    Future<TimeOfDay?> selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        selectedTime = picked;
        (context as Element).markNeedsBuild();
        return selectedTime;
      }

    }


    bool _validatetime(TimeOfDay? time) {
      if (time == null) {
        return false;
      }
      final now = TimeOfDay.now();
      return time.hour >= now.hour &&
          (time.hour != now.hour || time.minute >= now.minute);
    }


    void submitform() async {

      if (formkey.currentState!.validate()) {
        TimeOfDay? _selectedTime = selectedTime;
        formkey.currentState!.save();
        if (_selectedTime != null) {
            await Firestore_Datasource()
                .addTask(subtitle.text, title.text, _selectedTime);

            Navigator.of(context).pop();
            Fluttertoast.showToast(
              msg: "Task Inserted Successfully!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Color(0xFF0C1A38),
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
      }
    }

    showModalBottomSheet(
      isScrollControlled: true,
        barrierColor: Colors.black.withOpacity(0.5),
        elevation: 5.0,
        scrollControlDisabledMaxHeightRatio: 200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
        ),
        context: context,
        builder: (context) => SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Container(
              padding: EdgeInsets.all(30),
              height: MediaQuery.of(context).size.height*0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 0,
                  ),
                  SizedBox(
                    width: double.infinity,
                      height: 50,
                      child: Text("Add Task",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24,color: Colors.black,fontWeight: FontWeight.bold),)
                  ),
                  Divider(thickness: 1,),
                  SizedBox(height: 25,),
                  TextFormField(
                    controller: title,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Title of task';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.task,
                      ),
                      labelText: "Title",
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        BorderSide(color: Colors.black, width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.red, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.red, width: 2.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  TextFormField(
                    maxLines: 3,
                    controller: subtitle,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Sub-title of task';
                      } else if (value.length > 30) {
                        return "Input cant be more than 30 characters";
                      }
                      return null;
                    },
                    // maxLines: 2,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.subtitles,
                      ),
                      labelText: "Subtitle",
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        BorderSide(color: Colors.black, width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.red, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.red, width: 2.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
            
                  // DATE AND TIME SECTION
            
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                        children: [
                          Ink(
                            child: InkWell(
                              onTap: (){
                                selectTime(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.black,
                                        width: 1
                                    )
                                ),
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.clock),
                                    SizedBox(width: 12,),
                                    Text(
                                      selectedTime == null
                                          ? "HH : MM"
                                          : '${selectedTime!.format(context)}',)
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 25,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (selectedTime != null)
                                Text(
                                  _validatetime(selectedTime)
                                      ? "Valid Time"
                                      : "Invalid Time",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: _validatetime(selectedTime)
                                          ? Colors.black
                                          : Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            
                  // BUTTON SECTION
            
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              elevation: 0,
                              side: BorderSide(
                                color: Colors.blue
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14)
                            ),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel",
                            style: TextStyle(fontWeight: FontWeight.bold),),
                          )
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                                shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(8)
                              ),
                                padding: const EdgeInsets.symmetric(vertical: 14)
                            ),
                            onPressed: (){
                              submitform();
                            },
                            child: Text("Save",
                              style: TextStyle(fontWeight: FontWeight.bold),),
                          )
                      ),
                    ],
                  ),
            
                  //IMAGE SECTION

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Image.asset(
                                "assets/image/add task img.png",
                                fit: BoxFit.fitWidth,
                                height: 180,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),

            ),
          ),
        )
    );



  }

  void edittask(BuildContext context, String documentId) async  {

    final formkey = GlobalKey<FormState>();

    //FETCH TASK LOGIC

    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .doc(documentId)
        .get();
    var taskData = docSnapshot.data() as Map<String, dynamic>;

    //FETCH DATA STORE IN VARIABLE

    TextEditingController title = TextEditingController(text: taskData['title']);
    TextEditingController subtitle = TextEditingController(text: taskData['subtitle']);
    DateTime startTimeOfDay = (taskData['startTime'] as Timestamp).toDate();
    TimeOfDay startTime = TimeOfDay.fromDateTime(startTimeOfDay);

    //FOR SELECT TIME

    Future<void> _selectTime(BuildContext context) async {
      TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: startTime,
      );
      if (picked != null) {
        startTime = picked;
        // Update the displayed time
        (context as Element).markNeedsBuild();
      }
    }

    //VALIDATION OF TIME FUCTION

    bool _validatetime(TimeOfDay? time) {
      if (time == null) {
        return false;
      }
      final now = TimeOfDay.now();
      return time.hour >= now.hour &&
          (time.hour != now.hour || time.minute >= now.minute);
    }

    // UPDATE TASK LOGIC

    void edittask() async{
      DateTime now = DateTime.now();
      DateTime updatedDateTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);

      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('tasks')
          .doc(documentId)
          .update({
        'title': title.text,
        'subtitle': subtitle.text,
        'startTime': Timestamp.fromDate(updatedDateTime),
      }).then((_) {
         // Close the dialog
        Fluttertoast.showToast(
          msg: "Task Updated Successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color(0xFF0C1A38),
          textColor: Colors.white,
          fontSize: 16.0,
        );

      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: $error')),
        );
      });
      // Navigator.of(context).pop();
    }

    // EDIT PAGE UI

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              backgroundColor: Colors.white,
              elevation: 50,
              title: Text(
                "Edit Task",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height*0.4,
                  width: 300,
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          // initialValue: _title,
                          controller: title,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Title of task';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.add_task,
                            ),
                            labelText: "Title",
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 18, horizontal: 20),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          // initialValue: _subtitle,
                          controller: subtitle,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Sub-title of task';
                            }
                            return null;
                          },
                          maxLines: 2,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.subtitles,
                            ),
                            labelText: "Subtitle",
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 18, horizontal: 20),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        // TIME SELECT

                        Expanded(
                          child: Column(
                            children: [
                              Ink(
                                child: InkWell(
                                  onTap: (){
                                    _selectTime(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.black,
                                            width: 1
                                        )
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.clock),
                                        SizedBox(width: 12,),
                                        Text(
                                          startTime == null
                                              ? "HH : MM"
                                              : '${startTime!.format(context)}',)
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        if (startTime != null)
                          Text(
                            _validatetime(startTime)
                                ? ""
                                : "Invalid Time",
                            style: TextStyle(
                                fontSize: 14,
                                color: _validatetime(startTime)
                                    ? Colors.black
                                    : Colors.red,
                                fontWeight: FontWeight.bold),
                          )
                      ],
                    ),
                  ),
                ),
              ),

              // SAVE AND CANCEL BUTTON

              actions: [
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              elevation: 0,
                              side: BorderSide(
                                  color: Colors.blue
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14)
                          ),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel",
                            style: TextStyle(fontWeight: FontWeight.bold),),
                        )
                    ),
                    SizedBox(
                      width: 18,
                    ),
                    Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14)
                          ),
                          onPressed : (){
                            edittask(); 
                            Navigator.of(context).pop();
                          },
                          child: Text("Save",
                            style: TextStyle(fontWeight: FontWeight.bold),),
                        )
                    ),
                  ],
                ),
              ]);
        });
  }


  //FUNCTION FOR DELETE COMFIRMATION DAILOG BOX

  void deleteConfirmationDialog(BuildContext context,String documentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteTask(documentId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

}
