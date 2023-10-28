import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:giga_share/models/post/postmodel.dart';
import 'package:giga_share/resources/color_constants.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class MintingScreen extends StatefulWidget {
  @override
  State<MintingScreen> createState() => _MintingScreenState();
}

class _MintingScreenState extends State<MintingScreen> {
  List<QRData> qrDataList = [];

  @override
  void initState() {
    super.initState();
    fetchQRData();
  }

  Future<void> fetchQRData() async {
    DatabaseReference dataLinkRef =
        FirebaseDatabase.instance.reference().child('dataLink');
    DatabaseEvent event = await dataLinkRef.once();

    DataSnapshot snapshot = event.snapshot;

    qrDataList.clear();
    if (snapshot.value != null) {
      Map<dynamic, dynamic> values =
          Map<dynamic, dynamic>.from(snapshot.value as Map);
      values.forEach((key, value) {
        qrDataList.add(QRData(value.toString()));
      });
    }
    setState(() {});
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.appColor, // Change the background color
      appBar: AppBar(
        backgroundColor: ColorConstants.appColor, // Change the app bar color
        title: Text(
          'QR Data List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: qrDataList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5, // Add some elevation for a card-like effect
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                      future: loadImage(qrDataList[index].url),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(qrDataList[index].url,
                                    scale: 1.0),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Image.network(
                              qrDataList[index].url,
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Currently we support only images! But still you can view it in browser...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Lottie.asset("assets/lottie/error.json",
                                        height: 200)
                                  ],
                                );
                              },
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error loading image'),
                          );
                        } else {
                          return Center(
                            child: Lottie.asset("assets/lottie/loading.json"),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Redirect to a web browser (Chrome) with the URL
                          // You may want to use the url_launcher package for this
                          // Add the appropriate URL launching code here
                        },
                        child: Text('Open in Browser'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> loadImage(String url) async {
    // You can add any custom logic for image loading here.
    // This can be an HTTP request, decoding an image, etc.
    // For this example, we're using Future.delayed to simulate loading.
    await Future.delayed(Duration(seconds: 2));
  }
}
