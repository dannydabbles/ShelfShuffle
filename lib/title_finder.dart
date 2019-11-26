import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';

class ScanPage extends StatefulWidget {
  ScanPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool resultSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan a book"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SafeArea(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: CameraMlVision<List<Barcode>>(
                  detector:
                      FirebaseVision.instance.barcodeDetector().detectInImage,
                  onResult: (List<Barcode> barcodes) {
                    if (!mounted || resultSent) {
                      return;
                    }
                    if (barcodes.isNotEmpty) {
                      resultSent = true;
                      Navigator.of(context).pop<Barcode>(barcodes.first);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
