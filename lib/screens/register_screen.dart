import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _availabilityController = TextEditingController();
  // final _roleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _roles = ['Mentor', 'Mentee'];
  String? _selectedRole; // Variable to store selected role
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 @override
  void initState() {
    super.initState();
    _selectedRole = _roles[0]; // Set the default role (optional)
  }
  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new user using Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // After user registration, update their display name
        User? user = userCredential.user;
        await user?.updateDisplayName(_nameController.text.trim());

        // Send email verification
        await user?.sendEmailVerification();

        // Save additional user data (including UID) in Firestore
        await _firestore.collection('users').doc(user?.uid).set({
          'uid': user?.uid, // Explicitly store the UID
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _roleController.text.trim(),
          'bio': _bioController.text.trim(),
          'skills': _skillsController.text.trim(),
          // 'availability': _availabilityController.text.trim(),
          'createdAt': Timestamp.now(), // Store the account creation time
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful! Please verify your email.")),
        );

        // Clear the controllers
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _nameController.clear();
        _roleController.clear();
        _bioController.clear();
        _skillsController.clear();
        _availabilityController.clear();

        // Redirect to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        // Display specific error messages
        String errorMessage = 'An error occurred. Please try again.';
        if (e is FirebaseAuthException) {
          errorMessage = e.message ?? errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50, // Light teal background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Your Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter your name" : null,
                      ),
                      const SizedBox(height: 15),
                      // Role field
                        DropdownButtonFormField<String>(
                        value: _selectedRole,  // Default value
                        items: _roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Role',
                          prefixIcon: const Icon(Icons.account_box, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select your role";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // Bio field
                      TextFormField(
                        controller: _bioController,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          prefixIcon: const Icon(Icons.info, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) => value!.isEmpty ? "Enter a short bio" : null,
                      ),
                      const SizedBox(height: 15),
                      // Skills field
                      TextFormField(
                        controller: _skillsController,
                        decoration: InputDecoration(
                          labelText: 'Skills',
                          prefixIcon: const Icon(Icons.build, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter your skills" : null,
                      ),
                      // const SizedBox(height: 15),
                      // Availability field
                      // TextFormField(
                      //   controller: _availabilityController,
                      //   decoration: InputDecoration(
                      //     labelText: 'Availability',
                      //     prefixIcon: const Icon(Icons.schedule, color: Colors.teal),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10.0),
                      //     ),
                      //   ),
                      //   validator: (value) => value!.isEmpty ? "Enter your availability" : null,
                      // ),
                      const SizedBox(height: 15),
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? "Enter an email" : null,
                      ),
                      const SizedBox(height: 15),
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) =>
                            value!.length < 6 ? "Password must be 6+ characters" : null,
                      ),
                      const SizedBox(height: 15),
                      // Confirm password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Confirm your password";
                          }
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
