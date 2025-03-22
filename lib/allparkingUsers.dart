import 'package:flutter/material.dart';
import '../models/parking_place.dart';
import 'cancelbooking.dart';
import 'complaintscreen.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
class AvailableParkingSpots extends StatefulWidget {
  const AvailableParkingSpots({super.key});

  @override

  _AvailableParkingSpotsState createState() => _AvailableParkingSpotsState();
}

class _AvailableParkingSpotsState extends State<AvailableParkingSpots> {
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    AvailableParking(),  // Available parking spots screen
    const CancelBookingScreen(), // Cancel booking screen
    const ComplaintsScreen(),  // Complaints screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blueGrey,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
       backgroundColor: Colors.blueGrey,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white, // Set selected text/icon color to white
        unselectedItemColor: Colors.white60,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          
          BottomNavigationBarItem(
            
            icon: Icon(Icons.local_parking),
            label: 'Available Parking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel),
            label: 'Cancel Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Complaints',
          ),
        ],
      ),
    );
  }
}

class AvailableParking extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  AvailableParking({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text('Available Parking Spots', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blueGrey,
      centerTitle: true,
      actions: [
        IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await FirebaseAuth.instance.signOut(); // Log the user out
    Navigator.of(context).pushReplacementNamed('/login'); // Navigate to the login screen using the route name
  },
)
      ],
    ),
    body: StreamBuilder<List<ParkingPlace>>(
      stream: _firestoreService.streamParkingPlaces(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No parking places available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          );
        }

        final places = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.local_parking, color: Colors.blueGrey, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(place.name,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Available Spots: ${place.availableSpots}'),
                              Text('Type: ${place.type}'),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(place.status),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            place.status.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showReservationDialog(context, place),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      child: const Text(' Reserve Parking ',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}


  // Helper function to show reservation dialog
  void _showReservationDialog(BuildContext context, ParkingPlace place) {
    final TextEditingController registrationController = TextEditingController();
    final TextEditingController lengthController = TextEditingController();
     final userEmail = FirebaseAuth.instance.currentUser?.email;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reserve ${place.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: registrationController,
                decoration: const InputDecoration(
                  labelText: 'Car Registration Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lengthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Length of Stay (hours)',
                  border: OutlineInputBorder(),
                ),
              ),
            
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final registrationNumber = registrationController.text.trim();
                final lengthOfStay = int.tryParse(lengthController.text.trim()) ?? 0;

                if (registrationNumber.isEmpty || lengthOfStay <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid details')));
                  return;
                }

                await _firestoreService.reserveParking(
                  place.id,
                  registrationNumber,
                  lengthOfStay,
                  userEmail! ,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Parking reserved for $registrationNumber!')),
                );

                Navigator.pop(context); // Close dialog
              },
              child: const Text('Reserve'),
            ),
          ],
        );
      },
    );
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'full':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }
}  