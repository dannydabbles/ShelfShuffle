import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:shelf_shuffle/shelf.dart';
import 'package:shelf_shuffle/expanding_fab.dart';

const url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:';
const title = "Shelf Shuffle";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    loadShelf();
    setState(() {});
  }

  void _clearBooks() {
    clearShelf();
    setState(() {});
  }

  void scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", // Red barcode line
        "Cancel", // Cancel button text
        true, // Show flash
        ScanMode.DEFAULT // Scan a barcode
        );
    var bookUrl = url + barcodeScanRes;
    print(bookUrl);
    await http.get(bookUrl).then((response) {
      String json = response.body.toString();
      Map<String, dynamic> data = jsonDecode(json);
      print(data);
      if (data.isNotEmpty && data['totalItems'] != 0) {
        int date = 0;
        try {
          date = DateTime.parse(data['items'][0]['volumeInfo']['publishedDate'])
              .millisecondsSinceEpoch;
        } catch (Exception) {
          date = DateTime.parse(
                  data['items'][0]['volumeInfo']['publishedDate'] + "-01-01")
              .millisecondsSinceEpoch;
        }
        insertBook(Book(
          title: data['items'][0]['volumeInfo']['title'],
          date: date,
          author: data['items'][0]['volumeInfo']['authors'][0],
          cover: data['items'][0]['volumeInfo']['imageLinks']["thumbnail"],
          isbn: data['items'][0]['volumeInfo']['industryIdentifiers'][0]
              ['identifier'],
          description: data['items'][0]['volumeInfo']['description'],
          google_api_json: json,
        ));
      }
    });
    setState(() {});
  }

  Stream<List<Widget>> loadData() async* {
    yield await getBookWidgets();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: StreamBuilder<List<Widget>>(
        stream: loadData(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      leading: IconButton(
                        icon: Icon(Icons.autorenew),
                        onPressed: _clearBooks,
                      ),
                      expandedHeight: 220.0,
                      floating: true,
                      pinned: true,
                      snap: true,
                      elevation: 5,
                      backgroundColor: Colors.blue,
                      flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: FractionallySizedBox(
                            heightFactor: .265,
                            child: Text(widget.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0,-0.5),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ])),
                          ),
                          background: Image.network(
                            'https://images.unsplash.com/photo-1507842217343-583bb7270b66?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&h=650&w=940',
                            fit: BoxFit.cover,
                          )),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return snapshot.data[index];
                      }, childCount: snapshot.data.length),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
      floatingActionButton: ExpandingFab(
        onPressed: scanBarcode,
        tooltip: 'Add a new book',
        icon: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
