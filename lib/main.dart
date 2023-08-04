import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
