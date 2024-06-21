import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

void showInviteFriendDialog(BuildContext context, String userName) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String friendEmail = "";
      String friendName = "";

      Future<void> sendInvite() async {
        final response = await http.post(
          Uri.parse("http://192.168.0.237:3000/auth/send-invite"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": friendEmail,
            "friend": friendName,
            "name": userName,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Success"),
                content: Text("Invitation sent successfully!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to send invite")),
          );
        }
      }

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Invite a Friend"),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: "Friend's Email",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      friendEmail = value;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Friend's Name",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      friendName = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: sendInvite,
                child: Text("Send Invitation"),
              ),
            ],
          );
        },
      );
    },
  );
}
