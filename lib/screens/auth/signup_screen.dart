// ignore_for_file: prefer_const_constructors, deprecated_member_use, unnecessary_null_comparison

import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:giga_share/resources/color_constants.dart';
import 'package:giga_share/screens/auth/login_screen.dart';
import 'package:giga_share/screens/home/main_page.dart';
import 'package:giga_share/services/firebase_api.dart';
import 'package:giga_share/widgets/custom_button.dart';
import 'package:giga_share/widgets/progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../resources/image_resources.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  File? _image;

  /*html_file.File? _webImage;*/
  Uint8List? _webBytes;
  UploadTask? task;
  String? urlDownload;

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void registerUser() async {
    // Dialog box
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Registering you...',
      ),
    );

    final UserCredential user = await _auth
        .createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .catchError((error) {
      Navigator.pop(context);
      PlatformException thisEx = error;
      showSnackBar(thisEx.message as String);
    });

    if (user != null) {
      DatabaseReference newUserReference = FirebaseDatabase.instance
          .ref()
          .child('users/${_auth.currentUser!.uid}');

      // String uploadID = newUserReference.push().key!;

      final fileName =
          kIsWeb ? '${DateTime.now()}' : path.basename(_image.toString());
      final destination = 'files/$fileName';
      try {
        task = kIsWeb
            ? FirebaseApi.uploadBytes(destination, _webBytes!)
            : FirebaseApi.uploadFile(destination, _image!);
        setState(() {});

        if (task == null) return;

        final snapshot = await task!.whenComplete(() {});
        urlDownload = await snapshot.ref.getDownloadURL();
      } on FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }

      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'profileImage': urlDownload!,
      };

      newUserReference.set(userMap);

      Get.offAll(MainPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xff010723),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                ImageResources.appTextLogoImage,
                //height: 300,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Make your own ID Card",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromARGB(255, 86, 122, 152),
                                fontSize: 27,
                              ),
                            ),
                            Text(
                              "Welcome to Social Hub",
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color.fromRGBO(255, 255, 255, 1),
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 150,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () async {
                          final ImagePicker _picker = ImagePicker();
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );

                          //late final selectedImage
                          late final File selectedImage;
                          if (kIsWeb) {
                            _webBytes = await image!.readAsBytes();
                            setState(() {
                              /*_webImage = html_file.File(_webBytes!, image.name);*/
                            });
                          } else {
                            setState(() {
                              _image = File(image!.path);
                            });
                          }
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 43, 53, 98),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(500),
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(35),
                                    child: (_image != null || _webBytes != null)
                                        ? kIsWeb
                                            ? Image.memory(_webBytes!)
                                            : Image.file(File(_image!.path))
                                        : Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Flexible(
                                  child: Container(
                                    child: Text(
                                      "Upload your profile picture",
                                      softWrap: true,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: fullNameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.text_fields),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Full Name',
                        labelStyle: TextStyle(
                            fontSize: 14, color: Colors.black), // Label color
                        hintText: 'Enter your full name', // Optional hint text
                        hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 10), // Hint color
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.5), // White border when focused
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0), // White border when not focused
                        ),
                        filled: true,
                        fillColor: Colors.white, // Fill color
                      ),
                      style: TextStyle(
                          fontSize: 14, color: Colors.black), // Text color
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.email),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Email Address',
                        labelStyle: TextStyle(
                            fontSize: 14, color: Colors.black), // Label color
                        hintText: 'Enter your email', // Optional hint text
                        hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 10), // Hint color
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.5), // White border when focused
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0), // White border when not focused
                        ),
                        filled: true,
                        fillColor: Colors.white, // Fill color
                      ),
                      style: TextStyle(
                          fontSize: 14, color: Colors.black), // Text color
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.password),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            fontSize: 14, color: Colors.black), // Label color
                        hintText: 'Enter your password', // Optional hint text
                        hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 10), // Hint color
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.5), // White border when focused
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0), // White border when not focused
                        ),
                        filled: true,
                        fillColor: Colors.white, // Fill color
                      ),
                      style: TextStyle(
                          fontSize: 14, color: Colors.black), // Text color
                    ),
                    SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            title: 'LOGIN',
                            color: Colors.white,
                            textColor: Colors.black,
                            onPressed: () {
                              // Use a custom route with a swipe animation
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration:
                                      Duration(milliseconds: 500),
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return WillPopScope(
                                      onWillPop: () async {
                                        // Prevent the user from going back
                                        return false;
                                      },
                                      child: LoginScreen(),
                                    );
                                  },
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);
                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: CustomButton(
                            title: 'Register',
                            color: Colors.blueAccent,
                            onPressed: () async {
                              // Network checking
                              var connectivityResult =
                                  await Connectivity().checkConnectivity();
                              if (connectivityResult !=
                                      ConnectivityResult.mobile &&
                                  connectivityResult !=
                                      ConnectivityResult.wifi) {
                                showSnackBar('No Internet connection');
                                return;
                              }

                              // Textfield validation
                              if (fullNameController.text.length < 3) {
                                showSnackBar('Please enter your full name');
                                return;
                              }

                              if (!emailController.text.contains('@')) {
                                showSnackBar(
                                    'Please enter a valid email Address');
                                return;
                              }

                              if (passwordController.text.length <= 8) {
                                showSnackBar(
                                    'Password must be at least 8 characters');
                                return;
                              }

                              if (kIsWeb) {
                                if (_webBytes == null) {
                                  showSnackBar('Upload your images');
                                  return;
                                }
                              } else {
                                if (_image == null) {
                                  showSnackBar('Upload your images');
                                  return;
                                }
                              }

                              registerUser();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MaterialButton(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 10),
                onPressed: () {
                  Get.offAll(LoginScreen());
                },
                child: Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
