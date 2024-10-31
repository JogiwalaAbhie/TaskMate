import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class changepass extends StatefulWidget {
  const changepass({super.key});

  @override
  State<changepass> createState() => _changepassState();
}

class _changepassState extends State<changepass> {


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
            "Change Password",
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
              Text("Change Your Password",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black
                ),),
              SizedBox(height: 30.0),
              Text(
                'Enter your email address and we will send you a link to change your password.',
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
