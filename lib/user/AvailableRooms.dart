import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project1/user/roombooking.dart'; // Import RoomBookingPage

class AvailableRoomsPage extends StatelessWidget {
  final String hotelId;

  // Constructor to accept hotel ID
  const AvailableRoomsPage({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Available Rooms"),
      ),
      body: FutureBuilder<List<Room>>(
        future: _fetchAvailableRooms(hotelId), // Fetch rooms using hotelId
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No rooms available"));
          } else {
            List<Room> rooms = snapshot.data!;
            return SingleChildScrollView( // Wrap the ListView in SingleChildScrollView
              child: Column(
                children: rooms.map((room) {
                  return RoomTile(room: room, hotelId: hotelId); // Pass hotelId to RoomTile
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  // Fetch available rooms for a given hotelId from Firestore
  Future<List<Room>> _fetchAvailableRooms(String hotelId) async {
    try {
      // Query the Firestore rooms collection based on hotelId and isAvailable = true
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rooms') // Assuming you have a 'rooms' collection
          .where('hotelId', isEqualTo: hotelId) // Filter by hotelId
          .where('isAvailable', isEqualTo: true) // Filter by availability
          .get();

      List<Room> rooms = snapshot.docs.map((doc) {
        // Map Firestore document to Room object
        var data = doc.data() as Map<String, dynamic>;
        return Room(
          roomNumber: data['roomNumber'],
          acType: data['acType'],
          balconyAvailable: data['balconyAvailable'],
          bedType: data['bedType'],
          rent: data['rent'],
          isAvailable: data['isAvailable'],
          wifiAvailable: data['wifiAvailable'],
        );
      }).toList();

      return rooms;
    } catch (e) {
      print('Error fetching available rooms: $e');
      return [];
    }
  }
}

// Room model to represent a room
class Room {
  final int roomNumber;
  final String acType;
  final bool balconyAvailable;
  final String bedType;
  final double rent;
  final bool isAvailable;
  final bool wifiAvailable;

  Room({
    required this.roomNumber,
    required this.acType,
    required this.balconyAvailable,
    required this.bedType,
    required this.rent,
    required this.isAvailable,
    required this.wifiAvailable,
  });
}

// Widget to display a single room tile with expansion on tap
class RoomTile extends StatefulWidget {
  final Room room;
  final String hotelId; // To pass hotelId for booking

  const RoomTile({super.key, required this.room, required this.hotelId});

  @override
  _RoomTileState createState() => _RoomTileState();
}

class _RoomTileState extends State<RoomTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text('Room ${widget.room.roomNumber}'),
        subtitle: Text(widget.room.isAvailable ? 'Available' : 'Not Available'),
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
        ),
        onExpansionChanged: (bool expanding) {
          setState(() {
            _isExpanded = expanding;
          });
        },
        children: [
          ListTile(
            title: const Text('Room Details'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AC Type: ${widget.room.acType}'),
                Text('Balcony Available: ${widget.room.balconyAvailable ? 'Yes' : 'No'}'),
                Text('Bed Type: ${widget.room.bedType}'),
                Text('Rent: \$${widget.room.rent.toString()}'),
                Text('Wi-Fi Available: ${widget.room.wifiAvailable ? 'Yes' : 'No'}'),
              ],
            ),
          ),
          // Book Now button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to RoomBookingPage with room details and hotelId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomBookingPage(
                      hotelId: widget.hotelId,
                      roomNumber: widget.room.roomNumber,
                      rent: widget.room.rent,
                    ),
                  ),
                );
              },
              child: const Text("Book Now"),
            ),
          ),
        ],
      ),
    );
  }
}
