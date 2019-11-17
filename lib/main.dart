import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:shelf_shuffle/shelf.dart';
import 'package:shelf_shuffle/expanding_fab.dart';
import 'package:expandable/expandable.dart';

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
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: title)
      },
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
  bool scanning;

  _MyHomePageState({this.scanning}) {
    this.scanning = false;
  }

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

  void fetchISBN(String isbn) async {
    var bookUrl = url + isbn;
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
        List<dynamic> authors = data['items'][0]['volumeInfo']['authors'];
        if (authors.length > 1) {
          authors[-1] = "and " + authors[-1];
        }
        insertBook(Book(
          title: data['items'][0]['volumeInfo']['title'],
          date: date,
          author: authors.join(", "),
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

  void scanBarcode() async {
    if (this.scanning != null && this.scanning) return;
    this.scanning = true;
    String isbn = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", // Red barcode line
        "Cancel", // Cancel button text
        true, // Show flash
        ScanMode.DEFAULT // Scan a barcode
        );
    fetchISBN(isbn);
    this.scanning = false;
  }

  void getISBN() async {
    final String isbn = await _asyncInputDialog(context);
    fetchISBN(isbn);
  }

  Future<String> _asyncInputDialog(BuildContext context) async {
    String teamName = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter a book by ISBN:'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'ISBN', hintText: 'eg. 0547951981'),
                onChanged: (value) {
                  teamName = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                // Handle special case for empty isbn
                if (teamName.length > 0) {
                  Navigator.of(context).pop(teamName);
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Stream<List<Widget>> loadData() async* {
    List<Widget> slivers = [];
    for (String author in await getAuthors()) {
      slivers += [
        ExpandablePanel(
            hasIcon: false,
            tapHeaderToExpand: true,
            header: authorWidget(author),
            collapsed: Column(children: await getBookWidgets(author)))
      ];
    }
    yield slivers;
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(),
      ),
      backgroundColor: Colors.black12,
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
                        color: Colors.white,
                      ),
                      expandedHeight: 220.0,
                      floating: true,
                      pinned: true,
                      snap: true,
                      elevation: 5,
                      backgroundColor: Colors.grey,
                      flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: Text(widget.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, -0.5),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ])),
                          background: Image.network(
                            'https://images.unsplash.com/photo-1507842217343-583bb7270b66?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&h=650&w=940',
                            fit: BoxFit.cover,
                            color: Colors.grey,
                            colorBlendMode: BlendMode.saturation,
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
        barcodeScanner: scanBarcode,
        lookUpISBN: getISBN,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
