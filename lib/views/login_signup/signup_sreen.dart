import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login_signup/utils/exports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _value = false;
  final TextEditingController userEmail = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController username = TextEditingController();

  void Signup() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseDatabase rdb = FirebaseDatabase.instance;
    try {
      setState(() {
        loading = true;
      });
      final UserCredential user = await auth.createUserWithEmailAndPassword(
          email: userEmail.text, password: password.text);
      print("Registered1");
      db.collection("users").doc(user.user!.uid).set(
          {"username": username.text, "email": userEmail.text, "page": "user"});
      

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      print("Registered");
      setState(() {
        loading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "$e",
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
            "Sign up",
            
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26.sp,
                color: Colors.white,
                letterSpacing: 2),
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
                            Lone: "Username",
                            Htwo: "Username",
                            obs: false,
                            Controller: username),
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

                        loading
                            ? CircularProgressIndicator()
                            : InkWell(
                                child: SignUpContainer(st: "Sign Up"),
                                onTap: () {
                                  Signup();
                                },
                              ),
                        const SizedBox(
                          height: 50,
                        ),
                        InkWell(
                          child: RichText(
                            text: RichTextSpan(
                                one: "Already have an account ? ",
                                two: "Login"),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginScreen()));
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
