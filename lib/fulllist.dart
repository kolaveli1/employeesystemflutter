import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "employeedetails.dart";
import "invitefriend.dart";
import "main.dart";


class Employee {
  final int id;
  final String name;
  final String email;
  final String position;
  final double salary;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
    required this.salary,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      position: json["position"],
      salary: (json["salary"] is int) ? (json["salary"] as int).toDouble() : json["salary"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "position": position,
      "salary": salary,
    };
  }
}


class FullListPage extends StatefulWidget {
  final String userEmail;

  FullListPage({required this.userEmail});

  @override
  _FullListPageState createState() => _FullListPageState();
}

class _FullListPageState extends State<FullListPage> {
  List<Employee> employees = [];
  String sortField = "name";
  String sortOrder = "asc";
  String userName = "";
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchUserName(widget.userEmail);
    fetchEmployees();
  }

  Future<void> fetchUserName(String email) async {
    try {
      final response = await http.get(Uri.parse("http://192.168.0.237:3000/employees/name/$email"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userName = data["name"];
        });
      } else {
        print("Failed to fetch user name");
      }
    } catch (error) {
      print("Error fetching user name: $error");
    }
  }

  Future<void> fetchEmployees() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final url = "http://192.168.0.237:3000/employees?sortField=$sortField&sortOrder=$sortOrder";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          employees = data.map((json) => Employee.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load employees: ${response.statusCode}")),
        );
        print("Failed to load employees: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading employees: $e")),
      );
      print("Error loading employees: $e");
    }
  }

  void handleLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MyApp(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void handleEdit(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetails(employeeId: id),
      ),
    );


    if (result == true) {
      print("Fetching employees after edit...");
      fetchEmployees();
    }
  }

  void handleDelete(int id, String email) async {
    if (email == widget.userEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can't delete the user that's logged in")),
      );
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse("http://192.168.0.237:3000/employees/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          employees.removeWhere((employee) => employee.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Employee deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete employee")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting employee")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee List"),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () => showInviteFriendDialog(context, userName),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: handleLogout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text("Failed to load employees"))
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
                      child: ListTile(
                        title: Text(employee.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email: ${employee.email}"),
                            Text("Position: ${employee.position}"),
                            Text("Salary: ${employee.salary}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () => handleEdit(employee.id),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () => handleDelete(employee.id, employee.email),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
