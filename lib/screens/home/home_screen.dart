// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, prefer_typing_uninitialized_variables, unnecessary_null_comparison, unnecessary_cast, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giga_share/models/user_model.dart';
import 'package:giga_share/resources/color_constants.dart';
import 'package:giga_share/screens/home/history_screen.dart';
import 'package:giga_share/upload/receive_screen.dart';
import 'package:giga_share/upload/upload_screen.dart';
import 'package:giga_share/widgets/boxes.dart';
import 'package:giga_share/widgets/custom_home_button.dart';
import 'package:giga_share/widgets/history_card.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getUserName = '';
  String getUserEmail = '';
  String getUserImage = '';
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    DatabaseReference userReference = FirebaseDatabase.instance
        .ref()
        .child('users/${_auth.currentUser!.uid}');

    final user = userReference.once().then((DatabaseEvent databaseEvent) {
      final value = databaseEvent.snapshot.value;

      setState(() {
        getUserName = (value as Map)['fullname'].toString();
        getUserImage = (value as Map)['profileImage'].toString();
        getUserEmail = (value as Map)['email'].toString();
      });

      loaded = true;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff010723),
      appBar: AppBar(
        backgroundColor: Color(0xff320482),
        elevation: 0,
        //centerTitle: true,
        title: Text(
          'Free Store',
          style: TextStyle(
            letterSpacing: 1.2,
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: kIsWeb ? 100 : 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(150)),
              color: Color(0xff320482),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello ${getUserName.toUpperCase()},',
                    style: TextStyle(
                      letterSpacing: 1.2,
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Utilize our free storage to the fullest. Dont forget to share your work as a Post.',
                    style: TextStyle(
                      letterSpacing: 1.2,
                      color: Color(0xffDBC1FC),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Container(
              height: 220,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomHomeButton(
                        color: Color(0xff7D5BA4).withOpacity(0.7),
                        icon: Icons.upload_file_rounded,
                        text: 'Upload',
                        onPressed: () {
                          Get.to(() => UploadScreen());
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    kIsWeb
                        ? SizedBox.shrink()
                        : Expanded(
                            child: CustomHomeButton(
                              color: Color(0xffAA46B9).withOpacity(0.5),
                              icon: Icons.get_app,
                              text: 'Receive',
                              onPressed: () {
                                Get.to(() => ReceiveScreen());
                              },
                            ),
                          ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: CustomHomeButton(
                        color: Color(0xff5333CC).withOpacity(0.5),
                        icon: Icons.share,
                        text: 'Invite',
                        onPressed: () {
                          Share.share(
                              'Download our application Box Share from the below link https://drive.google.com/drive/u/0/folders/1--lL9ObgQoVzc0zH7ezsM4U12e8-WRHK');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 25),
          kIsWeb
              ? SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 5,
                    bottom: 15,
                    right: 10,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(child: Container()),
                      InkWell(
                        onTap: () {
                          Get.to(() => HistoryScreen());
                        },
                        child: Icon(
                          Icons.navigate_next,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
          ValueListenableBuilder<Box<UserModel>>(
            valueListenable: Boxes.getTransactions().listenable(),
            builder: (context, box, _) {
              final transactions = box.values.toList().cast<UserModel>();
              return Expanded(
                child: HistoryCard(
                  transactions: transactions,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
