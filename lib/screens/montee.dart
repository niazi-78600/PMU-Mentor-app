import 'package:flutter/material.dart';

// void main() {
//   runApp(MenteeApp());
// }

class MenteeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal,
        hintColor: Color(0xFF4CAF50),
        scaffoldBackgroundColor: Color(0xFFF7F9FC),
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      home: MenteeDashboard(),
    );
  }
}

class MenteeDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentee Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.person,
              title: 'Mentor Profile',
              color: Colors.blue[100]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MentorProfile()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.chat,
              title: 'Messaging',
              color: Colors.green[100]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessagingScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.event,
              title: 'Events',
              color: Colors.purple[100]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.account_circle,
              title: 'Profile',
              color: Colors.orange[100]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenteeProfile()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MentorProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentor Profile'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://example.com/mentor_image.jpg'),
            ),
            SizedBox(height: 10),
            Text('John Doe', style: Theme.of(context).textTheme.titleLarge),
            Text('Mobile App Development Expert', style: Theme.of(context).textTheme.bodyMedium),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'John is a seasoned mentor with 5+ years of experience in mobile application development.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Add functionality to request mentorship
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: Text('Request Mentorship'),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messaging'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Message ${index + 1}'),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    // Add message sending logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildEventCard(context, title: 'Flutter Workshop', date: '10 Dec 2024'),
          _buildEventCard(context, title: 'App Dev Webinar', date: '12 Dec 2024'),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, {required String title, required String date}) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text('Date: $date'),
        trailing: ElevatedButton(
          onPressed: () {
            // Add event joining logic
          },
          child: Text('Join'),
        ),
      ),
    );
  }
}

class MenteeProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://example.com/mentee_image.jpg'),
            ),
            SizedBox(height: 20),
            Text('Jane Smith', style: Theme.of(context).textTheme.titleLarge),
            Text('Aspiring Flutter Developer', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add profile editing logic
              },
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
