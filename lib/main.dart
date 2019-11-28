import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:expandable/expandable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml2json/xml2json.dart';
import 'package:best_effort_parser/name.dart';
import 'package:html/parser.dart';

import 'package:shelf_shuffle/keys.dart';
import 'package:shelf_shuffle/shelf.dart';
import 'package:shelf_shuffle/expanding_fab.dart';
import 'package:shelf_shuffle/view_book.dart';
import 'package:shelf_shuffle/title_finder.dart';

const url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:';
const title = "Shelf Shuffle";

Map<String, List<String>> screenData = {};

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
        '/': (context) => MyHomePage(title: title),
        '/book': (context) =>
            EditBookView(ModalRoute
                .of(context)
                .settings
                .arguments),
        '/coverScanner': (context) => ScanPage(),
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
    queryToID("0747538492").then((id) {
      idToISBN(id).then((isbn) {
        fetchISBN(isbn);
      });
    });
    queryToID("0747538492").then((id) {
      idToISBN(id).then((isbn) {
        fetchISBN(isbn);
      });
    });
    queryToID("0747595836").then((id) {
      idToISBN(id).then((isbn) {
        fetchISBN(isbn);
      });
    });
    queryToID("1551929767").then((id) {
      idToISBN(id).then((isbn) {
        fetchISBN(isbn);
      });
    });
    queryToID("	978-1-338-09913-3").then((id) {
      idToISBN(id).then((isbn) {
        fetchISBN(isbn);
      });
    });
    queryToID("9788498387568").then((id) {
      idToISBN(id).then((isbn) {
        fetchISBN(isbn);
      });
    });
    setState(() {});
  }

  void _clearBooks() {
    clearShelf();
    setState(() {});
  }

  Widget bookToDetailWidget(Book book) {
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          child: Row(
            children: <Widget>[
              Image(
                image: NetworkImage("${book.cover}"),
                alignment: Alignment.centerLeft,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: <Widget>[
                    Text(
                      "$title",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.3,
                    ),
                    Text(
                      "by \n${book.author}",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.15,
                    ),
                    Text(
                      "Published ${DateFormat('yyyy').format(DateTime
                          .fromMillisecondsSinceEpoch(book.date).toLocal())}",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      textScaleFactor: .8,
                    ),
                    Text(
                      "${book.description}",
                      softWrap: true,
                      textAlign: TextAlign.left,
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void areYouSureBookDialog(Book book) async {
    Future<bool> _asyncBoolDialog() async {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete book ${book.title}?'),
            content: const Text(
                'This will permanently delete this book from your library.'),
            actions: <Widget>[
              FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: const Text('DELETE'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        },
      );
    }

    final bool sure = await _asyncBoolDialog();
    if (sure) {
      deleteBook(book.id);
    }
    setState(() {});
  }

  Widget bookToWidget(book) {
    return Dismissible(
        key: UniqueKey(),
        background: slideToDeleteRightBackground(),
        secondaryBackground: slideToDeleteLeftBackground(),
        onDismissed: (direction) {
          areYouSureBookDialog(book);
        },
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/book', arguments: book);
          },
          child: Container(
            height: 50,
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2),
            child: Card(
              color: Colors.white24,
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: FractionallySizedBox(
                        widthFactor: .2,
                        child: Image(
                          image: NetworkImage("${book.cover}"),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    Flexible(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1.8,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
                          child: Text(
                            "${book.title}",
                            softWrap: true,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  String stripHTML(String htmlString) {
    var document = parse(htmlString);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

  Future<String> queryToID(String title) async {
    String id;

    String goodreadsSecret =
    await SecretLoader(secretPath: "secrets.json").load();
    String url =
        "https://www.goodreads.com/search/index.xml?key=$goodreadsSecret&q=${Uri
        .encodeFull(title)}";
    print(url);
    await http.get(url).then((response) {
      final Xml2Json myTransformer = Xml2Json();
      final String xml = response.body.toString();
      myTransformer.parse(xml);
      String jsonStr = myTransformer.toBadgerfish().toString();
      try {
        id = json
            .decode(jsonStr)['GoodreadsResponse']['search']['results']['work']
        ['best_book']['id']['\$']
            .toString();
      } catch (Exception) {
        print(Exception);
        id = json
            .decode(jsonStr)['GoodreadsResponse']['search']['results']['work']
        [0]['best_book']['id']['\$']
            .toString();
      }
    });
    return id;
  }

  Future<String> idToISBN(String id) async {
    String isbn;

    String goodreadsSecret =
    await SecretLoader(secretPath: "secrets.json").load();
    String url =
        "https://www.goodreads.com/book/show.xml?key=$goodreadsSecret&id=$id";
    print(url);
    await http.get(url).then((response) {
      final Xml2Json myTransformer = Xml2Json();
      final String xml = response.body.toString();
      myTransformer.parse(xml);
      String jsonStr = myTransformer.toBadgerfish().toString();
      isbn =
      json.decode(jsonStr)['GoodreadsResponse']['book']['isbn']['__cdata'];
    });

    return isbn;
  }

  void fetchISBN(String isbn) async {
    String goodreadsSecret =
    await SecretLoader(secretPath: "secrets.json").load();
    String url =
        "https://www.goodreads.com/book/isbn/$isbn?key=$goodreadsSecret";
    print(url);
    await http.get(url).then((response) {
      final Xml2Json myTransformer = Xml2Json();
      final String xml = response.body.toString();
      myTransformer.parse(xml);
      String jsonStr = myTransformer.toBadgerfish().toString();
      Map<String, dynamic> data =
      json.decode(jsonStr)['GoodreadsResponse']['book'];
      if (data.isNotEmpty) {
        int date = 0;
        String year =
        data['work']['original_publication_year']['\$'].toString();
        String month =
        data['work']['original_publication_month']['\$'].toString();
        String day = data['work']['original_publication_day']['\$'].toString();
        try {
          date = DateTime
              .parse("$year-$month-$day")
              .millisecondsSinceEpoch;
        } catch (Exception) {
          print(Exception);
          if (month == null || month == "null") {
            month = "01";
          }
          month = month.padLeft(2, "0");
          if (day == null || day == "null") {
            day = "01";
          }
          day = day.padLeft(2, "0");
          if (int.parse(year) >= 0) {
            date = DateTime
                .parse("$year-$month-$day")
                .millisecondsSinceEpoch;
          } else {
            year = int.parse(year).abs().toString().padLeft(4, '0');
            date = DateTime
                .parse("-$year-$month-$day")
                .millisecondsSinceEpoch;
          }
          print(Exception);
        }
        var authors_obj = data['authors']['author'];
        if (authors_obj is Map) {
          authors_obj = [authors_obj];
        }
        List<dynamic> authors = authors_obj;
        authors =
            authors.map((author) => author['name']['\$'].toString()).toList();
        String authorLastName;
        String author;
        if (authors.length > 0) {
          authorLastName = NameParser
              .basic()
              .parse(authors[0])
              .family;
        }
        if (authors.length > 1) {
          authors[authors.length - 1] = "and " + authors[authors.length - 1];
          author = authors.join(", ");
        } else if (authors.length == 1) {
          author = authors[0];
        }
        String title = data['title']['__cdata'].toString().replaceAll("\\", "");
        if (title == null || title == "null") {
          title = data['title']['\$'].toString().replaceAll("\\", "");
        }
        String cover = data['image_url']['\$'].toString();
        String description =
        stripHTML(data['description']['__cdata'].toString())
            .replaceAll("\\", "");
        String series = "";
        try {
          series = data['series_works']['series_work']['series']['title']
          ['__cdata']
              .toString();
        } catch (Exception) {
          print(Exception);
        }
        series = series.replaceAll("\\n", "");
        series = series.trim();
        print("Series: $series");
        insertBook(Book(
          title: title,
          date: date,
          author: author,
          cover: cover,
          isbn: isbn,
          series: series,
          description: description,
          authorLastName: authorLastName,
          goodreadsAPIXML: xml,
        ));
      }
    });
    setState(() {});
  }

  void scanBarcode() async {
    if (this.scanning != null && this.scanning) return;
    this.scanning = true;
    try {
      String isbn = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", // Red barcode line
          "Cancel", // Cancel button text
          true, // Show flash
          ScanMode.DEFAULT // Scan a barcode
      );
      fetchISBN(isbn);
    } catch (Exception) {
      print(Exception);
    } finally {
      this.scanning = false;
    }
  }

  void scanCover() async {
    if (this.scanning != null && this.scanning) return;
    this.scanning = true;
    try {
      dynamic coverScanResult =
      await Navigator.pushNamed(context, '/coverScanner');
      String title = coverScanResult.text;
      fetchISBN(await idToISBN(await queryToID(title)));
    } catch (Exception) {
      print(Exception);
    } finally {
      this.scanning = false;
    }
  }

  void getISBN() async {
    Future<String> _asyncInputDialog(BuildContext context) async {
      String isbn_or_title = '';
      return showDialog<String>(
        context: context,
        barrierDismissible: false,
        // dialog is dismissible with a tap on the barrier
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter a book by ISBN or title:'),
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                      autofocus: true,
                      decoration: new InputDecoration(
                          labelText: 'ISBN or title',
                          hintText: 'eg. 0547951981 or The Odyssey'),
                      onChanged: (value) {
                        isbn_or_title = value;
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
                  if (isbn_or_title.length > 0) {
                    Navigator.of(context).pop(isbn_or_title);
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

    final String isbn_or_title = await _asyncInputDialog(context);
    fetchISBN(await idToISBN(await queryToID(isbn_or_title)));
  }

  void areYouSureAuthorDialog(String author) async {
    Future<bool> _asyncBoolDialog() async {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete all books by author ${author}?'),
            content: const Text(
                'This will permanently delete these books from your library.'),
            actions: <Widget>[
              FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: const Text('DELETE ALL'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        },
      );
    }

    final bool sure = await _asyncBoolDialog();
    if (sure) {
      for (String author in screenData[author]) {
        deleteBooksByAuthor(author);
      }
      screenData.remove(author);
    }
    setState(() {});
  }

  Widget authorWidget(String author) {
    return Dismissible(
        key: UniqueKey(),
        background: slideToDeleteRightBackground(),
        secondaryBackground: slideToDeleteLeftBackground(),
        onDismissed: (direction) {
          print("Direction: $direction");
          areYouSureAuthorDialog(author);
          setState(() {});
        },
        child: Card(
          color: Colors.white38,
          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 3.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: Column(children: <Widget>[
                      Text(
                        "$author",
                        softWrap: true,
                        textScaleFactor: 1,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            height: 1),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<List<Widget>> getBookWidgets(String author) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Books.
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT * from books where author = '$author' ORDER BY series DESC, date ASC;");

    // Convert the List<Map<String, dynamic> into a List<Book>.
    return List.generate(maps.length, (i) {
      Book book = Book(
        id: maps[i]['id'],
        title: maps[i]['title'],
        date: maps[i]['date'],
        author: maps[i]['author'],
        authorLastName: maps[i]['authorLastName'],
        series: maps[i]['series'],
        isbn: maps[i]['isbn'],
        description: maps[i]['description'],
        cover: maps[i]['cover'],
        goodreadsAPIXML: maps[i]['google_api_xml'],
      );
      return bookToWidget(book);
    });
  }

  String formatAuthor(String author) {
    List<String> authors = author.split(', ');
    String authorLastName = NameParser
        .basic()
        .parse(authors[0])
        .family;
    String authorFirstName = NameParser
        .basic()
        .parse(authors[0])
        .given;
    String name;
    if ("$authorFirstName" == "") {
      name = "$authorLastName";
    } else {
      name = "$authorLastName, $authorFirstName";
    }
    return name;
  }

  Stream<List<Widget>> loadData() async* {
    List<Widget> slivers = [];
    screenData.clear();
    List<String> allAuthors = await getAuthors();
    Map<String, List<String>> authorDict = {};
    for (String author in allAuthors) {
      String authorFormatted = formatAuthor(author);
      if (authorDict.containsKey(authorFormatted)) {
        authorDict[authorFormatted] += [author];
      } else {
        authorDict[authorFormatted] = [author];
      }
    }
    for (String authorFormatted in authorDict.keys) {
      List<String> authors = authorDict[authorFormatted];
      List<Widget> authorWidgets = [];
      for (String author in authors) {
        if (screenData.containsKey(authorFormatted)) {
          screenData[authorFormatted] += [author];
        } else {
          screenData[authorFormatted] = [author];
        }
        authorWidgets += await getBookWidgets(author);
      }
      slivers += [
        ExpandablePanel(
            hasIcon: false,
            tapHeaderToExpand: true,
            header: authorWidget(authorFormatted),
            collapsed: Column(children: authorWidgets))
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
                  icon: Icon(Icons.delete_sweep),
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
        lookUpCover: scanCover,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
