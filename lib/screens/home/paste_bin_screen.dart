import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:giga_share/resources/image_resources.dart';

import '../../resources/color_constants.dart';
import '../../services/text_file_service.dart';

class PasteBinScreen extends StatefulWidget {
  const PasteBinScreen({Key? key}) : super(key: key);

  @override
  State<PasteBinScreen> createState() => _PasteBinScreenState();
}

class _PasteBinScreenState extends State<PasteBinScreen> {
  final _fileNameController = TextEditingController();
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff010723),
      appBar: AppBar(
        backgroundColor: Color(0xff320482),
        elevation: 0,
        //centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Paste Bin,',
          style: TextStyle(
            letterSpacing: 1.2,
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: kIsWeb ? 80 : 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(150)),
              color: Color(0xff320482),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create and share any text format on IPFS.',
                    style: TextStyle(
                      letterSpacing: 1.2,
                      color: Color(0xffDBC1FC),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // const Align(
          //   alignment: Alignment.center,
          //   child: Text(
          //     'Create and share any text format on IPFS.',
          //     textAlign: TextAlign.center,
          //     style: TextStyle(
          //         color: Colors.white,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 16),
          //   ),
          // ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              'FILENAME (OPTIONAL)',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _fileNameController,
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              cursorColor: Colors.white,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  hintStyle: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              'CONTENT',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                cursorColor: Colors.white,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    hintStyle: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                primary: ColorConstants.messageErrorBgColor,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () async {
                await TextFileService.uploadTextFile(context,
                    _textController.text, _fileNameController.text, '', "");
                _textController.text = '';
                _fileNameController.text = '';
              },
              label: const Text(
                'Create Paste',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Image.asset(
                ImageResources.pasteBinIcon,
                height: 16,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
