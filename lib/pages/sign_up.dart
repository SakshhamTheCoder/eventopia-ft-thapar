import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/pages/sign_in.dart';

import 'home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailCntr = TextEditingController();
  TextEditingController passwordCntr = TextEditingController();
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Eventopia"),
          titleTextStyle: const TextStyle(fontSize: 30.0),
          centerTitle: true,
          toolbarHeight: MediaQuery.of(context).size.height / 12,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40))),
        ),
        body: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width / 9),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                child: Text(
                  "Create account on Eventopia",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 35,
                      color: Theme.of(context).colorScheme.onBackground),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: "Email Address", border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  controller: emailCntr,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: TextField(
                  decoration: InputDecoration(
                      suffix: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          child: _showPassword
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off)),
                      labelText: "Password",
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.visiblePassword,
                  controller: passwordCntr,
                  obscureText: !_showPassword,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 50),
                child: ElevatedButton(
                  onPressed: () {
                    signUpFirebase(
                        emailCntr.value.text, passwordCntr.value.text);
                  },
                  child: const Text("Sign Up"),
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInPage()));
                  },
                  child: const Text("Already Registered? Sign In"),
                ),
              )
            ],
          )),
        ),
      ),
    );
  }

  void signUpFirebase(email, password) async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) {
        if (value.user != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(value.user!.uid)
              .set({'uid': value.user!.uid, 'email': email});
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text("Password is weak. Create a stronger password."),
                actions: [
                  TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              );
            });
      } else if (e.code == 'email-already-in-use') {
        print(
            'The account already exists for that email. Use Sign In to access account.');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(
                    "This Email Address is already associated with a different account."),
                actions: [
                  TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              );
            });
      }
    } catch (e) {
      print(e);
    }
  }
}
