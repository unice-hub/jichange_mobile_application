import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VendorUsersSection extends StatefulWidget {
  const VendorUsersSection({super.key});

  @override
  _VendorUsersSectionState createState() => _VendorUsersSectionState();
}

class _VendorUsersSectionState extends State<VendorUsersSection> {
  List<VendorUser> vendorUsers = [];
  List<VendorUserRole> vendorUsersRole = [];
  List<VendorUser> filteredUsers = [];
  String searchQuery = "";
  String _token = 'Not logged in';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
    _fetchVendorUsersData();
    _fetchVendorUsersRoleData();
    
  }

  // Method to fetch Vendor Users data from the API
  Future<void> _fetchVendorUsersData() async {
    const url = 'http://192.168.100.50:98/api/CompanyUsers/GetCompanyUserss';
    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;

      log('Making API request with token: $_token and instituteID: $instituteID');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({"compid": instituteID}),
      );

      log('API Status Code: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['response'] is List) {
          setState(() {
            vendorUsers = (responseBody['response'] as List)
                .map((item) => VendorUser.fromJson(item))
                .toList();
            // filteredUsers = vendorUsers; // Initialize filtered users
            isLoading = false;
          });
        } else {
          _showSnackBar('Unexpected data format: response is not a list');
        }
      } else {
        _showSnackBar('Error: Failed to fetch vendor users');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
      setState(() {
        isLoading = false;
      });
    }
  }

   // Show error dialog in case of failure
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Method to fetch Vendor Users data from the API
  Future<void> _fetchVendorUsersRoleData() async {
    const url = 'http://192.168.100.50:98/api/Role/GetRolesAct';
    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;

      log('Making API request with token: $_token and instituteID: $instituteID');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        // body: jsonEncode({"compid": instituteID}),
      );

      log('API Status Code: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['response'] is List) {
          setState(() {
            vendorUsersRole = (responseBody['response'] as List)
                .map((item) => VendorUserRole.fromJson(item))
                .toList();
            
            isLoading = false;
          });
        } else {
          _showSnackBar('Unexpected data format: response is not a list');
        }
      } else {
        _showSnackBar('Error: Failed to fetch vendor users');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String getRoleActDescription(String userPosition) {
    try {
      var t = vendorUsersRole.firstWhere((role) => role.sno == int.parse(userPosition));
      return t.role;
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    filteredUsers = vendorUsers.where((user) {
      return user.username.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.mobileNumber.contains(searchQuery);
    }).toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,  // Updated for better background color.
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss keyboard when tapping outside.
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: 'Search by username, full name, email, or mobile',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredUsers.isEmpty
                        ? const Center(child: Text("No vendor users found"))
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                return _buildUserCard(filteredUsers[index]);
                              },
                            ),
                          ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddVendorUserSheet(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  //to displya usercard 
  Widget _buildUserCard(VendorUser user) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(user.username, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            user.username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.person, 'Full Name', user.fullName),
                const SizedBox(height: 8.0),
                _buildInfoRow(Icons.phone, 'Mobile Number', user.mobileNumber),
                const SizedBox(height: 8.0),
                _buildInfoRow(Icons.badge, 'Role', getRoleActDescription(user.userpos)),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildIconActionButton(Icons.send, () {
                      _showResendCredentialsDialog(context, user);
                    }, Colors.black),

                    _buildIconActionButton(Icons.edit, () {
                      _showEditVendorUserSheet(context, user);
                    }, Colors.blue),

                    // IconButton(

                    //   icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                    //   onPressed: () {
                    //     _showResendCredentialsDialog(context, user);
                    //   },
                    // ),
                    // IconButton(
                    //   icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                    //   onPressed: () {
                    //     _showEditVendorUserSheet(context, user);
                    //   },
                    // ),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconActionButton(IconData icon, VoidCallback onPressed, Color iconColor) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: iconColor, width: 2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),        // Flat edge
            topRight: Radius.circular(16),       // Curved edge
            bottomLeft: Radius.circular(16),     // Curved edge
            bottomRight: Radius.circular(16),     // Flat edge
          ), // Apply caved corner effect
        ),
        child: IconButton(
          icon: Icon(icon, color: iconColor),
          onPressed: onPressed,
        ),
      ),
      // Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}


  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8.0),
        Text('$label: $value', style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  void _showResendCredentialsDialog(BuildContext context, VendorUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resend credentials'),
          content: const Text('Choose email or mobile to receive reissued credentials.'),
          actions: [
            TextButton(
              onPressed: () {
                _sendCredentialsByEmail(user);
                Navigator.pop(context);
              },
              child: const Text('Email'),
            ),
            TextButton(
              onPressed: () {
                _sendCredentialsBySMS(user);
                Navigator.pop(context);
              },
              child: const Text('Telephone'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendCredentialsByEmail(VendorUser user) async {
    const url = 'http://192.168.100.50:98/api/CompanyUsers/ResendCredentials';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
           "resendCredentials": "email",
           "companyUserId": user.id
        }),
      );

      log('API Status Code: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _showSnackBar('Credentials sent to email successfully.');
      } else {
        _showSnackBar('Error: Failed to send credentials to email.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendCredentialsBySMS(VendorUser user) async {
    const url = 'http://192.168.100.50:98/api/CompanyUsers/ResendCredentials';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
           "resendCredentials": "mobile",
           "companyUserId": user.id
        }),
      );

      log('API Status Code: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _showSnackBar('Credentials sent to mobile successfully.');
      } else {
        _showSnackBar('Error: Failed to send credentials to mobile.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
      setState(() {
        isLoading = false;
      });
    }
  }

  //Editing vendor users
  void _showEditVendorUserSheet(BuildContext context, VendorUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Edit Vendor User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16.0),
                  _buildEditableTextField('Username', user.username),
                  const SizedBox(height: 16.0),
                  _buildEditableTextField('Full Name', user.fullName),
                  const SizedBox(height: 16.0),
                  _buildEditableTextField('Email', user.email),
                  const SizedBox(height: 16.0),
                  _buildEditableTextField('Mobile Number', user.mobileNumber),
                  const SizedBox(height: 16.0),
                  // _buildEditableTextField('Role', user1.role),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildEditableTextField(String label, String initialValue) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: initialValue),
    );
  }

  void _showAddVendorUserSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Add Vendor User',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16.0),
                  _buildEditableTextField('Username', ''),
                  const SizedBox(height: 16.0),
                  _buildEditableTextField('Full Name', ''),
                  const SizedBox(height: 16.0),
                  _buildEditableTextField('Email', ''),
                  const SizedBox(height: 16.0),
                  _buildEditableTextField('Mobile Number', ''),
                  const SizedBox(height: 16.0),
                  _buildEditableTextField('Role', ''),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: const Text('Add Vendor User'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


class VendorUser {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String userpos;

  VendorUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.userpos,
  });

  // Factory method to create a VendorUser object from JSON
   factory VendorUser.fromJson(Map<String, dynamic> json) {
    return VendorUser(
      id: json['CompuserSno'] ?? 0,
      username: json['Username'] ?? 'Unknown',
      fullName: json['Fullname'] ?? 'Unknown',
      email: json['Email'] ?? 'Unknown',
      mobileNumber: json['Mobile'] ?? 'Unknown',
      userpos: json['Userpos'] ?? 'Unknown',
    );
  }
}

class VendorUserRole {
  final String role;
  final int sno;

  VendorUserRole({
    required this.role,
    required this.sno,
  });

  // Factory method to create a VendorUser object from JSON
   factory VendorUserRole.fromJson(Map<String, dynamic> json) {
    return VendorUserRole(
      role: json['Description'] ?? 'Unknown',
      sno: json['Sno'] ?? -1
    );
  }
}
