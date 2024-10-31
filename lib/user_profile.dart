import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taskmate/changepassword.dart';
import 'package:taskmate/home.dart';
import 'package:taskmate/login.dart';
import 'package:taskmate/register.dart';
import 'package:taskmate/settingpage.dart';

class user_profile extends StatefulWidget {
  const user_profile({super.key});

  @override
  State<user_profile> createState() => _user_profileState();
}

class _user_profileState extends State<user_profile> {

  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }


  Future<void> _fetchUserProfile() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username']; // Fetch the username
          _email = userDoc['email']; // Fetch the email
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User Profile',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black
              )),
          elevation: 50, // Shadow under the AppBar
          backgroundColor: Colors.white,
        ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height*0.9,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(height: 50,),
                Container(
                  height: 170,
                  width: 170,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                        'assets/image/man.png'),
                  ),
                ),
                SizedBox(height: 10,),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                //   child: Container(
                //     height: 60,
                //     width: MediaQuery.of(context).size.width,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(10),
                //       color: Colors.white,
                //       boxShadow: [
                //         BoxShadow(
                //             color: Colors.blue.withOpacity(0.1),
                //             spreadRadius: 5,
                //             blurRadius: 7,
                //             offset: Offset(0,2))
                //       ],
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Text("Username : $_username",
                //         style: TextStyle(
                //           color: Colors.black,
                //           fontWeight: FontWeight.bold,
                //           fontSize: 18,
                //         ),),
                //       ],
                //     ),
                //   ),
                // ),
                // SizedBox(height: 20,),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                //   child: Container(
                //     height: 60,
                //     width: MediaQuery.of(context).size.width,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(10),
                //       color: Colors.white,
                //       boxShadow: [
                //         BoxShadow(
                //             color: Colors.blue.withOpacity(0.1),
                //             spreadRadius: 5,
                //             blurRadius: 7,
                //             offset: Offset(0,2))
                //       ],
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Text("Email : $_email",
                //           style: TextStyle(
                //             color: Colors.black,
                //             fontWeight: FontWeight.bold,
                //             fontSize: 18,
                //           ),),
                //       ],
                //     ),
                //   ),
                // ),
                // SizedBox(height: 20,),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                //   child: Container(
                //     height: 60,
                //     width: MediaQuery.of(context).size.width,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(10),
                //       color: Colors.white,
                //       boxShadow: [
                //         BoxShadow(
                //             color: Colors.blue.withOpacity(0.1),
                //             spreadRadius: 5,
                //             blurRadius: 7,
                //             offset: Offset(0,2))
                //       ],
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Text("Phone Number : phone number",
                //           style: TextStyle(
                //             color: Colors.black,
                //             fontWeight: FontWeight.bold,
                //             fontSize: 18,
                //           ),),
                //       ],
                //     ),
                //   ),
                // )
                Text("$_username",
                style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold),),
                Text("$_email",
                style: TextStyle(fontSize: 18,fontWeight: FontWeight.w200),),
                SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Container(
                        height: 65,
                        width: MediaQuery.of(context).size.width*0.9,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26, // Shadow color
                              blurRadius: 8, // Shadow blur radius
                              offset: Offset(2, 2), // Shadow offset
                            ),
                          ],
                        ),child: Row(
                        children: [
                          Icon(Icons.mode_edit,color: Colors.black,),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(fontWeight: FontWeight.bold),)
                            ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
                        ],
                      ),
                      ),
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => usereditprofile()));
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Container(
                        height: 65,
                        width: MediaQuery.of(context).size.width*0.9,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26, // Shadow color
                              blurRadius: 8, // Shadow blur radius
                              offset: Offset(2, 2), // Shadow offset
                            ),
                          ],
                        ),child: Row(
                        children: [
                          Icon(Icons.password,color: Colors.black,),
                          SizedBox(width: 10),
                          Expanded(
                              child: Text(
                                'Change Password',
                                style: TextStyle(fontWeight: FontWeight.bold),)
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
                        ],
                      ),
                      ),
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => changepass()));
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Container(
                        height: 65,
                        width: MediaQuery.of(context).size.width*0.9,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26, // Shadow color
                              blurRadius: 8, // Shadow blur radius
                              offset: Offset(2, 2), // Shadow offset
                            ),
                          ],
                        ),child: Row(
                        children: [
                          Icon(Icons.task_outlined,color: Colors.black,),
                          SizedBox(width: 10),
                          Expanded(
                              child: Text(
                                'My Tasks',
                                style: TextStyle(fontWeight: FontWeight.bold),)
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
                        ],
                      ),
                      ),
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => home()));
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Container(
                        height: 65,
                        width: MediaQuery.of(context).size.width*0.9,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26, // Shadow color
                              blurRadius: 8, // Shadow blur radius
                              offset: Offset(2, 2), // Shadow offset
                            ),
                          ],
                        ),child: Row(
                        children: [
                          Icon(Icons.logout,color: Colors.black,),
                          SizedBox(width: 10),
                          Expanded(
                              child: Text(
                                'Log Out',
                                style: TextStyle(fontWeight: FontWeight.bold),)
                          ),
                        ],
                      ),
                      ),
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => register()));
                      },
                    ),
                  ],
                ),
                SizedBox(height: 60,),
                Expanded(
                    child: Text(
                      '© ${DateTime.now().year} TaskMate. Your productivity is our priority.')
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class usereditprofile extends StatefulWidget {
  const usereditprofile({super.key});

  @override
  State<usereditprofile> createState() => _usereditprofileState();
}

class _usereditprofileState extends State<usereditprofile> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _gender;

  final formkey = GlobalKey<FormState>();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter Your Email-ID';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return 'Enter a Valid Email Address';
    }
    return null;
  }

  // Fetch user data from Firestore
  Future<void> fetchUserData() async {
    if (FirebaseAuth.instance.currentUser != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _usernameController.text = userData['username'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _dobController.text = userData['dob'] ?? '';
          _gender = userData['gender'] ?? 'Male';
        });
      }
    }
  }


  // Update user data in Firestore
  Future<void> updateUserData() async {
    if (formkey.currentState?.validate() ?? false) {
      if (FirebaseAuth.instance.currentUser!.uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'username': _usernameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'dob': _dobController.text,
          'gender': _gender
        });

        Fluttertoast.showToast(
          msg: "Profile Updated Successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color(0xFF0C1A38),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => user_profile()));
      }
    }
  }



  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = picked.toLocal().toString().split(' ')[0]; // Display the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User-Profile',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black
            )),
        elevation: 50, // Shadow under the AppBar
        backgroundColor: Colors.white,
      ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: formkey,
            child: SingleChildScrollView(
              child: Column(
                children: [

                  // USERNAME :

                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Username : ",
                      style: TextStyle(fontWeight: FontWeight.w800),),
                    ],
                  ),
                  SizedBox(height: 8,),
                  TextFormField(
                    controller: _usernameController,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                        Icons.person,
                    ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                    ),
                  ),

                  // EMAIL :

                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Email - ID : ",
                        style: TextStyle(fontWeight: FontWeight.w800),),
                    ],
                  ),
                  SizedBox(height: 8,),
                  TextFormField(
                    controller: _emailController,
                    autocorrect: true,
                    enableSuggestions: true,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      errorText: _errorMessage,
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // PHONE NUMBER :

                  SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Phone Number : ",
                        style: TextStyle(fontWeight: FontWeight.w800),),
                    ],
                  ),
                  SizedBox(height: 8,),
                  TextFormField(
                    controller: _phoneController,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    maxLength: 10,
                    // maxLengthEnforcement: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),

                  // DOB :

                  SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Date Of Birth : ",
                        style: TextStyle(fontWeight: FontWeight.w800),),
                    ],
                  ),
                  SizedBox(height: 8,),
                  TextFormField(
                    controller: _dobController,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.date_range,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                    ),
                    readOnly: true,  // Make it read-only for date picker
                    onTap: () {
                      _selectDate(context);
                    },
                  ),

                  // GENDER :

                  SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Gender : ",
                        style: TextStyle(fontWeight: FontWeight.w800),),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _gender,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Row(
                                children: [
                                  Icon(Icons.male, color: Colors.blue),
                                  SizedBox(width: 8.0),
                                  Text('Male'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Row(
                                children: [
                                  Icon(Icons.female, color: Colors.pink),
                                  SizedBox(width: 8.0),
                                  Text('Female'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Row(
                                children: [
                                  Icon(Icons.person, color: Colors.grey),
                                  SizedBox(width: 8.0),
                                  Text('Other'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _gender = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // BUTTONS :

                  SizedBox(height: 40),
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
                              updateUserData();
                              //Navigator.of(context).pop();
                            },
                            child: Text("Save",
                              style: TextStyle(fontWeight: FontWeight.bold),),
                          )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
