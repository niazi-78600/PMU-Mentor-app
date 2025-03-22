import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class EventsListScreen extends StatelessWidget {
  final User user;

  const EventsListScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events available.'));
          }
          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(event['title'] ?? 'No Title'),
                  subtitle: Text('Created by: ${event['createdBy']}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to Event Details if required
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class CareerOpportunitiesListScreen extends StatelessWidget {
  const CareerOpportunitiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Opportunities'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('career_opportunities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No career opportunities available.'));
          }

          final opportunities = snapshot.data!.docs;

          return ListView.builder(
            itemCount: opportunities.length,
            itemBuilder: (context, index) {
              final opportunity = opportunities[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(opportunity['title']),
                  subtitle: Text(opportunity['description']),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Handle navigation to opportunity details (if needed)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ResourcesListScreen extends StatelessWidget {
  const ResourcesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('resources').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No resources available.'));
          }

          final resources = snapshot.data!.docs;

          return ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(resource['title']),
                  subtitle: Text(resource['description']),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Handle navigation to resource details (if needed)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
