import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmate/home.dart';
import 'package:taskmate/register.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {

  bool _isObscured = true;

  final formkey = GlobalKey<FormState>();

  final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  TextEditingController _passTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  String? _errorMessage;

  bool _isLoadingbtn = false;

  Future<void> _login() async {
    if (formkey.currentState?.validate() ?? false) {
      setState(() {
        _isLoadingbtn = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passTextController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content :Text("Login Successfully Completed..",
                style: TextStyle(fontSize: 20.0))));
        Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = "Either Email or Password are Incorrect";
        });
      }
      finally {
        setState(() {
          _isLoadingbtn = false;
        });
      }
    }
  }


  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _isLoadingbtn=false;
      });
      return 'Please Enter Your Email-ID';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      setState(() {
        _isLoadingbtn=false;
      });
      return 'Enter a Valid Email Address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _isLoadingbtn=false;
      });
      return 'Please Enter Your Password';
    }
    if (value.length < 6) {
      setState(() {
        _isLoadingbtn=false;
      });
      return 'Password Must Be at Least 6 Characters Long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/image/logo.jpg",
                    fit: BoxFit.fitWidth,
                    height: 300,
                  ),

                  Text(
                    "Login",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40,color: Colors.black),
                  ),
                  Text(
                    "Login To Your Account",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black45
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: _emailTextController,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        autocorrect: true,
                        enableSuggestions: true,
                        cursorColor: Colors.black,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        validator: _validateEmail,
                        decoration: InputDecoration(
                            errorText: _errorMessage,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                          ),
                          labelText: "Email-Id :",
                          labelStyle: TextStyle(color: Colors.black),
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
                        height: 15,
                      )
                    ],
                  ), Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: _passTextController,
                        obscureText: _isObscured,
                        autocorrect: false,
                        enableSuggestions: false,
                        cursorColor: Colors.black,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        validator: _validatePassword,
                        decoration: InputDecoration(
                            errorText: _errorMessage,
                            prefixIcon: Icon(
                              Icons.lock,
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
                            labelText: "Password :",
                            labelStyle: TextStyle(color: Colors.black),
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
                            borderSide: BorderSide(color: Colors.red, width: 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                          },
                          child: Text("Forgot Password ?",
                          style: TextStyle(fontWeight: FontWeight.w800,fontSize: 14,color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  if (_isLoadingbtn)
                    CircularProgressIndicator()
                  else
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 55,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(90)),
                    child: ElevatedButton(
                        onPressed: _login,
                      child: Text(
                        'LOG IN',
                        style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        shadowColor: Colors.black, backgroundColor: Colors.blue,
                        elevation: 10, // Elevation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  signupbtn(),

                  // GOOGLE SIGN IN SECTION

                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Container(
                  //   height: 20,
                  //   width: MediaQuery.of(context).size.width,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //       SizedBox(
                  //         width: 100,
                  //         height: 1,
                  //         child: Container(
                  //           color: Colors.black,
                  //         ),
                  //       ),
                  //       Text("Or Login With",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black),),
                  //       SizedBox(
                  //         width: 100,
                  //         height: 1,
                  //         child: Container(
                  //           color: Colors.black,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 25,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     GestureDetector(
                  //       onTap: _signInWithGoogle,
                  //       child: Image.asset(
                  //         "assets/image/google.jpg",
                  //         fit: BoxFit.fitWidth,
                  //         height: 40,
                  //       ),
                  //     ),
                  //     SizedBox(width: 20,),
                  //     Image.asset(
                  //       "assets/image/facebook.png",
                  //       fit: BoxFit.fitWidth,
                  //       height: 40,
                  //     ),
                  //   ],
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row signupbtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't Have An Account ?",
          style: TextStyle(color: Colors.black87),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => register()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}


class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _message = '';

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return 'Please Enter Your Email-ID' ;
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      setState(() {
        _isLoading = false;
      });
      return 'Enter a Valid Email Address';
    }
    return null;
  }


  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent!')),
        );
        Navigator.of(context).pop(); // Navigate back after success
      } on FirebaseAuthException catch (e) {
        setState(() {
          _message = "Please Enter Email";
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Forgot Password",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black
            )
        ),
        elevation: 10.0, // Shadow under the AppBar
        backgroundColor: Colors.white,
        ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30.0),
              Text("Find Your Email",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 26,
                color: Colors.black
              ),),
              SizedBox(height: 30.0),
              Text(
                'Enter your email address and we will send you a link to reset your password.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 36.0),
              TextFormField(
                controller: _emailController,
                validator: _validateEmail,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_rounded,
                  ),
                  labelText : "Email-ID : ",
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
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 40.0),
              if (_isLoading)
                CircularProgressIndicator()
              else
              Container(
                width: MediaQuery.of(context).size.width,
                height: 55,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(90)),
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  child: Text(
                    'Send',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black, backgroundColor: Colors.blue,
                    elevation: 10, // Elevation
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _message,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
