import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static Future<String> getOrCreateChat(String mentorId, String menteeId) async {
    final chatRef = FirebaseFirestore.instance.collection('chats');

    final existingChat = await chatRef
        .where('participants', arrayContains: mentorId)
        .where('participants', arrayContains: menteeId)
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) {
      return existingChat.docs.first.id;
    }

    final newChat = await chatRef.add({
      'participants': [mentorId, menteeId],
      'lastMessage': '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    return newChat.id;
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/parking_place.dart';

// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Add or update a parking place
//   Future<void> addOrUpdateParkingPlace(ParkingPlace place) async {
//     try {
//       if (place.id.isEmpty) {
//         // Add a new parking place
//         await _firestore.collection('parking_places').add(place.toJson());
//       } else {
//         // Update an existing parking place
//         await _firestore
//             .collection('parking_places')
//             .doc(place.id)
//             .update(place.toJson());
//       }
//     } catch (e) {
//       print('Error adding/updating parking place: $e');
//     }
//   }

//   // Stream parking places in real-time
//   Stream<List<ParkingPlace>> streamParkingPlaces() {
//     return _firestore
//         .collection('parking_places')
//         .orderBy('timestamp')
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => ParkingPlace.fromFirestore(doc.data(), doc.id))
//             .toList());
//   }

//   // Fetch parking places (one-time query)
//   Future<List<ParkingPlace>> getParkingPlaces() async {
//     try {
//       final snapshot = await _firestore.collection('parking_places').get();
//       return snapshot.docs.map((doc) {
//         return ParkingPlace.fromFirestore(doc.data(), doc.id);
//       }).toList();
//     } catch (e) {
//       print('Error fetching parking places: $e');
//       return [];
//     }
//   }

//   // Delete a parking place
//   Future<void> deleteParkingPlace(String id) async {
//     try {
//       await _firestore.collection('parking_places').doc(id).delete();
//     } catch (e) {
//       print('Error deleting parking place: $e');
//     }
//   }

//   // Reserve a parking place for the logged-in user
// Future<void> reserveParking(
//   String parkingPlaceId, 
//   String registrationNumber, 
//   int lengthOfStay, 
//   String userEmail // Add user email as a parameter
// ) async {
//   try {
//     final userId = FirebaseAuth.instance.currentUser?.uid;

//     if (userId == null) {
//       print('User is not logged in!');
//       return;
//     }

//     final reservation = {
//       'userId': userId,
//       'userEmail': userEmail, // Store the user's email
//       'registrationNumber': registrationNumber,
//       'lengthOfStay': lengthOfStay,
//       'timestamp': FieldValue.serverTimestamp(),
//     };

//     final reservationRef = await FirebaseFirestore.instance
//         .collection('parking_places')
//         .doc(parkingPlaceId)
//         .collection('reservations')
//         .add(reservation);

//     print('Reservation created successfully with ID: ${reservationRef.id}');
//   } catch (e) {
//     print('Error reserving parking place: $e');
//   }
// }

// Future<List<Map<String, dynamic>>> getUserReservations(String userId) async {
//   try {
//     // Get all parking places
//     final snapshot = await _firestore.collection('parking_places').get();

//     // List of futures to fetch reservations for each parking place
//     final futures = snapshot.docs.map((doc) async {
//       final parkingPlaceId = doc.id;

//       // Fetch reservations for this parking place and filter by userId
//       final subSnapshot = await _firestore
//           .collection('parking_places')
//           .doc(parkingPlaceId)
//           .collection('reservations')
//           .where('userId', isEqualTo: userId) // Filter by userId
//           .get();

//       // Map each reservation to include additional data (e.g., parking place name)
//       return subSnapshot.docs.map((subDoc) {
//         final data = subDoc.data();
//         final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(); // Get DateTime from timestamp

//         return {
//           'parkingPlaceId': parkingPlaceId,
//           'parkingPlaceName': doc.data()['name'], // Name of the parking place
//           'reservationId': subDoc.id, // Reservation ID
//           'lengthOfStay': data['lengthOfStay'], // Length of stay
//           'registrationNumber': data['registrationNumber'], // Registration number
//           'timestamp': timestamp, // Timestamp as DateTime object
//           'userEmail': data['userEmail'], // User email
//           'userId': data['userId'], // User ID#
          
//         };
//       }).toList();
//     }).toList();

//     // Wait for all futures to complete and flatten the list
//     final List<List<Map<String, dynamic>>> allReservations = await Future.wait(futures);
//     return allReservations.expand((x) => x).toList(); // Flatten the list of lists into a single list

//   } catch (e) {
//     print('Error fetching user reservations: $e');
//     return [];
//   }
// }
// void fetchAllReservations() async {
//   FirestoreService firestoreService = FirestoreService();
//   List<Map<String, dynamic>> reservations = await firestoreService.getAllReservations();

//   if (reservations.isEmpty) {
//     print('No reservations found.');
//   } else {
//     for (var reservation in reservations) {
//       print('Reservation ID: ${reservation['reservationId']}');
//       print('Parking Place: ${reservation['parkingPlaceName']}');
//       print('User Email: ${reservation['userEmail']}');
//       print('Length of Stay: ${reservation['lengthOfStay']}');
//       print('Registration Number: ${reservation['registrationNumber']}');
//       print('Timestamp: ${reservation['timestamp']}');
//     }
//   }
// }


//   // Cancel a reservation
//   Future<void> cancelReservation(String parkingPlaceId, String reservationId) async {
//     try {
//       // Assuming reservations are stored in a subcollection under parking places
//       await _firestore
//           .collection('parking_places') // Main collection
//           .doc(parkingPlaceId)         // Parking place document
//           .collection('reservations')  // Subcollection
//           .doc(reservationId)          // Specific reservation
//           .delete();                   // Delete the reservation
//     } catch (e) {
//       throw Exception('Failed to cancel reservation: $e');
//     }
//   }
//   // Add a complaint to the Firestore database
//   Future<void> addComplaint(String complaintText) async {
//     try {
//       final userId = FirebaseAuth.instance.currentUser?.uid;

//       if (userId == null) {
//         print('User is not logged in!');
//         return;
//       }

//       final complaint = {
//         'userId': userId,
//         'complaintText': complaintText,
//         'timestamp': FieldValue.serverTimestamp(),
//       };

//       // Add complaint to Firestore
//       await _firestore.collection('complaints').add(complaint);
//     } catch (e) {
//       print('Error adding complaint: $e');
//     }
//   }

//   // Stream complaints from Firestore
//   Stream<List<Map<String, dynamic>>> streamComplaints() {
//     return _firestore
//         .collection('complaints')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => {
//               'id': doc.id,
//               'complaintText': doc['complaintText'],
//               'timestamp': doc['timestamp'],
//             })
//             .toList());
//   }

//   // Delete a complaint from Firestore
//   Future<void> deleteComplaint(String complaintId) async {
//     try {
//       await _firestore.collection('complaints').doc(complaintId).delete();
//       print('Complaint deleted successfully');
//     } catch (e) {
//       print('Error deleting complaint: $e');
//     }
//   }
//   // Fetch all reservations with parking spot name, registration number, and user's name
// Future<List<Map<String, dynamic>>> getAllReservations() async {
//   try {
//     // Fetch all parking places
//     final parkingPlacesSnapshot = await _firestore.collection('parking_places').get();
    
//     List<Map<String, dynamic>> allReservations = [];

//     // Loop through each parking place
//     for (var parkingPlaceDoc in parkingPlacesSnapshot.docs) {
//       final parkingPlaceId = parkingPlaceDoc.id;
//       final parkingPlaceName = parkingPlaceDoc.data()['name'];

//       // Fetch all reservations for this parking place
//       final reservationsSnapshot = await _firestore
//           .collection('parking_places')
//           .doc(parkingPlaceId)
//           .collection('reservations')
//           .get();

//       // Loop through each reservation and fetch details
//       for (var reservationDoc in reservationsSnapshot.docs) {
//         final reservationData = reservationDoc.data();
//         final registrationNumber = reservationData['registrationNumber'];
//         final userId = reservationData['userId'];
//         final lengthOfStay = reservationData['lengthOfStay'];
//         final userEmail= reservationData['userEmail'];

//         // Fetch the user's name from the 'users' collection (your custom collection)
//         String userName = 'Unknown User'; // Default value
//         try {
//           if (userId != null) {
//             final userSnapshot = await _firestore.collection('users').doc(userId).get();
//             if (userSnapshot.exists) {
//               userName = userSnapshot.data()?['name'] ?? 'Unknown User';
//             }
//           }
//         } catch (e) {
//           print('Error fetching user name: $e');
//         }

//         // Add reservation data to the list
//         allReservations.add({
//           'parkingPlaceName': parkingPlaceName,
//           'registrationNumber': registrationNumber,
//           'userName': userName,
//           'reservationId': reservationDoc.id,
//           'timestamp': reservationData['timestamp'], // You can include the timestamp if needed
//           'lengthOfStay': lengthOfStay,
//           'userEmail':userEmail,
//         });
//       }
//     }

//     return allReservations;
//   } catch (e) {
//     print('Error fetching all reservations: $e');
//     return [];
//   }
// }

// }
