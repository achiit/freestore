// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:giga_share/config/config.dart';
import 'package:giga_share/models/user_model.dart';
import 'package:giga_share/services/ipfs/ipfs_service.dart';
import 'package:giga_share/upload/qr_screen.dart';
import 'package:giga_share/widgets/boxes.dart';
import 'package:giga_share/widgets/progress_dialog.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ImagePickerService {
  @protected
  @mustCallSuper
  void dispose() {
    Hive.close();
  }
  static Future<void> addURLToUserPosts(String url) async {
      final _auth = FirebaseAuth.instance;
      final currentUser = _auth.currentUser;
      print("the currentuser is ${currentUser!.uid}");
      if (currentUser != null) {
        final DatabaseReference userReference = FirebaseDatabase.instance
            .reference()
            .child('users/${currentUser.uid}/myposts');

        // Push the new URL to the "myposts" node
        final newPostRef = userReference.push();
        newPostRef.set(url);

        print('URL added to user posts: $url');
      }
    }
//PICKER
  static Future<XFile?> pickImage(BuildContext context, String username,String userid) async {
    final ImagePicker _picker = ImagePicker();
    final List<UserModel> transactions = [];

    try {
      // Pick an images
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      //Nothing picked
      if (image == null) {
        Fluttertoast.showToast(
          msg: 'No Image Selected',
        );
        return null;
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => ProgressDialog(
            status: 'Uploading to IPFS',
          ),
        );

        final Uint8List bytes = await image.readAsBytes();

        // upload images to ipfs
        final cid = await IpfsService().uploadToIpfs(bytes);
        // debugPrint(cid);

        // Saving the transaction to database
        // DatabaseReference transaction =
        //     FirebaseDatabase.instance.ref().child('transactions');

        // String uploadID = transaction.push().key!;

        // Map transactionMap = {
        //   'url': ipfsURL + cid,
        //   'date': DateFormat.yMMMd().format(DateTime.now()),
        //   'received': false,
        // };

        // transaction.child(uploadID).set(transactionMap);

        // Saving the transaction to database
        final transactionMap = UserModel()
          ..url = ipfsURL + cid
          ..date = DateFormat.yMMMd().format(DateTime.now())
          ..received = false;

        final box = Boxes.getTransactions();
        box.add(transactionMap);
        await addURLToUserPosts(ipfsURL + cid);
        // Popping out the dialog box
        Navigator.pop(context);

        // Take to QrScreen
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QrScreen(
                      cid: cid,
                      username: username,
                      userid: userid,
                    )));
        //await Get.to(() => QrScreen(cid: cid));

        //Return Path
        return image;
      }
    } catch (e) {
      debugPrint('Error at images picker: $e');
      SnackBar(
        content: Text(
          'Error at images picker: $e',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
      );
      return null;
    }
  }
}
