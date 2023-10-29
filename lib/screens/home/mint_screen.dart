import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:giga_share/models/post/postmodel.dart';
import 'package:giga_share/resources/color_constants.dart';
import 'package:giga_share/screens/home/myposts/videopage.dart';
import 'package:giga_share/screens/userscreen/userscreen.dart';
import 'package:giga_share/widgets/custom_alert.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class MintingScreen extends StatefulWidget {
  @override
  State<MintingScreen> createState() => _MintingScreenState();
}

class _MintingScreenState extends State<MintingScreen> {
  //List<QRData> qrDataList = [];
  String downloadedFilePath = "";
  bool downloading = false;
  List<QRData> qrDataList = [];
  @override
  void initState() {
    super.initState();
    fetchQRData();
  }

  Future<void> fetchQRData() async {
    print("the function is called");
    DatabaseReference dataLinkRef =
        FirebaseDatabase.instance.reference().child('dataLink');

    DatabaseEvent event = await dataLinkRef.once();

    DataSnapshot snapshot = event.snapshot;
    qrDataList.clear();

    if (snapshot.value != null) {
      Map<dynamic, dynamic> values =
          Map<dynamic, dynamic>.from(snapshot.value as Map);
      values.forEach((key, value) {
        if (value is Map) {
          String username = value['username'] ?? 'Unknown';
          String title = value['title'] ?? 'No Title';
          String caption = value['caption'] ?? 'No Caption';
          String url = value['url'].toString();
          String uid = value['userid'].toString();

          qrDataList.add(QRData(username, title, caption, url, uid));
        } else {
          print('Invalid data format: $value');
        }
      });
    }
    print("the qr list is ${qrDataList[0].title}");
    setState(() {});
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          //backgroundColor: ColorConstants.appColor,
          backgroundColor: Color(0xff010723).withOpacity(0.8),
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            toolbarHeight: kIsWeb ? 170 : 120,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(130),
              ),
            ),
            backgroundColor: Color(0xff320482),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'PUBLIC CONTENT,',
                      style: TextStyle(
                        letterSpacing: 1.2,
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Subscribe to your favourite\ncreators to download their content',
                  style: TextStyle(
                    letterSpacing: 1.2,
                    color: Color(0xffDBC1FC),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true, // Allow text to wrap to the next line
                ),
              ],
            ),
          ),

          body: ListView.separated(
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                color: Colors.white,
                height: 2,
              ),
            ),
            itemCount: qrDataList.length,
            itemBuilder: (context, index) {
              if (qrDataList.isNotEmpty && index < qrDataList.length) {
                final qrData = qrDataList[index];
                return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 5, // Add elevation for a 3D look
                      shadowColor: Color(0xff6B4DB2)
                          .withOpacity(0.8), // Color for the shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder(
                              future: loadImage(qrData.url),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: Colors
                                        .transparent, // Use your theme color
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserScreen(
                                                        uid: qrData.postedby),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors
                                                      .white, // Change this to your theme color
                                                  child: Center(
                                                    child: Text(
                                                      ' ${qrData.url[0].toUpperCase()}',
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                        color: ColorConstants
                                                            .appColor, // Use your theme color
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Wrap(
                                                      children: [
                                                        Text(
                                                          ' ${qrData.url.toUpperCase()}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color: Colors
                                                                .white, // Change this to your theme color
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(width: 18),
                                                    Wrap(
                                                      children: [
                                                        Text(
                                                          '${qrData.title[0].toUpperCase()}${qrData.title.substring(1)}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 20,
                                                            color: Colors
                                                                .white, // Change this to your theme color
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Image.network(
                                          qrData.caption,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Tap Me',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .white, // Change this to your theme color
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              VideoPage(
                                                            url: qrData.caption,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Lottie.asset(
                                                      "assets/lottie/play video.json",
                                                      height: 200,
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                    child: Lottie.asset(
                                        "assets/lottie/loading.json"),
                                  );
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     ElevatedButton(
                          //       onPressed: () {
                          //         launch(qrData.caption); // Open in browser
                          //       },
                          //       child: Text('Open in Browser'),
                          //     ),
                          //     SizedBox(width: 16),
                          //     ElevatedButton(
                          //       onPressed: () {
                          //         downloadFromIPFS(
                          //           qrData.caption,
                          //           qrData.hashCode,
                          //         ); // Download the image
                          //       },
                          //       child: Text('Download'),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ));
              } else {
                return SizedBox
                    .shrink(); // Return an empty widget if qrDataList is empty or index is out of range
              }
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
            ); /* AlertDialog(
              title: Text('Download Successful'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('The content has been downloaded.'),
                  SizedBox(height: 10),
                  Text('Downloaded to: $downloadedFilePath'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    viewDownloadedContent();
                  },
                  child: Text('Show'),
                ),
              ],
            ); */
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

  // void viewDownloadedContent() {
  //   if (downloadedFilePath.isNotEmpty) {
  //     // Use the open_file package to open the downloaded file
  //     OpenFile.open(downloadedFilePath);
  //   }
  // }

  Future<void> loadImage(String url) async {
    // You can add any custom logic for image loading here.
    // This can be an HTTP request, decoding an image, etc.
    // For this example, we're using Future.delayed to simulate loading.
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
