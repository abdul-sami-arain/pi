import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login_signup/utils/exports.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_signup/views/admin.dart';
import 'package:login_signup/views/login_signup/forgotPassword.dart';
import 'package:login_signup/views/student.dart';

class LoginScreen extends StatefulWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userEmail = TextEditingController();
  final TextEditingController password = TextEditingController();

  void Login() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      setState(() {
        loading = true;
      });
      final UserCredential user = await auth.signInWithEmailAndPassword(
          email: userEmail.text, password: password.text);
      final DocumentSnapshot snapshot =
          await db.collection("users").doc(user.user!.uid).get();
      final data = snapshot.data();
      if (data['page'] == "admin") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => 
              AdminPage(
                    username: data["username"],
                    designation: data["page"],
                    email: data["email"],
                    course:data["course"],
                    uuid: user.user!.uid,
                  )
                  ),
        );
      } else if (data["page"] == "user") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StudentPage(
                    username: data["username"],
                    designation: data["page"],
                    email: data["email"],
                  )),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Alert!!"),
              content: new Text("Not Recongnize"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        setState(() {
        loading = false;
      });
      }
    } catch (e) {
      Fluttertoast.showToast (
      msg:"$e",
      
        toastLength: Toast.LENGTH_SHORT,
       );
      setState(() {
        loading = false;
      });
    }

    print(userEmail.text);
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
         title: Text(
                      "Log in",
                     
                      style: TextStyle(  
                          fontWeight: FontWeight.bold,
                          fontSize: 26.sp,
                          color: Colors.white,
                           letterSpacing: 2
                      ),
                    ),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(43, 87, 154, 1),
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
                        CustomTextField(
                            Lone: "Password",
                            Htwo: "Password",
                            obs: true,
                            Controller: password),
                        const SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                child: RichText(
                                  text: RichTextSpan(
                                      one: "Forgot password? ",
                                      two: "click here"),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ForgotPassword()));
                                },
                              ),
                            ]),
                        const SizedBox(height: 20),
                        loading
                            ? CircularProgressIndicator()
                            : InkWell(
                                child: SignUpContainer(st: "Log In"),
                                onTap: () {
                                  Login();
                                },
                              ),
                        const SizedBox(
                          height: 50,
                        ),
                        InkWell(
                          child: RichText(
                            text: RichTextSpan(
                                one: "Dont have an account ? ", two: "Sign Up"),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const SignupScreen()));
                          },
                        ),
                       
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
