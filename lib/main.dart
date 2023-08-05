import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'home_screen.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void getNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  debugPrint("MESSAGING TOKEN ${await messaging.getToken()}");
  print('User granted permission: ${settings.authorizationStatus}');
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  getNotificationPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await NotificationServices.initialize();

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
  //     .instance
  //     .collection("user")
  //     .doc('JuB0wflBg602f1MLE8pl')
  //     .get();
  // log(snapshot.data().toString());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlobalLoaderOverlay(
      useDefaultLoading: true,
      // ignore: prefer_const_constructors
      overlayWidget: Center(
        child: CircularProgressIndicator(),
      ),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomeScreen(uid: 'Deep',)
      ),
    );
  }
}
