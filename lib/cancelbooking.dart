import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({super.key});

  @override
  _CancelBookingScreenState createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  List<Map<String, dynamic>> _userReservations = [];
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;  // Add a loading state

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserReservations(user.uid);
      } else {
        setState(() {
          _userReservations = [];
          _isLoading = false;  // Set loading to false when no user is logged in
        });
      }
    });
  }

  // Fetch reservations when the user logs in or the screen is initialized
  void _fetchUserReservations(String userId) async {
    setState(() {
      _isLoading = true;  // Set loading to true when fetching data
    });
    final reservations = await _firestoreService.getUserReservations(userId);
    setState(() {
      _userReservations = reservations;
      _isLoading = false;  // Set loading to false once data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancel Reservation', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())  // Show loading spinner
          : _userReservations.isEmpty
              ? const Center(child: Text('No reservations found'))
              : ListView.builder(
                  itemCount: _userReservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _userReservations[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 4.0,
                      child: ListTile(
                        title: Text(reservation['parkingPlaceName']),
                        subtitle: Text(
                          'Registration: ${reservation['registrationNumber']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            _cancelReservation(reservation['parkingPlaceId'], reservation['reservationId']);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Method to cancel a reservation
  void _cancelReservation(String parkingPlaceId, String reservationId) async {
    try {
      await _firestoreService.cancelReservation(parkingPlaceId, reservationId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation canceled successfully!')),
      );
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        _fetchUserReservations(userId); // Refresh the list after canceling
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error canceling reservation')),
      );
    }
  }
}
