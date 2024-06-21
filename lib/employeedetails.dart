import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

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
      salary: (json["salary"] as num).toDouble(),
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

class EmployeeDetails extends StatefulWidget {
  final int employeeId;

  EmployeeDetails({required this.employeeId});

  @override
  _EmployeeDetailsState createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
  final _formKey = GlobalKey<FormState>();
  late Employee employee;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchEmployeeDetails();
  }

  Future<void> fetchEmployeeDetails() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.0.237:3000/employees/${widget.employeeId}"));
      if (response.statusCode == 200) {
        setState(() {
          employee = Employee.fromJson(jsonDecode(response.body));
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void handleChange(String field, String value) {
    setState(() {
      switch (field) {
        case "name":
          employee = employee.copyWith(name: value);
          break;
        case "position":
          employee = employee.copyWith(position: value);
          break;
        case "salary":
          employee = employee.copyWith(salary: double.tryParse(value) ?? employee.salary);
          break;
      }
    });
  }

  Future<void> saveChanges() async {
    try {
      final response = await http.put(
        Uri.parse("http://192.168.0.237:3000/employees/${widget.employeeId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(employee.toJson()),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Employee updated successfully!")));
        Navigator.pop(context, true);
      } else {
        throw Exception("Failed to update employee");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update employee")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Employee"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text("Failed to load employee details"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: employee.name,
                          decoration: InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                          onChanged: (value) => handleChange("name", value),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          initialValue: employee.email,
                          readOnly: true,
                          decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          initialValue: employee.position,
                          decoration: InputDecoration(labelText: "Position", border: OutlineInputBorder()),
                          onChanged: (value) => handleChange("position", value),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          initialValue: employee.salary.toString(),
                          decoration: InputDecoration(labelText: "Salary", border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => handleChange("salary", value),
                        ),
                        SizedBox(height: 16.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: saveChanges,
                            child: Text("Save"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

extension on Employee {
  Employee copyWith({
    int? id,
    String? name,
    String? email,
    String? position,
    double? salary,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      position: position ?? this.position,
      salary: salary ?? this.salary,
    );
  }
}
