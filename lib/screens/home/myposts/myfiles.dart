import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:giga_share/models/post/postmodel.dart';
import 'package:giga_share/resources/color_constants.dart';
import 'package:giga_share/screens/home/myposts/videopage.dart';
import 'package:giga_share/widgets/custom_alert.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class MyPost extends StatefulWidget {
  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  //List<QRData> qrDataList = [];
  String downloadedFilePath = "";
  bool downloading = false;
  List<String> qrDataList = [];

  @override
  void initState() {
    super.initState();
    fetchQRData();
  }

  Future<void> fetchQRData() async {
    print("the function is called");
    final _auth = FirebaseAuth.instance;
    final currentUser = _auth.currentUser;
    print("the current usr is ${currentUser!.uid}");
    if (currentUser != null) {
      DatabaseReference dataLinkRef = FirebaseDatabase.instance
          .reference()
          .child('users/${currentUser.uid}/myposts');

      DatabaseEvent event = await dataLinkRef.once();

      DataSnapshot snapshot = event.snapshot;
      print("the snapshot is ${snapshot.value}");
      if (snapshot.value != null && snapshot.value is Map) {
        // Assuming that snapshot.value is a Map with keys and URLs.
        Map<dynamic, dynamic> dataMap =
            Map<dynamic, dynamic>.from(snapshot.value as Map);
        qrDataList.clear();
        dataMap.forEach((key, value) {
          if (value is String) {
            qrDataList.add(value);
          }
        });
      } else {
        print("Data format is not as expected");
      }

      print("the qr list is ${qrDataList}");
      setState(() {});
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          //backgroundColor: ColorConstants.appColor,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor:
                ColorConstants.appColor, // Change the app bar color
            title: Text(
              'My Files',
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
                          future: loadImage(qrDataList[index]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Card(
                                elevation: 0,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                    ),
                                    Image.network(
                                      qrDataList[index],
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Tap Me',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            CircleAvatar(
                                              radius: 100,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              VideoPage(
                                                                url: qrDataList[
                                                                    index],
                                                              )));
                                                },
                                                child: Lottie.asset(
                                                    "assets/lottie/play video.json",
                                                    height: 200),
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error loading image'),
                              );
                            } else {
                              return Center(
                                child:
                                    Lottie.asset("assets/lottie/loading.json"),
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
                              launch(qrDataList[index]); // Open in browser
                            },
                            child: Text('Open in Browser'),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              downloadFromIPFS(
                                  qrDataList[index],
                                  qrDataList[index]
                                      .hashCode); // Download the image
                            },
                            child: Text('Download'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (downloading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Future<void> downloadFromIPFS(String url, int cid) async {
    try {
      setState(() {
        downloading = true;
      });
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          downloading = false;
        });
        final downloadsDirectory =
            "/storage/emulated/0/Download"; // Specify the path to the downloads folder on Android
        final fileName = "${cid}.jpg"; // Specify the file name and extension
        final filePath = '$downloadsDirectory/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          downloadedFilePath = filePath;
        });
        showDialog(
          context: context,
          builder: (context) {
            return CustomAlertDialog(
              title: 'Download Successful',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('The content has been downloaded.'),
                  SizedBox(height: 10),
                  Text('Downloaded to: $downloadedFilePath'),
                ],
              ),
              onpressed: () {
                viewDownloadedContent();
              },
            );
          },
        );
      } else {
        setState(() {
          downloading = false;
        });
        showErrorDialog('Error Downloading', 'Failed to download the content.');
      }
    } catch (e) {
      setState(() {
        downloading = false;
      });
      showErrorDialog('Error', 'An error occurred while downloading.');
    }
  }

  void viewDownloadedContent() {
    if (downloadedFilePath.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Downloaded Content'),
            ),
            body: Center(
              child: Image.file(File(downloadedFilePath)),
            ),
          ),
        ),
      );
    }
  }

  Future<String> saveFile(Uint8List data) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/downloaded_content';
    final file = File(filePath);
    await file.writeAsBytes(data);
    return filePath;
  }

  Future<void> loadImage(String url) async {
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> launchDownload(String url) async {
    // Use the url_launcher package to open the URL for download
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
