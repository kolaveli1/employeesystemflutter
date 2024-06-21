import "package:flutter/material.dart";
import "dart:convert";
import "package:http/http.dart" as http;
import "fulllist.dart";
import "enterotp.dart";
import "reset.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String active = "login";
  String email = "";
  String password = "";
  String repeatPassword = "";
  bool error = false;

  void handleLogin() async {
    setState(() {
      error = false;
    });
    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.237:3000/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FullListPage(userEmail: email)),
        );
      } else if (response.statusCode == 400 && data["message"] == "Email not confirmed. Please check your email for the OTP.") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EnterOtpPage(email: email)),
        );
      } else {
        setState(() {
          error = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${data['message']}")),
        );
      }
    } catch (e) {
      setState(() {
        error = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error during login")),
      );
    }
  }

  void handleRegister() async {
    if (password != repeatPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.237:3000/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration successful. Please check your email for the OTP.")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnterOtpPage(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${data['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error during registration")),
      );
    }
  }

  void showResetPasswordPopup() {
    showDialog(
      context: context,
      builder: (context) => ResetPasswordPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final bool isSmallScreen = width < 600;

    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(24),
            width: isSmallScreen ? width * 0.8 : width * 0.4, 
            height: isSmallScreen ? height * 0.5 : 350, 
            decoration: BoxDecoration(
              color: active == "login" ? Colors.blue : Colors.green,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          setState(() {
                            active = "login";
                          });
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: active == "login" ? FontWeight.bold : FontWeight.normal,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          setState(() {
                            active = "register";
                          });
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: active == "register" ? FontWeight.bold : FontWeight.normal,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white24,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                          obscureText: true,
                        ),
                      ),
                      if (active == "register") SizedBox(width: 20),
                      if (active == "register")
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Repeat Password",
                              labelStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.white24,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                repeatPassword = value;
                              });
                            },
                            obscureText: true,
                          ),
                        ),
                    ],
                  ),
                  if (active == "login")
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: showResetPasswordPopup,
                        child: Text(
                          "Reset Password",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: active == "login" ? handleLogin : handleRegister,
                    child: Text(active == "login" ? "Login" : "Register"),
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
