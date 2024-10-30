import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:learingdart/core/utils/api_config.dart';
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
  String? vendorUsersRoleIds;
  String? selectedVendorUsersRole;
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

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({"compid": instituteID}),
      );

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

      );
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

  // Method to edit vendor data from the API
  Future<void> _modifyVendorAPI(VendorUser user, String fullName, String name, String email, String mobile, String sno, String usertype) async {
    const url = 'http://192.168.100.50:98/api/CompanyUsers/AddCompanyUser'; 
    final prefs = await SharedPreferences.getInstance();
    int instituteID = prefs.getInt('instID') ?? 0;
    int userID = prefs.getInt('userID') ?? 0;

    final body = jsonEncode({
      "pos": vendorUsersRoleIds,
      "auname": fullName,
      "mob": mobile,
      "uname": name,
      "mail": email,
      "sno": sno,
      "compid": instituteID,
      "chname": usertype,
      "userid": userID
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Show success dialog
        _showQuickAlert(context, 'Success', 'Vendor modified successfully!', true);
        _loadSessionInfo();// Refresh Vendor list
      } else {
        // Show error dialog
        _showQuickAlert(context, 'Error', 'Failed to modify Vendor: ${response.body}', false);
      }
    } catch (e) {
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

  Future<void> _addCompanyUser(String role, String name, String fullName, String email, String mobile, String sno, String usertype) async {
    const url = 'http://192.168.100.50:98/api/CompanyUsers/AddCompanyUser';
    final prefs = await SharedPreferences.getInstance();
        int instituteID = prefs.getInt('instID') ?? 0;
        int userID= prefs.getInt('userID') ?? 0;

    final body = jsonEncode({
        "pos": role,
        "auname": fullName,
        "mob": mobile,
        "uname": name,
        "mail": email,
        "sno": 0,
        "compid": instituteID,
        "chname": usertype,
        "userid": userID
      });

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token'
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          if (responseBody['response'] == 0) {
           // Extract the message from the "message" array
            String errorMessage = responseBody['message'].isNotEmpty
                ? responseBody['message'][0]
                : 'An error occurred'; // Default message if empty

            _showQuickAlert(context, 'Error', errorMessage, true);
          } else {
            // Handle success
            _showQuickAlert(context, 'Success', 'Vendor added successfully!', true);
            _loadSessionInfo(); // Refresh customer list
          }

        } else {
          // Handle error response
          _showQuickAlert(context, 'Error', 'Failed to add Vendor: ${response.body}', false);
        }
      } catch (e) {

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

  void _showQuickAlert(BuildContext context, String title, String message, bool isSuccess) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
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
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Disable scrolling inside the list
                            itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                return _buildUserCard(filteredUsers[index]);
                              },
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  //to displya usercard 
  Widget _buildUserCard(VendorUser user) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      // margin: const EdgeInsets.symmetric(vertical: 8.0),
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


  void _showEditVendorUserSheet(BuildContext context, VendorUser user) {
    final nameController = TextEditingController(text: user.username);
    final fullNameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final mobileController = TextEditingController(text: user.mobileNumber);
    final snoController = TextEditingController(text: user.id.toString());
    final usertypeController = TextEditingController(text: user.usertype.toString());

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final mobileRegex = RegExp(r'^\d+$');

    String? nameError;
    String? fullNameError;
    String? emailError;
    String? mobileError;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Edit Vendor',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedVendorUsersRole,
                      isExpanded: true,
                      hint: const Text('Select Role'),
                      items: vendorUsersRole.map((role) {
                        return DropdownMenuItem<String>(
                          value: role.sno.toString(),
                          child: Text(
                            "${role.role} ",
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedVendorUsersRole = value;
                          vendorUsersRoleIds = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Name field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'User Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        errorText: nameError,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Full Name field
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        errorText: fullNameError,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Email field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        errorText: emailError,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Mobile field
                    TextField(
                      controller: mobileController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        errorText: mobileError,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16.0),

                    // Save button
                    ElevatedButton(
                      onPressed: () {
                        String name = nameController.text.trim();
                        String fullName = fullNameController.text.trim();
                        String email = emailController.text.trim();
                        String mobile = mobileController.text.trim();
                        String sno = snoController.text.trim();
                        String usertype = usertypeController.text.trim();

                        setState(() {
                          nameError = null;
                          fullNameError = null;
                          emailError = null;
                          mobileError = null;
                        });

                        bool isValid = true;

                        if (name.isEmpty) {
                          setState(() {
                            nameError = 'Please enter your name';
                          });
                          isValid = false;
                        }

                        if (fullName.isEmpty) {
                          setState(() {
                            fullNameError = 'Please enter your full name';
                          });
                          isValid = false;
                        }

                        if (email.isEmpty || !emailRegex.hasMatch(email)) {
                          setState(() {
                            emailError = 'Please enter a valid email address';
                          });
                          isValid = false;
                        }

                        if (mobile.isEmpty || !mobileRegex.hasMatch(mobile)) {
                          setState(() {
                            mobileError = 'Please enter a valid mobile number';
                          });
                          isValid = false;
                        }

                        if (isValid) {
                          Navigator.pop(context);
                          _showModifyConfirmationDialog(context, user, name, fullName, email, mobile, sno, usertype);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}


void _showModifyConfirmationDialog(BuildContext context, VendorUser user, String name, String fullName, String email, String mobile, String sno, String usertype) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Modify Vendor'),
        content: const Text('Are you sure you want to modify this vendor?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _modifyVendorAPI( user, name, fullName,email, mobile, sno,usertype); // Call API to modify customer
            },
            child: const Text('CONFIRM'),
          ),
        ],
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

void _showAddVendorUserSheet(BuildContext context, ) {
  final nameController = TextEditingController();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final snoController = TextEditingController();
  final usertypeController = TextEditingController();

  // Email validation regex pattern
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  // Mobile number validation regex pattern (digits only)
  final mobileRegex = RegExp(r'^\d+$');

  // State variables for error messages
  String? roleError;
  String? nameError;
  String? fullNameError;
  String? emailError;
  String? mobileError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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

                      /// Role Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedVendorUsersRole,
                        isExpanded: true,
                        hint: const Text('Select Role'),
                        items: vendorUsersRole.map((role) {
                          return DropdownMenuItem<String>(
                            value: role.sno.toString(),
                            child: Text(
                              "${role.role} ",
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedVendorUsersRole = value;
                            vendorUsersRoleIds = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          errorText: roleError, // Show error message if roleError is not null
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Name field
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'User Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          errorText: nameError,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Full Name field
                      TextField(
                        controller: fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          errorText: fullNameError,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Email field
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          errorText: emailError,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Mobile field
                      TextField(
                        controller: mobileController,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          errorText: mobileError,
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16.0),

                      // Save button
                      ElevatedButton(
                        onPressed: () {
                          String role = selectedVendorUsersRole ?? '';
                          String name = nameController.text.trim();
                          String fullName = fullNameController.text.trim();
                          String email = emailController.text.trim();
                          String mobile = mobileController.text.trim();
                          String sno = snoController.text.trim();
                          String usertype = usertypeController.text.trim();

                          setState(() {
                            roleError = null;
                            nameError = null;
                            fullNameError = null;
                            emailError = null;
                            mobileError = null;
                          });

                          bool isValid = true;

                          if (role.isEmpty) {
                            setState(() {
                              roleError = 'Please select role';
                            });
                            isValid = false;
                          }

                          if (name.isEmpty) {
                            setState(() {
                              nameError = 'Please enter your name';
                            });
                            isValid = false;
                          }

                          if (fullName.isEmpty) {
                            setState(() {
                              fullNameError = 'Please enter your full name';
                            });
                            isValid = false;
                          }

                          if (email.isEmpty || !emailRegex.hasMatch(email)) {
                            setState(() {
                              emailError = 'Please enter a valid email address';
                            });
                            isValid = false;
                          }

                          if (mobile.isEmpty || !mobileRegex.hasMatch(mobile)) {
                            setState(() {
                              mobileError = 'Please enter a valid mobile number';
                            });
                            isValid = false;
                          }

                          if (isValid) {
                            Navigator.pop(context);
                            _showConfirmationDialog(context, role, name, fullName, email, mobile, sno, usertype);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add vendor',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context,String role, String name, String fullName, String email, String mobile, String sno, String usertype) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Save changes?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('CLOSE'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _addCompanyUser(role, name,fullName, email, mobile, sno, usertype); // Call API to add customer
              },
              child: const Text('CONFIRM'),
            ),
          ],
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
  final String usertype;

  VendorUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.userpos,
    required this.usertype,
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
      usertype: json['Usertype'] ?? 'Unknown',
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
      sno: json['Sno'] ?? 0
    );
  }
}
