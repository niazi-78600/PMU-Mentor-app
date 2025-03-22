import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import './eventscreation.dart';
import './quick_links_imp.dart'; 
import './resourses.dart'; 
import './career_opertunities.dart'; 
import './study_guides.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import './chat_screen.dart';
class MentorHomeScreen extends StatefulWidget {
  const MentorHomeScreen({super.key});

  @override
  _MentorHomeScreenState createState() => _MentorHomeScreenState();
}

class _MentorHomeScreenState extends State<MentorHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _screens = [
      DashboardScreen(user: _user),
      CreateEventScreen(user: _user),
      ResourcesScreen(user: _user),
      CareerOpportunitiesScreen(user: _user),
      ShareStudyGuideScreen(user: _user),
    ];
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Function to navigate to the chat screen
  void _navigateToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(user: _user, menteeId: '',)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mentor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: _navigateToChat,  // Chat button
          ),
        ],
        backgroundColor: Colors.teal,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        backgroundColor: Colors.transparent,
        color: Colors.teal,
        buttonBackgroundColor: Colors.teal,
        items: const <Widget>[
          Icon(Icons.dashboard, size: 30, color: Colors.white),
          Icon(Icons.event, size: 30, color: Colors.white),
          Icon(Icons.book, size: 30, color: Colors.white),
          Icon(Icons.work, size: 30, color: Colors.white),
          Icon(Icons.library_books, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});
void _updateUserInformation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateUserInfoScreen(user: user),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mentor',// user.displayName ?? 'Mentor',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                         'mentor@gmail.com', //user.email ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Role: Mentor',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _updateUserInformation(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text('Update Info'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

          // Quick Links Section
Text(
  'Quick Links',
  style: Theme.of(context).textTheme.titleLarge,
),
const SizedBox(height: 10),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    // Events Quick Link
    InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventsListScreen(user: user), // Navigate to Events List Screen
          ),
        );
      },
      child: const Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal,
            child: Icon(Icons.event, size: 30, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'All Events',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    ),
    // Resources Quick Link
    InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/resources');
      },
      child: const Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal,
            child: Icon(Icons.book, size: 30, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'All Resources',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    ),

    // Career Opportunities Quick Link
    InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/career');
      },
      child: const Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal,
            child: Icon(Icons.work, size: 30, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'All Careers',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    ),
  ],
),

            const SizedBox(height: 20),

            // Notifications Section
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.teal),
                title: const Text('New mentee joined your session.'),
                subtitle: const Text('2 hours ago'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Handle notification tap
                },
              ),
            ),
            const SizedBox(height: 20),

            // Analytics Section
            Text(
              'Your Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatsCard('Events', '12'),
                _buildStatsCard('Resources', '8'),
                _buildStatsCard('Mentees', '5'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Quick Link Builder
  Widget _buildQuickLink(BuildContext context, IconData icon, String title, String route) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Stats Card Builder
  Widget _buildStatsCard(String title, String count) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
class UpdateUserInfoScreen extends StatefulWidget {
  final User user;

  const UpdateUserInfoScreen({super.key, required this.user});

  @override
  _UpdateUserInfoScreenState createState() => _UpdateUserInfoScreenState();
}

class _UpdateUserInfoScreenState extends State<UpdateUserInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  String? _selectedRole; // Role dropdown value

  final List<String> _roles = ['Mentor', 'Mentee']; // Available roles

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  // Load user data from Firestore and initialize fields
  Future<void> _initializeFields() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        _nameController.text = data?['name'] ?? '';
        _emailController.text = data?['email'] ?? '';
        _selectedRole = data?['role'] ?? _roles.first; // Default to the first role
        _skillsController.text=data?['skills']??'';
        setState(() {}); // Update the UI after initialization
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Information'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Your Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
            ),
              const SizedBox(height: 16),
            TextField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Skills',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String updatedName = _nameController.text.trim();
                final String updatedEmail = _emailController.text.trim();
                final String updatedSkills=_skillsController.text.trim();
                final String? updatedRole = _selectedRole;

                if (updatedName.isEmpty || updatedEmail.isEmpty || updatedRole == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Update Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.user.uid)
                      .update({
                    'displayName': updatedName,
                    'email': updatedEmail,
                    'role': updatedRole,
                    'skills':updatedSkills,
                  });

                  // Optionally update Firebase Authentication user info
                  await widget.user.updateDisplayName(updatedName);
                  await widget.user.updateEmail(updatedEmail);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Information updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.pop(context);
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating information: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
