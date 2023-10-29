import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:giga_share/models/thirdpartyuserdata.dart';
import 'package:giga_share/resources/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class UserScreen extends StatefulWidget {
  final String uid;
  const UserScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool isSubscribed = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final infuraUrl =
      'https://mainnet.infura.io/v3/66596c9f1de548549df5d5702b28eb1f'; // Replace with your Infura API key
  final ethereumAddress = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';

  @override
  void initState() {
    super.initState();
    _checkSubscription();
    _fetchUserData();
    // Create a WebSocket channel

    // Fetch Ethereum account balance
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    final data = {
      'jsonrpc': '2.0',
      'method': 'eth_getBalance',
      'params': [ethereumAddress, 'latest'],
      'id': 1,
    };
    final response = await http.post(
      Uri.parse(infuraUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    // Replace with your Ethereum wallet address
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final balanceInWeiHex = responseData['result'];
      final balanceInWei = BigInt.parse(balanceInWeiHex);
      final balanceInEther = balanceInWei / BigInt.from(10).pow(18);

      print('Ethereum Address: $ethereumAddress');
      print('Balance: ${balanceInEther.toStringAsFixed(6)} ether');
    } else {
      print(
          'Failed to fetch balance. HTTP Status Code: ${response.statusCode}');
    }
  }

  UserData? userdata;
  bool isUserSubscribed = false;

  Future<void> _fetchUserData() async {
    DatabaseReference dataLinkRef =
        FirebaseDatabase.instance.reference().child('users').child(widget.uid);
    DatabaseEvent event = await dataLinkRef.once();

    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value != null) {
      final userDataMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final userData = UserData.fromMap(userDataMap);
      setState(() {
        this.userdata = userData;
      });
    }
  }

  Future<void> _checkSubscription() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      DatabaseReference subscribedUsersRef = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(widget.uid)
          .child('subscribedUsers');

      DatabaseEvent event = await subscribedUsersRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> subscribedUsers =
            Map<dynamic, dynamic>.from(snapshot.value as Map);
        if (subscribedUsers.containsKey(user.uid)) {
          print("yes subscribed");
          setState(() {
            isUserSubscribed = true;
          });
        }
      }
    }
  }

  Future<void> subscribeUser() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      DatabaseReference subscribedUsersRef = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(widget.uid)
          .child('subscribedUsers');

      // Check if the user is already subscribed, if not, subscribe
      if (!isUserSubscribed) {
        await subscribedUsersRef.child(user.uid).set(true);

        setState(() {
          isUserSubscribed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.appColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.appColor,
        elevation: 1,
        centerTitle: true,
        title: Text(
          "${userdata?.fullname ?? 'Profile'}",
          style: TextStyle(
            letterSpacing: 1.2,
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: userdata != null
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(userdata!.profileImage),
                    ),
                  ),
                  Text(
                    '${userdata!.fullname.toUpperCase()}',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  isUserSubscribed
                      ? Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemCount: userdata!.myposts.length,
                            itemBuilder: (context, index) {
                              final entry =
                                  userdata!.myposts.entries.elementAt(index);
                              return Card(
                                child: Image.network(
                                  entry.value,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        )
                      : Column(
                          children: [
                            SizedBox(
                              height: 50,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(300, 70)),
                              onPressed: () {
                                subscribeUser();
                              },
                              child: Text(
                                'Subscribe to View More',
                                style: GoogleFonts.inter(fontSize: 20),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                //subscribeUser();
                                fetchBalance();
                              },
                              child: Lottie.asset(
                                "assets/lottie/subscribe.json",
                                height: 400,
                              ),
                            )
                          ],
                        ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
