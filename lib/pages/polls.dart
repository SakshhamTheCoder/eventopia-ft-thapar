import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/components/chat_bubble.dart';
import '/services/chat_service.dart';
import 'package:intl/intl.dart';

class PollsPage extends StatefulWidget {
  const PollsPage({super.key});

  @override
  State<PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage> {
  TextEditingController _messageController = TextEditingController();
  ChatService _chatService = ChatService();
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: null,
        //   label: Text("Create Poll"),
        //   icon: Icon(Icons.add),
        // ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Current Polls"),
          titleTextStyle: const TextStyle(fontSize: 20.0),
          centerTitle: true,
          toolbarHeight: MediaQuery.of(context).size.height / 12,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40))),
        ),
        body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('poll').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data!.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    var myWid = snapshot.map((data) => _buildListItem(context, data)).toList();
    myWid.insert(
        0,
        Text(
          "POLL",
          textAlign: TextAlign.center,
        ));
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: myWid,
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
        key: ValueKey(record.name),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
              title: Text(record.name),
              trailing: Text(record.votes.toString()),
              onTap: () =>
                  record.reference.update({'votes': FieldValue.increment(1)})),
        ));
  }
}

class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(map, {required this.reference})
      : name = map['name'] ?? '',
        votes = map['votes'] ?? 0;

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>,
            reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}
