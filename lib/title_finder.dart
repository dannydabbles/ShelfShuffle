import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';

class TitleFinderPage extends StatefulWidget {
  TitleFinderPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TitleFinderPageState createState() => _TitleFinderPageState();
}

class _TitleFinderPageState extends State<TitleFinderPage> {
  List<String> data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RaisedButton(
            child: Text('Scan title'),
            onPressed: () async {
              final barcode = await Navigator.of(context).push<Barcode>(
                MaterialPageRoute(
                  builder: (c) {
                    return ScanPage();
                  },
                ),
              );
              if (barcode == null) {
                return;
              }

              data.add(barcode.displayValue);
              Navigator.of(context).pop<Barcode>(barcode);

              setState(() {});
            },
          ),
          Expanded(
            child: ListView(
              children: data.map((d) => Text(d)).toList(),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool resultSent = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: CameraMlVision<List<Barcode>>(
            detector: FirebaseVision.instance.barcodeDetector().detectInImage,
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
    );
  }
}