import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/pages/home.dart';
import '/pages/sign_up.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailCntr = TextEditingController();
  TextEditingController emailCntr2 = TextEditingController();
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
                  "Welcome back to Eventopia",
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
                    signInFirebase(
                        emailCntr.value.text, passwordCntr.value.text);
                  },
                  child: const Text("Sign In"),
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary),
                ),
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Reset Password'),
                              content: TextField(
                                decoration: const InputDecoration(
                                    labelText: "Email Address",
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.emailAddress,
                                controller: emailCntr2,
                              ),
                              actions: [
                                TextButton(
                                    child: Text("Submit"),
                                    onPressed: () {
                                      FirebaseAuth.instance
                                          .sendPasswordResetEmail(
                                              email: emailCntr2.value.text)
                                          .then((value) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "Email Sent. Check inbox to proceed with password reset.",
                                          toastLength: Toast.LENGTH_LONG,
                                        );
                                      });
                                      Navigator.pop(context);
                                    })
                              ],
                            );
                          });
                    },
                    child: const Text("Forgot Password"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()));
                    },
                    child: const Text("New User? Sign Up"),
                  ),
                ],
              )
            ],
          )),
        ),
      ),
    );
  }

  void signInFirebase(email, password) async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) {
        if (value.user != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(value.user!.uid)
              .set({'uid': value.user!.uid, 'email': email},
                  SetOptions(merge: true));
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        }
      });
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text("No user found with this Email Address."),
                actions: [
                  TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              );
            });
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text("Wrong password. Try again."),
                actions: [
                  TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              );
            });
      } else if (e.code == 'too-many-requests') {
        print('Disabled');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(
                    "Login disabled due to too many wrong attempts. Try again later."),
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
