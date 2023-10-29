// ignore_for_file: prefer_const_constructors, deprecated_member_use, unnecessary_null_comparison

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:giga_share/resources/image_resources.dart';
import 'package:giga_share/screens/auth/signup_screen.dart';
import 'package:giga_share/screens/home/main_page.dart';
import 'package:giga_share/widgets/custom_button.dart';
import 'package:giga_share/widgets/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void showSnackBar(String title) {
    final snackBar = SnackBar(
        content: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15),
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void login() async {
    // Dialog box
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Signing you in',
      ),
    );

    final UserCredential user = await _auth
        .signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .catchError((error) {
      Navigator.pop(context);
      debugPrint("the error is :$error");
      /* try {
        PlatformException thisEx = error;
      } catch (e) {
        print(e);
        showSnackBar(" $e");
      }*/
    });

    if (user != null) {
      DatabaseReference userReference =
          FirebaseDatabase.instance.ref().child('users/${user.user!.uid}');

      userReference.once().then(
            (snapshot) => {
              if (snapshot != null)
                {
                  Get.offAll(() => MainPage()),
                }
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xff010723),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  ImageResources.loginImage,
                  height: 200,
                ),
                SizedBox(height: 40),
                Text(
                  'WELCOME BACK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
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
                              fontSize: 15), // Hint color
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
                              fontSize: 15), // Hint color
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
                      SizedBox(height: 100),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              title: 'LOGIN',
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

                                login();
                              },
                            ),
                          ),
                          Expanded(
                            child: CustomButton(
                              title: 'Register',
                              color: Colors.white,
                              textColor: Colors.black,
                              onPressed: () {
                                // Use a custom route with a swipe animation
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    transitionDuration:
                                        Duration(milliseconds: 500),
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      return SignupScreen();
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
