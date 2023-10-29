// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:giga_share/resources/color_constants.dart';
import 'package:giga_share/resources/image_resources.dart';
import 'package:giga_share/services/file_picker_service.dart';
import 'package:giga_share/services/image_picker_service.dart';
import 'package:giga_share/services/video_picker_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _textController = TextEditingController();
  String getUserName = '';
  String getUserid = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
        getUserid = _auth.currentUser!.uid;
      });
      print("the username and id is $getUserName and $getUserid");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff010723),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: kIsWeb ? 150 : 120,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(170),
              bottomRight: Radius.circular(0)),
        ),
        backgroundColor: Color(0xff320482),
        elevation: 0,
        //centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                    Text(
                      'Hey, ${getUserName.toUpperCase()},',
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
                  'lets upload your stuff ',
                  style: TextStyle(
                    letterSpacing: 1.2,
                    color: Color(0xffDBC1FC),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xff320482),
                borderRadius: BorderRadius.only(
                    //topLeft: Radius.circular(20),
                    topRight: Radius.circular(180)),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        await ImagePickerService.pickImage(
                            context, getUserName, getUserid);
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Image.asset(
                                ImageResources.uploadImage,
                                height: 200,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  primary: ColorConstants.messageErrorBgColor,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  await ImagePickerService.pickImage(
                                      context, getUserName, getUserid);
                                },
                                label: Text(
                                  'Upload Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                icon: Icon(Icons.image,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        await VideoPickerService.pickVideo(
                            context, getUserName, getUserid);
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Image.asset(
                                ImageResources.uploadVideoImage,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  primary: ColorConstants.messageErrorBgColor,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  await VideoPickerService.pickVideo(
                                      context, getUserName, getUserid);
                                },
                                label: Text(
                                  'Upload Video',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                icon: Icon(Icons.video_call_rounded,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        await FilePickerService.pickFile(
                            context, getUserName, getUserid);
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Image.asset(
                                ImageResources.uploadFileImage,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  primary: ColorConstants.messageErrorBgColor,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  await FilePickerService.pickFile(
                                      context, getUserName, getUserid);
                                },
                                label: Text(
                                  'Upload File',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.file_copy_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
