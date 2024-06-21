import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "resetpassword.dart";

class ResetPasswordPopup extends StatefulWidget {
  @override
  _ResetPasswordPopupState createState() => _ResetPasswordPopupState();
}

class _ResetPasswordPopupState extends State<ResetPasswordPopup> {
  String message = "";
  String email = ""; 

  Future<void> handleResetRequest() async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.237:3000/auth/send-reset-email"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email}),
      );
      final data = jsonDecode(response.body);
      setState(() {
        message = data["message"];
      });
      if (response.statusCode == 201) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ResetPassword(email: email)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send reset email: ${data['message']}")),
        );
      }
    } catch (error) {
      setState(() {
        message = "Failed to process your request.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send reset email: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Enter your email",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "Email address",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              setState(() {
                email = value; 
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              handleResetRequest();
            },
            child: Text("Send reset password"),
          ),
          SizedBox(height: 20),
          if (message.isNotEmpty) Text(message),
        ],
      ),
    );
  }
}
