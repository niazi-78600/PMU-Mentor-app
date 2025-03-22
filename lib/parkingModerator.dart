import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/parking_place.dart';
import 'parkingAddModerator.dart';
import 'package:intl/intl.dart';

class ManageParkingPlaces extends StatefulWidget {
    final String userEmail; // Add userEmail variable to the class

  // Constructor to receive the email
  const ManageParkingPlaces({super.key, required this.userEmail});
  @override
  _ManageParkingPlacesState createState() => _ManageParkingPlacesState();
}

class _ManageParkingPlacesState extends State<ManageParkingPlaces>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  List<ParkingPlace> parkingPlaces = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchParkingPlaces();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch parking places
  Future<void> fetchParkingPlaces() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<ParkingPlace> fetchedPlaces =
          await _firestoreService.getParkingPlaces();
      setState(() {
        parkingPlaces = fetchedPlaces;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching parking places: $e')),
      );
    }
  }

  // Delete a parking place
  Future<void> deleteParkingPlace(String id) async {
    try {
      await _firestoreService.deleteParkingPlace(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking place deleted successfully!')),
      );
      fetchParkingPlaces();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting parking place: $e')),
      );
    }
  }

  // Navigate to Add/Update parking place
  void navigateToUpdate(ParkingPlace? place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddParkingPlace(parkingPlace: place),
      ),
    ).then((_) => fetchParkingPlaces());
  }

  // Build parking places tab
  Widget buildParkingPlacesTab() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : parkingPlaces.isEmpty
            ? const Center(
                child: Text(
                  'No parking places found!',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: parkingPlaces.length,
                itemBuilder: (context, index) {
                  final place = parkingPlaces[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Available Spots: ${place.availableSpots}"),
                          Text("Status: ${place.status}"),
                          Text("Type: ${place.type}"),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => navigateToUpdate(place),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                child: const Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () => deleteParkingPlace(place.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }

// Build reservations tab
Widget buildReservationsTab() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: _firestoreService.getAllReservations(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(
          child: Text(
            'No reservations found!',
            style: TextStyle(fontSize: 18),
          ),
        );
      }

      final reservations = snapshot.data!;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];

          // Extract reservation data with null checks
          final parkingPlaceName = reservation['parkingPlaceName'] ?? 'Unknown Parking Place';
          final parkingPlaceId = reservation['parkingPlaceId'] ?? '';
          final reservationId = reservation['reservationId'] ?? '';
          final registrationNumber = reservation['registrationNumber'] ?? 'Unknown';
          final lengthOfStay = reservation['lengthOfStay']?.toString() ?? 'Unknown';
          final timestamp = reservation['timestamp'] as Timestamp?;
          final userEmail = reservation['userEmail'] ?? 'Unknown User';
          final userName = reservation['userName'];

          // Format the timestamp to a readable date
          String formattedDate = timestamp != null
              ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate())
              : 'Unknown Date';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    parkingPlaceName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
//                   IconButton(
//   icon: const Icon(Icons.cancel, color: Colors.red),
//   onPressed: () async {
//     if (reservationId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid reservation data!')),
//       );
//       return;
//     }

//     try {
//       // Assuming cancelReservation only needs reservationId
//       await _firestoreService.cancelReservation(parkingPlaceId , reservationId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Reservation cancelled successfully!')),
//       );
//       setState(() {});  // Refresh the UI after cancellation
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error cancelling reservation: $e')),
//       );
//     }
//   },
// )

                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registration No: $registrationNumber'),
                  Text('Stay Duration: $lengthOfStay hours'),
                  Text('User Email: $userEmail'),
                  Text('Reservation Date: $formattedDate'),
                  Text('User Name: $userName')
                ],
              ),
            ),
          );
        },
      );
    },
  );
}



  // Build complaints tab
  Widget buildComplaintsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>( 
      stream: _firestoreService.streamComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No complaints found!',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        final complaints = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            final timestamp = complaint['timestamp'] as Timestamp;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        complaint['complaintText'] ?? 'No message',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _firestoreService.deleteComplaint(complaint['id']);
                      },
                    ),
                  ],
                ),
                subtitle: Text(
                  'Date: ${DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch)}',
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Parking Places'),
            Tab(text: 'Reservations'),
            Tab(text: 'Complaints'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildParkingPlacesTab(),
          buildReservationsTab(),
          buildComplaintsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => navigateToUpdate(null),
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.add),
            )
          : null, // Only show FAB for Parking Places
    );
  }
}
