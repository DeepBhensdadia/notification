import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasetosqflite/widget/custom_button.dart';
import 'package:firebasetosqflite/widget/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'database.dart';

class HomeScreen extends StatefulWidget {
  final String? uid;
  const HomeScreen({
    super.key,
    required this.uid,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController Namecontroller = TextEditingController();
  TextEditingController Emailcontroller = TextEditingController();
  File? profilepic;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;



  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool _isSyncing = false;
  final dbHelper = DatabaseHelper.instance;
  List<dynamic> asyncdata = [];
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(); // Initialize Firebase
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        syncDataToFirebase();
        _connectivityResult = result;
      });

      // if (result != ConnectivityResult.none && !_isSyncing) {
      //   syncDataToFirebase(); // Call the sync function when internet is available
      // }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> syncDataToFirebase() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      List<Map<String, dynamic>> localData = await dbHelper.queryAllRows();

      for (var data in asyncdata) {
        await _firestore.collection(widget.uid!).add({
          'name': data['name'],
          'email': data['email']
        });

        await asyncdata.remove(data['id']);
      }

      Fluttertoast.showToast(msg: 'Sync successful');
    } catch (e) {
      print('Error syncing data: $e');
      Fluttertoast.showToast(msg: 'Sync failed');
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  addData() async {
    String name = Namecontroller.text.trim();
    String Email = Emailcontroller.text.trim();

    if (name != '' || Email != '') {
      Map<String, dynamic> newuserdata = {
        'name': name,
        'email': Email,
        'profilepic': ""
      };
      if (_connectivityResult == ConnectivityResult.none) {
        Fluttertoast.showToast(msg: "internet not available");
        print("internet not available");
        Map<String, dynamic> dataEntry = {
          'name': name,
          'email': Email,
        };
        asyncdata.add(dataEntry);
        dbHelper.insert(name, Email, "");
      } else {
        _firestore.collection(widget.uid!).add(newuserdata);
        dbHelper.insert(name, Email, "");
      }

      log('new user saved');
    }
    Emailcontroller.clear();
    Namecontroller.clear();
    setState(() {
      profilepic = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {

          },
          icon: const Icon(Icons.read_more),
        ),
        centerTitle: true,
        title: const Text('Home'),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     logout();
          //   },
          //   icon: const Icon(Icons.exit_to_app),
          // )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),

          CustomTextField(
            controller: Namecontroller,
            name: 'name',
          ),
          CustomTextField(
            controller: Emailcontroller,
            name: 'Email',
          ),
          CustomButton(
            name: 'Create Account',
            onPressed: () async {
              context.loaderOverlay.show();
              await addData();
              context.loaderOverlay.hide();
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection(widget.uid!).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {

                if (snapshot.hasData && snapshot.data != null) {
                  return Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text("Firebase Data",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(

                              elevation: 5,
                              margin: EdgeInsets.zero,

                              child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                primary: false,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> newusers =
                                      snapshot.data!.docs[index].data()
                                          as Map<String, dynamic>;
                                  return ListTile(
                                    // leading: newusers['profilepic'] != null ? CircleAvatar(
                                    //     backgroundImage:
                                    //         NetworkImage(newusers['profilepic'])):SizedBox(),
                                    title: Text(newusers['name']),
                                    subtitle: Text(newusers['email']),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await _firestore
                                            .collection(widget.uid!)
                                            .doc(snapshot.data!.docs[index].id)
                                            .delete();
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Text("Local Storage Data",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              elevation: 5,
                              margin: EdgeInsets.zero,
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: dbHelper.queryAllRows(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    final List<Map<String, dynamic>> data = snapshot.data!;
                                    return ListView.builder(
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      primary: false,
                                      itemCount: data.length,
                                      itemBuilder: (context, index) {
                                        final item = data[index];
                                        return ListTile(
                                          title: Text(item['name']),
                                          subtitle: Text(item['email']),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () async {
                                              dbHelper.delete(item['name']);
                                              setState(() {

                                              });
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Text('no data!');
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}
