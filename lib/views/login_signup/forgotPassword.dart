import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login_signup/utils/exports.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_signup/views/login_signup/forgotPassword.dart';

class ForgotPassword extends StatefulWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController userEmail = TextEditingController();
  void Reset() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await auth.sendPasswordResetEmail(email: userEmail.text.trim());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Alert!!"),
            content: new Text("Check Your Email and Reset Password"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "$e",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(43, 87, 154, 1),
          title: GlowText(
                      "Reset Password",
                      glowColor: Colors.white,
                      style: TextStyle(  
                          fontWeight: FontWeight.bold,
                          fontSize: 26.sp,
                          color: Colors.white,
                           letterSpacing: 1
                      ),
                    ),
          centerTitle: true,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Scaffold(
            backgroundColor: Color.fromRGBO(243, 243, 243, 1),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 20),
                        CustomTextField(
                            Lone: "Email",
                            Htwo: "Email",
                            obs: false,
                            Controller: userEmail),
                        const SizedBox(height: 20),

                        InkWell(
                          child: SignUpContainer(st: "Reset Password"),
                          onTap: () {
                            Reset();
                          },
                        ),

                        //Text("data"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
