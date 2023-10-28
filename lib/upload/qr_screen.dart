// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:giga_share/config/config.dart';
import 'package:giga_share/widgets/custom_button.dart';
import 'package:giga_share/widgets/custom_divider.dart';
import 'package:giga_share/widgets/progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class QrScreen extends StatefulWidget {
  final String cid;
  const QrScreen({Key? key, required this.cid}) : super(key: key);

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  GlobalKey globalKey = GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final String qrUrl = ipfsURL + widget.cid;
    bool isUploading = false;

    void _launchURL() async {
      if (!await launch(qrUrl)) throw 'Could not launch $qrUrl';
    }

    void uploadUrl() async {
      try {
        setState(() {
          isUploading = true; // Start the upload, set isUploading to true
        });

        DatabaseReference dataLinkRef =
            FirebaseDatabase.instance.reference().child('dataLink');
        DatabaseReference newqrUpload = dataLinkRef.push();

        await newqrUpload.set(qrUrl);

        // If the URL is successfully uploaded, show a success message
        Fluttertoast.showToast(
          msg: 'URL uploaded successfully',
        );
      } catch (e) {
        // If there's an error, show an error message
        Fluttertoast.showToast(
          msg: 'Error uploading URL: $e',
        );
      } finally {
        setState(() {
          isUploading = false; // Finish the upload, set isUploading to false
        });
      }
    }

    void _downloadQr() async {
      PermissionStatus res;
      res = await Permission.storage.request();
      if (res.isGranted) {
        final boundary = globalKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;

        final image = await boundary.toImage(pixelRatio: 5.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          // getting directory of our phone
          final directory = (await getApplicationDocumentsDirectory()).path;
          final imgFile = File(
            '$directory/${DateTime.now()}qr.png',
          );
          imgFile.writeAsBytes(pngBytes);
          GallerySaver.saveImage(imgFile.path).then((success) async {
            Fluttertoast.showToast(
              msg: 'QR saved to your device',
            );
          });
        }
      }
    }

    void _copyTextToClipboard(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Text copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'SCAN QR',
          style: TextStyle(
            letterSpacing: 1.2,
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            RepaintBoundary(
              key: globalKey,
              child: QrImageView(
                data: qrUrl,
                size: 280,
                gapless: false,
                version: QrVersions.auto,
                //backgroundColor: Colors.white,
                //errorCorrectionLevel: QrErrorCorrectLevel.L,
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Scan above QR or Press Go to check your file',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'CID',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 14),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.65,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          widget.cid,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: CustomDivider(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: 15,
                top: 10,
              ),
              child: Row(
                children: [
                  Text(
                    'URL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.65,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          qrUrl,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: _launchURL,
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.12,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Go',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _copyTextToClipboard(qrUrl);
                    },
                    child: Container(
                      height: 50,
                      //width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Copy URL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      uploadUrl();
                    },
                    child: Container(
                      height: 50,
                      //width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Share as post..',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: CustomDivider(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 15.0,
              ),
              child: CustomButton(
                title: 'Download QR',
                color: Colors.black87,
                onPressed: _downloadQr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
