import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateEventScreen extends StatefulWidget {
     final String? eventId;
  const CreateEventScreen({super.key, this.eventId, required User user});
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _eventDateTime;
  String _eventType = 'Virtual'; // Default event type
  final _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to create an event
  void _createEvent() async {
    if (_formKey.currentState!.validate() && _eventDateTime != null) {
      try {
        // Get the current user's ID
        User? user = _auth.currentUser;

        if (user != null) {
          // Store event details in Firestore
          await _firestore.collection('events').add({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'dateTime': _eventDateTime,
            'location': _locationController.text,
            'eventType': _eventType,
            'createdBy': user.uid,
            'createdAt': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully!')),
          );

          // Reset form
          _titleController.clear();
          _descriptionController.clear();
          _locationController.clear();
          setState(() {
            _eventDateTime = null;
            _eventType = 'Virtual';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Function to delete an event
  void _deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // DateTime picker for event date/time
  Future<void> _pickDateTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        setState(() {
          _eventDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      // appBar: AppBar(
      //   title: const Text('Events'),
      //   backgroundColor: Colors.teal, // Theme color
      // ),
     body: Padding(
     padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
       key: _formKey,
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Event Title',
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter a title' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Event Description',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter a description' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location (for in-person events)',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter a location' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Event Type: '),
              DropdownButton<String>(
                value: _eventType,
                onChanged: (newValue) {
                  setState(() {
                    _eventType = newValue!;
                  });
                },
                items: <String>['Virtual', 'In-person']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _pickDateTime,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Text(
              _eventDateTime == null
                  ? 'Pick Event Date and Time'
                  : 'Event Date/Time: ${_eventDateTime!.toLocal()}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _createEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text(
              'Create Event',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    ),
  ),
),

    );
  }
}
