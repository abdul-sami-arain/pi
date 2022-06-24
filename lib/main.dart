import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login_signup/utils/exports.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:login_signup/utils/green.dart';
import 'package:login_signup/utils/red.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    "id", "name", "description",
    importance: Importance.high, playSound: true);
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("bg mess : ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
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
                    color: Colors.blue, playSound: true,
                    icon: '@mipmap/ic_launcher'
                    )));
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
void _show(){
   _flutterLocalNotificationsPlugin.show(
                              0,
                               "assalamualikum",
                                "body",
                                 NotificationDetails(
                                  android: AndroidNotificationDetails(
                                    channel.id, 
                                    channel.name,
                                     channel.description,
                                     importance: Importance.high,
                                     color: Colors.blue,
                                     playSound: true,
                                     icon: '@mipmap/ic_launcher'
                                     )
                                 )
                                 );
}
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              child: Text("NOT RUNNING"),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return ScreenUtilInit(
              builder: (context, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: HomeScreen(),
                  routes: {
                    "red": (_) => RedPage(),
                    "green": (_) => GreenPage(),
                  },
                );
              },
              designSize: Size(360, 800));
        }
        return Container(
          child: Center(child: Text("NOT RUNNING")),
        );
      },
    );
  }
}
