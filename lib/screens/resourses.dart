import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ResourcesScreen extends StatefulWidget {
  final User user;

  const ResourcesScreen({super.key, required this.user});

  @override
  _ResourcesScreenState createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DocumentSnapshot> _resources = [];
  final TextEditingController _resourceTitleController = TextEditingController();
  final TextEditingController _resourceDescriptionController = TextEditingController();
  XFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  // Load shared resources
void _loadResources() async {
  try {
    QuerySnapshot snapshot = await _firestore
        .collection('resources')
        .where('createdBy', isEqualTo: widget.user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    if (mounted) { // Check if the widget is still mounted
      setState(() {
        _resources = snapshot.docs;
      });
    }
  } catch (e) {
    print(e);
    if (mounted) { // Check if the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading resources: ${e.toString()}')),
      );
    }
  }
}

  // Share a new resource
  void _shareResource() async {
    if (_resourceTitleController.text.isEmpty || _resourceDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    String resourceUrl = '';
    if (_pickedFile != null) {
      try {
        final ref = _storage.ref().child('resources/${DateTime.now().millisecondsSinceEpoch}');
        await ref.putFile(File(_pickedFile!.path));
        resourceUrl = await ref.getDownloadURL();
      } catch (e) {
        print(e);
      }
    }

    try {
      await _firestore.collection('resources').add({
        'title': _resourceTitleController.text,
        'description': _resourceDescriptionController.text,
        'createdBy': widget.user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'resourceUrl': resourceUrl,
      });

      _resourceTitleController.clear();
      _resourceDescriptionController.clear();
      setState(() {
        _pickedFile = null;
      });

      _loadResources(); // Refresh the resource list
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing resource: ${e.toString()}')),
      );
    }
  }

  // Delete resource
  void _deleteResource(String resourceId, String resourceUrl) async {
    try {
      // Delete file from Firebase Storage if it exists
      if (resourceUrl.isNotEmpty) {
        await _storage.refFromURL(resourceUrl).delete();
      }

      // Delete resource document from Firestore
      await _firestore.collection('resources').doc(resourceId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource deleted successfully')),
      );

      _loadResources(); // Refresh the resource list after deletion
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting resource: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _resourceTitleController,
            decoration: const InputDecoration(labelText: 'Resource Title'),
          ),
          TextField(
            controller: _resourceDescriptionController,
            decoration: const InputDecoration(labelText: 'Resource Description'),
          ),
          ElevatedButton(
            onPressed: () async {
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              setState(() {
                _pickedFile = pickedFile;
              });
            },
            child: const Text('Pick a file'),
          ),
          _pickedFile != null
              ? Text('File selected: ${_pickedFile!.name}')
              : const SizedBox(),
          ElevatedButton(
            onPressed: _shareResource,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text('Share Resource'),
          ),
          const SizedBox(height: 20),
          const Text('Shared Resources', style: TextStyle(fontSize: 18)),
          _resources.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Text('No resources shared yet.'),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _resources.length,
                    itemBuilder: (context, index) {
                      final resource = _resources[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 5,
                        child: ListTile(
                          title: Text(resource['title']),
                          subtitle: Text(resource['description']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Show confirmation dialog before deleting
                              bool? confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text('Are you sure you want to delete this resource?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmDelete == true) {
                                _deleteResource(resource.id, resource['resourceUrl']);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
