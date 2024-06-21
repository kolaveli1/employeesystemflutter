import "package:flutter/material.dart";
import "package:flutterapp2/fulllist.dart";
import "package:http/http.dart" as http;
import "dart:convert";

class EnterOtpPage extends StatefulWidget {
  final String email;

  EnterOtpPage({required this.email});

  @override
  _EnterOtpPageState createState() => _EnterOtpPageState();
}

class _EnterOtpPageState extends State<EnterOtpPage> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String position = "";
  double salary = 0;
  String otp = "";
  bool otpError = false;

  Future<void> handleSubmit() async {
    final response = await http.post(
      Uri.parse("http://192.168.0.237:3000/auth/verify-email"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": widget.email,
        "otp": otp,
        "name": name,
        "position": position,
        "salary": salary,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullListPage(userEmail: widget.email),
        ),
      );
    } else {
      setState(() {
        otpError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue[500],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "An email has been sent to ${widget.email}. Please enter your details and the OTP from the email.",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    _buildTextFormField(
                      labelText: "Name",
                      onChanged: (value) => setState(() => name = value),
                    ),
                    SizedBox(height: 20),
                    _buildTextFormField(
                      labelText: "Position",
                      onChanged: (value) => setState(() => position = value),
                    ),
                    SizedBox(height: 20),
                    _buildTextFormField(
                      labelText: "Salary",
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          setState(() => salary = double.tryParse(value) ?? 0),
                    ),
                    SizedBox(height: 20),
                    _buildTextFormField(
                      labelText: "OTP",
                      onChanged: (value) => setState(() {
                        otp = value;
                        otpError = false;
                      }),
                      errorText: otpError ? "Invalid OTP" : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: handleSubmit,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Verify OTP"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        errorText: errorText,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: Colors.white),
    );
  }
}
