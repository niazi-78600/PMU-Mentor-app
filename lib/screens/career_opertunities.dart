import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class CareerOpportunitiesScreen extends StatefulWidget {
  final User user;

  const CareerOpportunitiesScreen({super.key, required this.user});

  @override
  _CareerOpportunitiesScreenState createState() => _CareerOpportunitiesScreenState();
}

class _CareerOpportunitiesScreenState extends State<CareerOpportunitiesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _opportunityTitleController = TextEditingController();
  final TextEditingController _opportunityDescriptionController = TextEditingController();
  final TextEditingController _opportunityUrlController = TextEditingController();

  List<DocumentSnapshot> _opportunities = [];

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  // Load career opportunities from Firestore
  void _loadOpportunities() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('career_opportunities')
          .orderBy('createdAt', descending: true)
          .get();

      if(mounted){  
        setState(() {
        _opportunities = snapshot.docs;
      });
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading opportunities: ${e.toString()}')),
      );
    }
  }

  // Share a new career opportunity
  void _shareOpportunity() async {
    if (_opportunityTitleController.text.isEmpty || 
        _opportunityDescriptionController.text.isEmpty || 
        _opportunityUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await _firestore.collection('career_opportunities').add({
        'title': _opportunityTitleController.text,
        'description': _opportunityDescriptionController.text,
        'url': _opportunityUrlController.text,
        'createdBy': widget.user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _opportunityTitleController.clear();
      _opportunityDescriptionController.clear();
      _opportunityUrlController.clear();

      _loadOpportunities(); // Refresh the opportunity list
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing opportunity: ${e.toString()}')),
      );
    }
  }

  // Delete a career opportunity
  void _deleteOpportunity(String opportunityId) async {
    try {
      await _firestore.collection('career_opportunities').doc(opportunityId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opportunity deleted successfully')),
      );
      _loadOpportunities(); // Refresh the opportunity list after deletion
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting opportunity: ${e.toString()}')),
      );
    }
  }

  // Launch URL for opportunity
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _opportunityTitleController,
            decoration: const InputDecoration(labelText: 'Opportunity Title'),
          ),
          TextField(
            controller: _opportunityDescriptionController,
            decoration: const InputDecoration(labelText: 'Opportunity Description'),
          ),
          TextField(
            controller: _opportunityUrlController,
            decoration: const InputDecoration(labelText: 'Opportunity URL (e.g., for applying)'),
          ),
          ElevatedButton(
            onPressed: _shareOpportunity,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text('Share Opportunity'),
          ),
          const SizedBox(height: 20),
          const Text('Career Opportunities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: _opportunities.isEmpty
                ? const Center(child: Text('No opportunities shared yet.'))
                : ListView.builder(
                    itemCount: _opportunities.length,
                    itemBuilder: (context, index) {
                      final opportunity = _opportunities[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 5,
                        child: ListTile(
                          title: Text(opportunity['title']),
                          subtitle: Text(opportunity['description']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.launch),
                                onPressed: () {
                                  final url = opportunity['url'];
                                  if (url.isNotEmpty) {
                                    _launchURL(url);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  // Show confirmation dialog before deleting
                                  bool? confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: const Text('Are you sure you want to delete this opportunity?'),
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
                                    _deleteOpportunity(opportunity.id);
                                  }
                                },
                              ),
                            ],
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
