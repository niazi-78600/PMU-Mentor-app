import 'package:flutter/material.dart';
import '../models/parking_place.dart';

class AddParkingPlace extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final ParkingPlace? parkingPlace;

  AddParkingPlace({super.key, this.parkingPlace});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController spotsController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Populate fields if editing
    if (parkingPlace != null) {
      nameController.text = parkingPlace!.name;
      spotsController.text = parkingPlace!.availableSpots.toString();
      statusController.text = parkingPlace!.status;
      typeController.text = parkingPlace!.type;
    }

    void saveParkingPlace() async {
      // Basic validation
      if (nameController.text.trim().isEmpty ||
          spotsController.text.trim().isEmpty ||
          statusController.text.trim().isEmpty ||
          typeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')),
        );
        return;
      }

      final availableSpots = int.tryParse(spotsController.text.trim());
      if (availableSpots == null || availableSpots < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid number for spots.')),
        );
        return;
      }

      final place = ParkingPlace(
        id: parkingPlace?.id ?? '', // Use existing ID for update or let Firestore auto-generate for new
        name: nameController.text.trim(),
        availableSpots: availableSpots,
        status: statusController.text.trim(),
        type: typeController.text.trim(),
      );

      try {
        await _firestoreService.addOrUpdateParkingPlace(place);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(parkingPlace == null
                ? 'Parking place added successfully!'
                : 'Parking place updated successfully!'),
          ),
        );
        Navigator.pop(context); // Go back after saving
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving parking place: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(parkingPlace == null ? 'Add Parking' : 'Update Parking'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Parking Name'),
            ),
            TextField(
              controller: spotsController,
              decoration: const InputDecoration(labelText: 'Available Spots'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: statusController,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveParkingPlace,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(parkingPlace == null ? 'Save' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
