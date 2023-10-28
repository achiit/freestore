import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:giga_share/models/post/postmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class QRList extends StatefulWidget {
  @override
  _QRListState createState() => _QRListState();
}

class _QRListState extends State<QRList> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Public'),
      ),
      body: ListView.builder(
        itemCount: qrDataList.length,
        itemBuilder: (context, index) {
          return buildQRContainer(qrDataList[index].url);
        },
      ),
    );
  }

  Widget buildQRContainer(String url) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Image.network(
        url,
        width: 200,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading image'),
              ElevatedButton(
                onPressed: () {
                  // Redirect to a web browser (Chrome) with the URL
                  launch(url);
                },
                child: Text('Open in Browser'),
              ),
            ],
          );
        },
      ),
    );
  }
}
