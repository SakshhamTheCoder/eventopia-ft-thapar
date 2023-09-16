import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/components/chat_bubble.dart';
import '/services/chat_service.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;
  const ChatPage(
      {super.key, required this.receiverEmail, required this.receiverId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();
  ChatService _chatService = ChatService();
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.receiverEmail),
        titleTextStyle: const TextStyle(fontSize: 20.0),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40),
                bottomLeft: Radius.circular(40))),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput()
        ],
      ),
    );
  }

  void sendMessage() async {
    if (_messageController.value.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverId, _messageController.value.text);
      _messageController.clear();
    }
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _auth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    var color = (data['senderId'] == _auth.currentUser!.uid)
        ? Theme.of(context).colorScheme.onInverseSurface
        : Theme.of(context).colorScheme.primaryContainer;
    var time = data['timestamp'] as Timestamp;
    var dateString = DateFormat('MMM d, y - H:mm').format(time.toDate());
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: data['senderId'] == _auth.currentUser!.uid
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisAlignment: data['senderId'] == _auth.currentUser!.uid
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(data['senderEmail'] == _auth.currentUser!.email.toString()
                  ? "You · $dateString"
                  : data['senderEmail'].toString().split("@").first +
                      " · $dateString"),
              SizedBox(height: 5),
              ChatBubble(
                message: data['message'],
                color: color,
              ),
            ]),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream:
          _chatService.getMessage(widget.receiverId, _auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            decoration: const InputDecoration(
                hintText: "Send a Message", border: OutlineInputBorder()),
            keyboardType: TextInputType.text,
            controller: _messageController,
          )),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
          IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send,
                size: 30,
              ))
        ],
      ),
    );
  }
}
