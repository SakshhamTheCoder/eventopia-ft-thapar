import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventopia_ft_thapar/pages/polls.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat.dart';
import 'sign_up.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("SabreChat"),
        titleTextStyle: const TextStyle(fontSize: 30.0),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40),
                bottomLeft: Radius.circular(40))),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.secondaryContainer)),
                  onPressed: () {
                    signOut();
                  },
                  child: const Text("Logout"),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.secondaryContainer)),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PollsPage()));
                  },
                  child: const Text("Polls"),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: _buildUserList()),
          ),
        ],
      ),
    );
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut().then((value) =>
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SignUpPage())));
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

    if (FirebaseAuth.instance.currentUser!.email != data['email']) {
      return ListTile(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(data['email']),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        receiverEmail: data['email'],
                        receiverId: data['uid'],
                      )));
        },
      );
    } else {
      return Container();
    }
  }
}
