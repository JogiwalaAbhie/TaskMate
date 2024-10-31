import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmate/home.dart';
import 'package:taskmate/login.dart';
import 'package:taskmate/firestore.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {

  bool _isObscured = true;

  var name="",email="",pass="";

  final formkey=GlobalKey<FormState>();

  TextEditingController _usernameTextController=TextEditingController();
  TextEditingController _emailTextController=TextEditingController();
  TextEditingController _passTextController=TextEditingController();

  String? _errorMessage;

  bool _isLoading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _isLoading=false;
      });
      return 'Please Enter Your Email-ID';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      setState(() {
        _isLoading=false;
      });
      return 'Enter a Valid Email Address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _isLoading=false;
      });
      return 'Please Enter Your Password';
    }
    if (value.length < 6) {
      setState(() {
        _isLoading=false;
      });
      return 'Password Must Be at Least 6 Characters Long';
    }
    return null;
  }

  String? _validateusername(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _isLoading=false;
      });
      return 'Please Enter Your Name';
    }
    return null;
  }

  Future<void> _register() async {
    if (formkey.currentState?.validate() ?? false) {
        setState(() {
          _isLoading = true;
        });
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passTextController.text,
        );
        Firestore_Datasource().CreateUser(_usernameTextController.text,_emailTextController.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content :Text("Register Successfully..",
                style: TextStyle(fontSize: 20.0))));
        Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      }
      finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        title: const Text("Sign Up",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(20),
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  Image.asset("assets/image/logo.jpg",
                    fit: BoxFit.fitWidth,
                    height: 350,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        validator: _validateusername,
                        controller: _usernameTextController,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        autocorrect: true,
                        enableSuggestions: true,
                        cursorColor: Colors.black,
                        style: TextStyle(fontSize: 14,color: Colors.black),
                        decoration: InputDecoration(
                          errorText: _errorMessage,
                            prefixIcon: Icon(
                              Icons.person,
                            ),
                            labelText: "Username :",
                          labelStyle: TextStyle(color: Colors.black),
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
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        validator: _validateEmail,
                        controller: _emailTextController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: true,
                        enableSuggestions: true,
                        cursorColor: Colors.black,
                        style: TextStyle(fontSize: 14,color: Colors.black),
                        decoration: InputDecoration(
                          errorText: _errorMessage,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                            ),
                            labelText: "Email-Id :",
                          labelStyle: TextStyle(color: Colors.black),
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
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        validator: _validatePassword,
                        controller: _passTextController,
                        obscureText: _isObscured,
                        autocorrect: false,
                        enableSuggestions: false,
                        cursorColor: Colors.black,
                        style: TextStyle(fontSize: 14,color: Colors.black),
                        decoration: InputDecoration(
                          errorText: _errorMessage,
                            prefixIcon: Icon(
                              Icons.security_outlined,
                            ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Change the icon based on the _isObscured value
                              _isObscured ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              // Toggle the password visibility
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                            labelText: "Password : ",
                          labelStyle: TextStyle(color: Colors.black),
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
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                  SizedBox(height: 35,),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                  ElevatedButton(
                    onPressed: _register,
                      child: Text(
                        'SIGN UP',
                        style: const TextStyle(
                            color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 16
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, shadowColor: Colors.black, backgroundColor: Colors.blue,
                        elevation: 10, // Elevation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                      ),
                    ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already Have An Account ?",
                        style: TextStyle(color: Colors.black87),),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => login()));
                        },
                        child: const Text(" Sign In",
                          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),

                ],
              ),
            ),
          ),

        ),
      ),
    );
  }
}
