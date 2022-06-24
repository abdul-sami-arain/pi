import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login_signup/utils/exports.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_signup/views/login_signup/forgotPassword.dart';
import 'package:login_signup/views/test.dart';
import 'package:url_launcher/url_launcher.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    "id", "name", "description",
    importance: Importance.high, playSound: true);
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("bg mess : ${message.messageId}");
}

class AdminPage extends StatefulWidget {
  final String username;
  final String designation;
  final String email;
  final String course;
  final uuid;
  AdminPage({
    Key? key,
    required this.username,
    required this.designation,
    required this.email,
    required this.course,
    required this.uuid,
  }) : super(key: key);
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController lecture_no = TextEditingController();
  final TextEditingController link = TextEditingController();
  final TextEditingController edit_link = TextEditingController();

  final TextEditingController lecture_title = TextEditingController();
  final TextEditingController lecture_description = TextEditingController();
  // final TextEditingController lecture_instructor = TextEditingController();
  void initState() {
    // TODO: implement initState
    FirebaseMessaging.instance.getInitialMessage();
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification.android;

      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.body,
            notification.title,
            NotificationDetails(
                android: AndroidNotificationDetails(
                    channel.id, channel.name, channel.description,
                    color: Colors.blue,
                    playSound: true,
                    icon: '@mipmap/ic_launcher')));
        print(message.notification.body);
        print(message.notification.title);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("object");
      RemoteNotification notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title),
                content: SingleChildScrollView(
                  child: Column(
                    children: [Text(notification.body)],
                  ),
                ),
              );
            });
      }
      final routeFromMessage = message.data["route"];
      Navigator.of(context).pushNamed(routeFromMessage);
    });
  }

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add Video Lecture"),
              titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20),
              actionsOverflowButtonSpacing: 20,
              actions: [
                ElevatedButton(
                    onPressed: () {
                      upload();
                      Navigator.of(context).pop();
                    },
                    child: Text("Add"))
              ],
              content: SingleChildScrollView(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextField(
                        controller: lecture_no,
                        decoration: InputDecoration(hintText: "Lecture No")),
                    TextField(
                      controller: link,
                      decoration: InputDecoration(hintText: "Lecture Link"),
                    ),
                    TextField(
                        controller: lecture_title,
                        decoration: InputDecoration(hintText: "Lecture Title")),
                    TextField(
                        controller: lecture_description,
                        decoration:
                            InputDecoration(hintText: "Lecture Description")),
                    // TextField(
                    //     controller: lecture_instructor,
                    //     decoration:
                    //         InputDecoration(hintText: "Instructor Name")),
                  ],
                ),
              ),
            ));
  }

  void upload() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DatabaseReference rdb = FirebaseDatabase.instance.reference();
    String Key = rdb.child('lect').push().key;

    try {
      db.collection("lectures").doc().set({
        "title": lecture_title.text,
        "description": lecture_description.text,
        "Lecture Link": link.text,
        "instructor": widget.username,
        "lecture no": lecture_no.text,
      });
      rdb.child('lect').child(Key).set({
        "title": lecture_title.text,
        "description": lecture_description.text,
        "Lecture Link": link.text,
        "instructor": widget.username,
        "lecture no": lecture_no.text,
        "Key": Key,
      });
      print("done");
      _flutterLocalNotificationsPlugin.show(
          0,
          "Update",
          "${widget.username} uploaded a video of ${lecture_description.text}",
          NotificationDetails(
              android: AndroidNotificationDetails(
                  channel.id, channel.name, channel.description,
                  importance: Importance.high,
                  color: Colors.blue,
                  playSound: true,
                  icon: '@mipmap/ic_launcher')));
    } catch (e) {
      print(e);
    }
  }

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
                txt: "Admin Dashboard",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                )),
            centerTitle: true,
          ),
          body: PageStorage(bucket: PageStorageBucket(), child: currentScreen),
          bottomNavigationBar: BottomAppBar(
            // notchMargin: 50,
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
                          showAlert(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: Color.fromRGBO(254, 254, 254, 1),
                          child: GlowIcon(
                            Icons.add,
                            color: Color.fromRGBO(43, 87, 154, 1),
                            size: 34,
                          ),
                          radius: 50,
                        )),
                    MaterialButton(
                      minWidth: 60,
                      onPressed: () {
                        setState(() {
                          currentScreen = Screen3(
                            usrnme: widget.username,
                          );
                          currentTab = 2;
                        });
                      },
                      child: Icon(
                          currentTab == 2 ? Icons.chat : Icons.chat_outlined,
                          color: Color.fromRGBO(254, 254, 254, 1)),
                    )
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
  const Screen1({
    Key? key,
  }) : super(key: key);

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  final TextEditingController lecture_no = TextEditingController();
  final TextEditingController link = TextEditingController();
  final TextEditingController del_lecture_no = TextEditingController();
  final TextEditingController lecture_title = TextEditingController();
  final TextEditingController lecture_description = TextEditingController();
  var _ref;
  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance.reference().child('lect');
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection('lectures').snapshots();

    Widget _lectures({required Map lect}) {
      return new Flexible(
          child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                      title: Text(lect['title']),
                      subtitle: GestureDetector(
                        child: Text(
                          lect['Lecture Link'],
                          style:
                              TextStyle(color: Color.fromRGBO(43, 87, 154, 1)),
                        ),
                        onTap: () async {
                          final url = lect['Lecture Link'].toString();
                          if (await canLaunch(url)) {
                            await launch(url,
                                forceSafariVC: true, enableJavaScript: true);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete,
                            color: Color.fromRGBO(43, 87, 154, 1)),
                        onPressed: () {
                          link.text = lect['Lecture Link'];
                          lecture_title.text = lect['title'];
                          lecture_description.text = lect['description'];
                          lecture_no.text = lect['lecture no'];
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text("Delete Items"),
                                    titleTextStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 20),
                                    actionsOverflowButtonSpacing: 20,
                                    actions: [
                                      ElevatedButton(
                                          style: ButtonStyle(),
                                          onPressed: () {
                                            FirebaseDatabase.instance
                                                .reference()
                                                .child('lect')
                                                .child(lect['Key'].toString())
                                                .remove();
                                                Navigator.of(context).pop();
                                          },
                                          child: Text("Delete"))
                                    ],
                                    content: SingleChildScrollView(
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          TextField(
                                              controller: lecture_no,
                                              decoration: InputDecoration(
                                                  hintText: "Lecture No")),
                                          TextField(
                                            controller: link,
                                            decoration: InputDecoration(
                                                hintText: "Lecture Link"),
                                          ),
                                          TextField(
                                              controller: lecture_title,
                                              decoration: InputDecoration(
                                                  hintText: "Lecture Title")),
                                          TextField(
                                              controller: lecture_description,
                                              decoration: InputDecoration(
                                                  hintText:
                                                      "Lecture Description")),
                                        ],
                                      ),
                                    ),
                                  ));
                        },
                      )),
                ),
              ),
            ],
          ),
        ),
        //
      ));
    }

    return new Column(children: [
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
      new Flexible(
        child: new FirebaseAnimatedList(
            query: _ref,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              Map lect = snapshot.value;
              return _lectures(lect: lect);
            }),
      ),
    ]);

    // StreamBuilder<QuerySnapshot>(
    //   stream: _usersStream,
    //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //     if (snapshot.hasError) {
    //       return Text('Something went wrong');
    //     }

    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Text("Loading");
    //     }
    //     return Column(
    //       children: [
    //         SizedBox(height: 20.h),
    //         Container(
    //           child: GlowText(
    //             "Lectures Videos",
    //             glowColor: Color.fromRGBO(43, 87, 154, 1),
    //             style: TextStyle(
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 20.sp,
    //                 color: Colors.white,
    //                 letterSpacing: 2),
    //           ),
    //         ),
    //         Expanded(
    //           child: ListView.builder(
    //               itemCount: snapshot.data!.docs.length,
    //               itemBuilder: (context, index) {
    //                 var doc = snapshot.data!.docs[index];
    //                 return Padding(
    //                   padding: EdgeInsets.symmetric(
    //                       horizontal: 20.w, vertical: 10.h),
    //                   child: Container(
    //                     decoration: BoxDecoration(
    //                         color: Colors.white,
    //                         borderRadius: BorderRadius.circular(10)),
    //                     child: ListTile(
    //                         title: GestureDetector(
    //                           child: Text(
    //                             doc['Lecture Link'],
    //                             style: TextStyle(
    //                                 // color:Color.fromRGBO(251, 170, 4, 1)
    //                                 color: Colors.blue),
    //                           ),
    //                           onTap: () async {
    //                             final url = doc['Lecture Link'].toString();
    //                             if (await canLaunch(url)) {
    //                               await launch(url,
    //                                   forceSafariVC: true,
    //                                   enableJavaScript: true);
    //                             } else {
    //                               throw 'Could not launch $url';
    //                             }
    //                           },
    //                         ),
    //                         subtitle: Text(
    //                           doc['title'],
    //                           style: TextStyle(
    //                               color: Color.fromRGBO(251, 170, 4, 1)),
    //                         ),
    //                         trailing: IconButton(
    //                           icon: Icon(Icons.delete,
    //                               color: Color.fromRGBO(43, 87, 154, 1)),
    //                           onPressed: () {
    //                             link.text = doc['Lecture Link'];
    //                             lecture_title.text = doc['title'];
    //                             lecture_description.text = doc['description'];
    //                             lecture_no.text = doc['lecture no'];
    //                             showDialog(
    //                                 context: context,
    //                                 builder: (context) => AlertDialog(
    //                                       title: Text("Delete Item"),
    //                                       titleTextStyle: TextStyle(
    //                                           fontWeight: FontWeight.bold,
    //                                           color: Colors.black,
    //                                           fontSize: 20),
    //                                       actionsOverflowButtonSpacing: 20,
    //                                       actions: [
    //                                         ElevatedButton(
    //                                             style: ButtonStyle(),
    //                                             onPressed: () {
    //                                               snapshot.data!.docs[index]
    //                                                   .reference
    //                                                   .delete();
    //                                               Navigator.of(context).pop();
    //                                             },
    //                                             child: Text("Delete"))
    //                                       ],
    //                                       content: SingleChildScrollView(
    //                                         child: ListView(
    //                                           shrinkWrap: true,
    //                                           children: [
    //                                             TextField(
    //                                                 controller: lecture_no,
    //                                                 decoration: InputDecoration(
    //                                                     hintText:
    //                                                         "Lecture No")),
    //                                             TextField(
    //                                               controller: link,
    //                                               decoration: InputDecoration(
    //                                                   hintText: "Lecture Link"),
    //                                             ),
    //                                             TextField(
    //                                                 controller: lecture_title,
    //                                                 decoration: InputDecoration(
    //                                                     hintText:
    //                                                         "Lecture Title")),
    //                                             TextField(
    //                                                 controller:
    //                                                     lecture_description,
    //                                                 decoration: InputDecoration(
    //                                                     hintText:
    //                                                         "Lecture Description")),
    //                                             // TextField(
    //                                             //     controller: lecture_instructor,
    //                                             //     decoration:
    //                                             //         InputDecoration(hintText: "Instructor Name")),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     ));
    //                           },
    //                         )),
    //                   ),
    //                 );
    //               }),
    //         ),
    //          InkWell(
    //                             child: SignUpContainer(st: "Done"),
    //                             onTap: () {
    //                               Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => Test()),
    //   );
    //                             },
    //                           ),
    //       ],
    //     );
    //   },
    // );
  }
}

class Screen2 extends StatefulWidget {
  const Screen2({Key? key}) : super(key: key);

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Screen3 extends StatefulWidget {
  final String usrnme;
  const Screen3({Key? key, required this.usrnme}) : super(key: key);

  @override
  _Screen3State createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
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
