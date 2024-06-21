import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "main.dart"; 

class ResetPassword extends StatefulWidget {
  final String email;

  ResetPassword({required this.email});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  String password = "";
  String confirmPassword = "";
  String otp = "";
  String message = "";
  bool passwordError = false;

  Future<void> _handleResetRequest() async {
    if (password != confirmPassword) {
      setState(() {
        message = "Passwords do not match.";
        passwordError = true;
      });
      return;
    } else {
      setState(() {
        passwordError = false;
      });
      try {
        final response = await http.post(
          Uri.parse("http://192.168.0.237:3000/auth/reset-password"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": widget.email, 
            "password": password,
            "otp": otp,
          }),
        );
        final data = jsonDecode(response.body);
        setState(() {
          message = data["message"];
        });
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password reset successfully")),
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Success"),
                content: Text("Password has been reset successfully."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => MyApp()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        print("Failed to reset password: $error");
        setState(() {
          message = "Failed to process your request.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Reset your password",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "New password",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: passwordError ? "Passwords do not match" : null,
                    ),
                    onChanged: (value) {
                      password = value;
                    },
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm new password",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: passwordError ? "Passwords do not match" : null,
                    ),
                    onChanged: (value) {
                      confirmPassword = value;
                    },
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "OTP",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      otp = value;
                    },
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleResetRequest,
                      child: Text("Reset Password"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                  if (message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        message,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
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
