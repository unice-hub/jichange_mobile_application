import 'package:flutter/material.dart';

class VendorUsersSection extends StatefulWidget {
  const VendorUsersSection({super.key});

  @override
  _VendorUsersSectionState createState() => _VendorUsersSectionState();
}

class _VendorUsersSectionState extends State<VendorUsersSection> {
  final List<VendorUser> users = [
    VendorUser('25540040040', 'User', 'Cilog', 'cilog50844@iteradev.com', '25540040040'),
    VendorUser('apparel1', 'Admin', 'Shin Chin', 'betejoy504@albarulo.com', '25580000900'),
    VendorUser('apparel2', 'Manager', 'Mumtaz Aziz', 'novita3519@albarulo.com', '25580008008'),
  ];

  List<VendorUser> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = users; // Display all users initially
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        return user.username.toLowerCase().contains(query.toLowerCase()) ||
               user.fullName.toLowerCase().contains(query.toLowerCase()) ||
               user.email.toLowerCase().contains(query.toLowerCase()) ||
               user.mobileNumber.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: 'Search by username, full name, email or mobile',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),

          // List of Vendor Users
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return _buildUserCard(filteredUsers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(VendorUser user) {
    return ExpansionTile(
      title: Text(user.username, style: Theme.of(context).textTheme.titleLarge),
      subtitle: Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(user.username[0]), // First letter of username
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
              _buildInfoRow(Icons.badge, 'Role', user.role),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_red_eye_outlined, color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      // Handle view action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      // Handle edit action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    onPressed: () {
                      // Handle delete action
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
}

class VendorUser {
  final String username;
  final String role;
  final String fullName;
  final String email;
  final String mobileNumber;

  VendorUser(this.username, this.role, this.fullName, this.email, this.mobileNumber);
}
