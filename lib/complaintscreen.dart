import 'package:flutter/material.dart';


class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  _ComplaintsScreenState createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final _complaintController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  // Function to submit complaint
  void submitComplaint() async {
    final complaintText = _complaintController.text.trim();

    if (complaintText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a complaint')),
      );
      return;
    }

    // Add complaint to Firestore
    await _firestoreService.addComplaint(complaintText);

    // Clear the text field after submission
    _complaintController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint submitted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text field for complaint input
            const SizedBox(height: 10,),
            TextField(
              controller: _complaintController,
              decoration: const InputDecoration(
                labelText: 'Enter your complaint',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            // Button to submit complaint
            ElevatedButton(
              onPressed: submitComplaint,
              child: const Text('Submit Complaint'),
            ),
            const SizedBox(height: 32),
            // Display complaints from Firestore
//             Expanded(
//   child: StreamBuilder<List<Map<String, dynamic>>>(
//     stream: _firestoreService.streamComplaints(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       if (!snapshot.hasData || snapshot.data!.isEmpty) {
//         return const Center(child: Text('No complaints available.'));
//       }

//       final complaints = snapshot.data!;

//       return ListView.builder(
//         itemCount: complaints.length,
//         itemBuilder: (context, index) {
//           final complaint = complaints[index];
//           final Timestamp timestamp = complaint['timestamp'] ?? Timestamp.fromMillisecondsSinceEpoch(0); // Default value if null

//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             child: ListTile(
//               title: Text(complaint['complaintText']),
//               subtitle: Text(
//                 'Submitted at: ${DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch).toString()}',
//                 style: const TextStyle(fontSize: 12),
//               ),
//             ),
//           );
//         },
//       );
//     },
//   ),
// )

          ],
        ),
      ),
    );
  }
}
