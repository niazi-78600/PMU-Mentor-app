// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:pmu/models/chat.dart';

// class ChatScreen extends StatefulWidget {
//   final String chatId;
//   final String mentorId;

//   const ChatScreen({
//     super.key,
//     required this.chatId,
//     required this.mentorId,
//   });

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     final messageText = _messageController.text.trim();
//     _messageController.clear();

//     final message = {
//       'senderId': widget.mentorId,
//       'text': messageText,
//       'timestamp': FieldValue.serverTimestamp(),
//     };

//     // Add the message to the messages sub-collection
//     final chatRef = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.chatId)
//         .collection('messages');

//     await chatRef.add(message);

//     // Update the main chat document with the last message
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.chatId)
//         .update({
//       'lastMessage': messageText,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat'),
//         backgroundColor: Colors.teal,
//       ),
//       body: Column(
//         children: [
//           // Message list
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .doc(widget.chatId)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final messages = snapshot.data!.docs.map((doc) {
//                   return Message.fromFirestore(doc.data() as Map<String, dynamic>);
//                 }).toList();

//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     final isMe = message.senderId == widget.mentorId;

//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 10.0, vertical: 5.0),
//                         padding: const EdgeInsets.all(10.0),
//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.teal : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Text(
//                           message.text,
//                           style: TextStyle(
//                               color: isMe ? Colors.white : Colors.black),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           // Message input
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.teal),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final User user;
  final String menteeId;  // You can pass menteeId here or get it dynamically based on the context.

  const ChatScreen({super.key, required this.user, required this.menteeId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    try {
      await _firestore.collection('chats').add({
        'senderId': widget.user.uid,
        'receiverId': widget.menteeId,  // Set Mentee ID
        'message': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();  // Clear text input
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Mentee'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('senderId', isEqualTo: widget.user.uid)
                  .where('receiverId', isEqualTo: widget.menteeId)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(
                      title: Text(message['message']),
                      subtitle: Text(message['timestamp'].toString()),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
