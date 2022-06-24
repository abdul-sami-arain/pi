import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:login_signup/utils/exports.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_signup/views/login_signup/forgotPassword.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentPage extends StatefulWidget {
  final String username;
  final String designation;
  final String email;
  const StudentPage({
    Key? key,
    required this.username,
    required this.designation,
    required this.email,
  }) : super(key: key);

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  int currentTab = 0;

  Widget currentScreen = Screen1();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color.fromRGBO(243, 243, 243, 1),
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(43, 87, 154, 1),
            title: customText(
                txt: widget.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                )),
            centerTitle: true,
          ),
          body: PageStorage(bucket: PageStorageBucket(), child: currentScreen),
          bottomNavigationBar: BottomAppBar(
            color: Color.fromRGBO(43, 87, 154, 1),
            child: Container(
              height: 60,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    MaterialButton(
                        minWidth: 50,
                        onPressed: () {
                          setState(() {
                            currentScreen = Screen1();
                            currentTab = 0;
                          });
                        },
                        child: Icon(
                            currentTab == 0 ? Icons.home : Icons.home_outlined,
                            color: Color.fromRGBO(254, 254, 254, 1))),
                    MaterialButton(
                      minWidth: 60,
                      onPressed: () {
                        setState(() {
                          currentScreen = Screen2(
                            usrnme: widget.username,
                          );
                          currentTab = 1;
                        });
                      },
                      child: Icon(
                          currentTab == 1 ? Icons.chat : Icons.chat_outlined,
                          color: Color.fromRGBO(254, 254, 254, 1)),
                    ),
                  ]),
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(43, 87, 154, 1),
                  ),
                  accountName: Text(widget.username),
                  accountEmail: Text(widget.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      "${widget.username[0].toUpperCase().toString()}",
                      style: TextStyle(
                        fontSize: 40.0,
                        color: Color.fromRGBO(43, 87, 154, 1),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Color.fromRGBO(43, 87, 154, 1),
                  ),
                  title: Text(
                    "Logout",
                    style: TextStyle(
                      color: Color.fromRGBO(43, 87, 154, 1),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

class Screen1 extends StatefulWidget {
  const Screen1({Key? key}) : super(key: key);

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  late final _ref;
  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance.reference().child('lect');
  }

  Widget _lectures({required Map lect}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          title: Text(
            lect['title'],
            style: TextStyle(color: Color.fromRGBO(43, 87, 154, 1)),
          ),
          subtitle: Text(lect['description']),
          trailing: IconButton(
            icon: Icon(Icons.arrow_forward,
                color: Color.fromRGBO(43, 87, 154, 1)),
            onPressed: () async {
              final url = lect['Lecture Link'].toString();
              if (await canLaunch(url)) {
                await launch(url, forceSafariVC: true, enableJavaScript: true);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Container(
              child: GlowText(
                "Lectures Videos",
                glowColor: Color.fromRGBO(43, 87, 154, 1),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Colors.white,
                    letterSpacing: 2),
              ),
            ),
            Container(
              child: new Flexible(
                child: new FirebaseAnimatedList(
                    query: _ref,
                    itemBuilder: (BuildContext context, DataSnapshot snapshot,
                        Animation<double> animation, int index) {
                      Map lect = snapshot.value;
                      return _lectures(lect: lect);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Screen2 extends StatefulWidget {
  final String usrnme;
  Screen2({Key? key, required this.usrnme}) : super(key: key);

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  final TextEditingController chat = TextEditingController();
  @override
  Widget build(BuildContext context) {
    void Send() async {
      FirebaseFirestore db = FirebaseFirestore.instance;

      try {
        db.collection("Messages").doc().set({
          "name": widget.usrnme,
          "message": chat.text,
        });
        print("done");
        chat.clear();
      } catch (e) {
        print(e);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Container(
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Container(
                child: GlowText(
                  "Messages",
                  glowColor: Color.fromRGBO(43, 87, 154, 1),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                      color: Colors.white,
                      letterSpacing: 2),
                ),
              ),
            ),
            SizedBox(
              height: 500.h,
              child: ChattingScreen(
                usr: widget.usrnme,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                      Lone: "message",
                      Htwo: "message",
                      obs: false,
                      Controller: chat),
                ),
                SizedBox(
                  width: 20.w,
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(43, 87, 154, 1),
                  ),
                  child: GestureDetector(
                    child: Icon(Icons.send, color: Colors.white),
                    onTap: () {
                      Send();
                      chat.clear();
                    },
                  ),
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}

class ChattingScreen extends StatefulWidget {
  final String usr;
  const ChattingScreen({Key? key, required this.usr}) : super(key: key);

  @override
  _ChattingScreenState createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection('Messages').snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(43, 87, 154, 1),
                      borderRadius: BorderRadius.circular(10)),
                  // color: Colors.blue,
                  child: ListTile(
                    title: Text(
                      doc['message'],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      doc['name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: doc['name'] == widget.usr
                        ? IconButton(
                            onPressed: () {
                              snapshot.data!.docs[index].reference.delete();
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ))
                        : Icon(
                            Icons.abc,
                            color: Colors.white,
                          ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Text(
                        "${doc['name'][0].toUpperCase().toString()}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40.0,
                          color: Color.fromRGBO(43, 87, 154, 1),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}
