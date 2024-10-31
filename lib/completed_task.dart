import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class complete_task extends StatefulWidget {
  const complete_task({super.key});

  @override
  State<complete_task> createState() => _complete_taskState();
}

class _complete_taskState extends State<complete_task> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Task',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black
            )),
        elevation: 50, // Shadow under the AppBar
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Flexible(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('tasks')
                      .where('isDone', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No completed tasks.'));
                    }
                    final tasks = snapshot.data!.docs;

                    return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          var task = tasks[index];
                          bool isDone = task['isDone'] ?? false;

                          Timestamp taskTimestamp = task['startTime'];
                          DateTime taskTime = taskTimestamp.toDate();

                          String formattedTime =
                          DateFormat('HH:mm').format(taskTime);
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Container(
                                height: 130,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
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
                                                  task['title'],
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
                                                      // if (newValue != null) {
                                                      //   _showConfirmationDialog(context, documentId);
                                                      // }
                                                    })
                                              ],
                                            ),
                                            Text(task['subtitle'],
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
                                                width: 180,
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
                                                      width: 10,
                                                    ),
                                                    Container(
                                                        width: 75,
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
                                                              12,
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
                                                                width: 10,
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
                            // ),
                          );
                        });
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
