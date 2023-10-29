// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:giga_share/models/post/postmodel.dart';
// import 'package:url_launcher/url_launcher.dart';

// class QRList extends StatefulWidget {
//   @override
//   _QRListState createState() => _QRListState();
// }

// class _QRListState extends State<QRList> {
//   List<QRData> qrDataList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchQRData();
//   }

//   Future<void> fetchQRData() async {
//     print("the function is called");
//     DatabaseReference dataLinkRef =
//         FirebaseDatabase.instance.reference().child('dataLink');

//     DatabaseEvent event = await dataLinkRef.once();

//     DataSnapshot snapshot = event.snapshot;
//     qrDataList.clear();

//     if (snapshot.value != null) {
//       Map<dynamic, dynamic> values =
//           Map<dynamic, dynamic>.from(snapshot.value as Map);
//       values.forEach((key, value) {
//         if (value is Map) {
//           String username = value['username'] ?? 'Unknown';
//           String title = value['title'] ?? 'No Title';
//           String caption = value['caption'] ?? 'No Caption';
//           String url = value['url'].toString();

//           qrDataList.add(QRData(username, title, caption, url));
//         } else {
//           print('Invalid data format: $value');
//         }
//       });
//     }
//     print("the qr list is ${qrDataList[0].caption}");
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Public'),
//       ),
//       body: ListView.builder(
//         itemCount: qrDataList.length,
//         itemBuilder: (context, index) {
//           return buildQRContainer(qrDataList[index]);
//         },
//       ),
//     );
//   }

//   Widget buildQRContainer(QRData qrData) {
//     return Container(
//       margin: EdgeInsets.all(10),
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         border: Border.all(),
//       ),
//       child: Image.network(
//         qrData.caption,
//         width: 200,
//         height: 200,
//         errorBuilder: (context, error, stackTrace) {
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('Error loading image'),
//               ElevatedButton(
//                 onPressed: () {
//                   // Redirect to a web browser (Chrome) with the URL
//                   launch(qrData.caption);
//                 },
//                 child: Text('Open in Browser'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
