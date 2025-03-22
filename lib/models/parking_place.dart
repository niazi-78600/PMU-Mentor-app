class ParkingPlace {
  final String id;
  final String name;
  final int availableSpots;
  final String status;
  final String type;

  ParkingPlace({
    required this.id,
    required this.name,
    required this.availableSpots,
    required this.status,
    required this.type,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'available_spots': availableSpots,
      'status': status,
      'type': type,
      'timestamp': DateTime.now(),
      
    };
  }

  // Create a ParkingPlace object from Firestore snapshot
  factory ParkingPlace.fromFirestore(Map<String, dynamic> data, String id) {
    return ParkingPlace(
      id: id,
      name: data['name'],
      availableSpots: data['available_spots'],
      status: data['status'],
      type: data['type'],
    );
  }
}
