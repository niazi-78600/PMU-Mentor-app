import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class ShareStudyGuideScreen extends StatefulWidget {
  const ShareStudyGuideScreen({super.key, required User user});

  @override
  _ShareStudyGuideScreenState createState() => _ShareStudyGuideScreenState();
}

class _ShareStudyGuideScreenState extends State<ShareStudyGuideScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedFile;

  // Pick a file using FilePicker
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file selected.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Upload the study guide (file is optional)
  Future<void> _uploadStudyGuide() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a title.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String? fileUrl; // Optional file URL

      // If a file is selected, upload it to Firebase Storage
      if (_selectedFile != null) {
        final fileName = _selectedFile!.path.split('/').last;
        final storageRef = FirebaseStorage.instance.ref().child('study_guides/$fileName');
        final uploadTask = await storageRef.putFile(_selectedFile!);
        fileUrl = await uploadTask.ref.getDownloadURL();
      }

      // Get the user ID for the uploaded guide
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Add metadata to Firestore
      await FirebaseFirestore.instance.collection('study_guides').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'url': fileUrl, // File URL (null if no file is uploaded)
        'uploadedBy': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study guide uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields after upload
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedFile = null;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading guide: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fetch study guides from Firestore
  Stream<QuerySnapshot> _fetchStudyGuides() {
    return FirebaseFirestore.instance
        .collection('study_guides')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Study Guide'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Select File (Optional)'),
            ),
            if (_selectedFile != null)
              Text('Selected File: ${_selectedFile!.path.split('/').last}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadStudyGuide,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Upload'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Uploaded Study Guides:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchStudyGuides(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No study guides available.');
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final guide = snapshot.data!.docs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(guide['title']),
                          subtitle: Text(guide['description']),
                          trailing: guide['url'] != null
                              ? IconButton(
                                  icon: const Icon(Icons.open_in_browser),
                                  onPressed: () {
                                    // Open the file URL
                                    final url = guide['url'];
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Open this URL: $url'),
                                      ),
                                    );
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
