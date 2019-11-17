import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shelf_shuffle/view_book.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

final database = initShelf();

Future<Database> initShelf() async {
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'book_database.db'),
    // When the database is first created, create a table to store books.
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE books("
        "id INTEGER PRIMARY KEY, "
        "title TEXT, "
        "date INTEGER, "
        "author TEXT, "
        "series TEXT, "
        "isbn TEXT, "
        "description TEXT, "
        "cover TEXT, "
        "google_api_json TEXT"
        ")",
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  return database;
}

Widget slideToDeleteBackground() {
  return Card(
    color: Colors.red,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text(
            " Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      alignment: Alignment.centerRight,
    ),
  );
}

Widget slideToEditBackground() {
  return Card(
    color: Colors.green,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.edit,
            color: Colors.white,
          ),
          Text(
            " Edit",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
    ),
  );
}

Future<void> insertBook(Book book) async {
  // Get a reference to the database.
  final Database db = await database;

  // Insert the Book into the correct table. Also specify the
  // `conflictAlgorithm`. In this case, if the same book is inserted
  // multiple times, it replaces the previous data.
  await db.insert(
    'books',
    book.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Book>> getBooks() async {
  // Get a reference to the database.
  final Database db = await database;

  // Query the table for all The Books.
  final List<Map<String, dynamic>> maps = await db.query('books');

  // Convert the List<Map<String, dynamic> into a List<Book>.
  return List.generate(maps.length, (i) {
    return Book(
      id: maps[i]['id'],
      title: maps[i]['title'],
      date: maps[i]['date'],
      author: maps[i]['author'],
      series: maps[i]['series'],
      isbn: maps[i]['isbn'],
      description: maps[i]['description'],
      cover: maps[i]['cover'],
      google_api_json: maps[i]['google_api_json'],
    );
  });
}

Future<List<String>> getAuthors() async {
  // Get a reference to the database.
  final Database db = await database;

  // Query the table for all The Books.
  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT DISTINCT author FROM books");
  print(maps);

  // Convert the List<Map<String, dynamic> into a List<Book>.
  return List.generate(maps.length, (i) {
    return maps[i]['author'];
  });
}

Future<List<Widget>> getBookWidgets(BuildContext context, String author) async {
  // Get a reference to the database.
  final Database db = await database;

  // Query the table for all The Books.
  final List<Map<String, dynamic>> maps = await db.query('books',
      where: "author = ?",
      whereArgs: [author],
      groupBy: "series",
      orderBy: "date");

  // Convert the List<Map<String, dynamic> into a List<Book>.
  return List.generate(maps.length, (i) {
    Book book = Book(
      id: maps[i]['id'],
      title: maps[i]['title'],
      date: maps[i]['date'],
      author: maps[i]['author'],
      series: maps[i]['series'],
      isbn: maps[i]['isbn'],
      description: maps[i]['description'],
      cover: maps[i]['cover'],
      google_api_json: maps[i]['google_api_json'],
    );
    return book.toWidget(context);
  });
}

Future<void> updateBook(Book book) async {
  // Get a reference to the database.
  final db = await database;

  // Update the given Book.
  await db.update(
    'books',
    book.toMap(),
    // Ensure that the Book has a matching id.
    where: "id = ?",
    // Pass the Book's id as a whereArg to prevent SQL injection.
    whereArgs: [book.id],
  );
}

Future<void> deleteBook(int id) async {
  // Get a reference to the database.
  final db = await database;

  // Remove the Book from the database.
  await db.delete(
    'books',
    // Use a `where` clause to delete a specific book.
    where: "id = ?",
    // Pass the Book's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}

Future<void> clearShelf() async {
  // Get a reference to the database.
  final db = await database;

  // Remove the Book from the database.
  await db.delete(
    'books',
  );
}

var example = Book(
  id: 0,
  title: 'Harry Potter and the Deathly Hallows',
  date: 1199174400000,
  author: 'J. K. Rowling',
  series: "Harry Potter",
  isbn: '0747595836',
  description:
      "Harry Potter is preparing to leave the Dursleys and Privet Drive for the last time. But the future that awaits him is full of danger, not only for him, but for anyone close to him - and Harry has already lost so much. Only by destroying Voldemort's remaining Horcruxes can Harry free himself and overcome the Dark Lord's forces of evil. In this dramatic conclusion to the Harry Potter series, Harry must leave his most loyal friends behind, and in a final perilous journey find the strength and the will to face his terrifying destiny: a deadly confrontation that is his alone to fight. In this thrilling climax to the phenomenally bestselling series, J.K. Rowling reveals all to her eagerly waiting readers.",
  cover:
      "http://books.google.com/books/content?id=uaxPJwAACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api",
  google_api_json: """
{
 "kind": "books#volumes",
 "totalItems": 1,
 "items": [
  {
   "kind": "books#volume",
   "id": "uaxPJwAACAAJ",
   "etag": "U8afabuFv/Q",
   "selfLink": "https://www.googleapis.com/books/v1/volumes/uaxPJwAACAAJ",
   "volumeInfo": {
    "title": "Harry Potter and the Deathly Hallows",
    "authors": [
     "J. K. Rowling"
    ],
    "publisher": "Bloomsbury Pub Limited",
    "publishedDate": "2008",
    "description": "Harry Potter is preparing to leave the Dursleys and Privet Drive for the last time. But the future that awaits him is full of danger, not only for him, but for anyone close to him - and Harry has already lost so much. Only by destroying Voldemort's remaining Horcruxes can Harry free himself and overcome the Dark Lord's forces of evil. In this dramatic conclusion to the Harry Potter series, Harry must leave his most loyal friends behind, and in a final perilous journey find the strength and the will to face his terrifying destiny: a deadly confrontation that is his alone to fight. In this thrilling climax to the phenomenally bestselling series, J.K. Rowling reveals all to her eagerly waiting readers.",
    "industryIdentifiers": [
     {
      "type": "ISBN_10",
      "identifier": "0747595836"
     },
     {
      "type": "ISBN_13",
      "identifier": "9780747595830"
     }
    ],
    "readingModes": {
     "text": false,
     "image": false
    },
    "pageCount": 607,
    "printType": "BOOK",
    "categories": [
     "Juvenile Fiction"
    ],
    "averageRating": 4.5,
    "ratingsCount": 3384,
    "maturityRating": "NOT_MATURE",
    "allowAnonLogging": false,
    "contentVersion": "preview-1.0.0",
    "imageLinks": {
     "smallThumbnail": "http://books.google.com/books/content?id=uaxPJwAACAAJ&printsec=frontcover&img=1&zoom=5&source=gbs_api",
     "thumbnail": "http://books.google.com/books/content?id=uaxPJwAACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api"
    },
    "language": "en",
    "previewLink": "http://books.google.com/books?id=uaxPJwAACAAJ&dq=isbn:0747595836&hl=&cd=1&source=gbs_api",
    "infoLink": "http://books.google.com/books?id=uaxPJwAACAAJ&dq=isbn:0747595836&hl=&source=gbs_api",
    "canonicalVolumeLink": "https://books.google.com/books/about/Harry_Potter_and_the_Deathly_Hallows.html?hl=&id=uaxPJwAACAAJ"
   },
   "saleInfo": {
    "country": "US",
    "saleability": "NOT_FOR_SALE",
    "isEbook": false
   },
   "accessInfo": {
    "country": "US",
    "viewability": "NO_PAGES",
    "embeddable": false,
    "publicDomain": false,
    "textToSpeechPermission": "ALLOWED",
    "epub": {
     "isAvailable": false
    },
    "pdf": {
     "isAvailable": false
    },
    "webReaderLink": "http://play.google.com/books/reader?id=uaxPJwAACAAJ&hl=&printsec=frontcover&source=gbs_api",
    "accessViewStatus": "NONE",
    "quoteSharingAllowed": false
   },
   "searchInfo": {
    "textSnippet": ". . In this final, seventh instalment of the Harry Potter series, J.K. Rowling unveils in spectacular fashion the answers to the many questions that have been so eagerly awaited."
   }
  }
 ]
}
""",
);

void loadShelf() async {
  // Create example book
  example = Book(
    id: example.id,
    title: example.title,
    date: example.date,
    author: example.author,
    series: example.series,
    isbn: example.isbn,
    description: example.description,
    cover: example.cover,
    google_api_json: example.google_api_json,
  );

  // Insert example book into the database.
  await insertBook(example);
}

Widget authorWidget(String author) {
  return Dismissible(
      key: UniqueKey(),
      background: slideToDeleteBackground(),
      secondaryBackground: slideToEditBackground(),
      onDismissed: (direction) => {print("Author: $author | Direction: $direction")},
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

class Book {
  final int id;
  final String title;
  final int date;
  final String author;
  final String series;
  final String isbn;
  final String description;
  final String cover;
  final String google_api_json;

  Book({
    this.id,
    this.title,
    this.date,
    this.author,
    this.series,
    this.isbn,
    this.description,
    this.cover,
    this.google_api_json,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'author': author,
      'series': series,
      'isbn': isbn,
      'description': description,
      'cover': cover,
      'google_api_json': google_api_json,
    };
  }

  // Implement toString to make it easier to see information about
  // each book when using the print statement.
  @override
  String toString() {
    return 'Book{id: $id, title: $title, date: ${DateTime.fromMillisecondsSinceEpoch(date)}, author: $author, series: $series, isbn: $isbn, description: $description}';
  }

  Widget toDetailWidget() {
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          child: Row(
            children: <Widget>[
              Image(
                image: NetworkImage("$cover"),
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
                      "by \n$author",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.15,
                    ),
                    Text(
                      "Published ${DateFormat('yyyy').format(DateTime.fromMillisecondsSinceEpoch(date).toLocal())}",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      textScaleFactor: .8,
                    ),
                    Text(
                      "$description",
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

  Widget toWidget(BuildContext context) {
    return Dismissible(
        key: UniqueKey(),
        background: slideToDeleteBackground(),
        secondaryBackground: slideToEditBackground(),
        onDismissed: (direction) {
          print("Direction: $direction");
          Navigator.pushNamed(context, '/book');
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
                        image: NetworkImage("$cover"),
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
                          "$title",
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
        ));
  }
}
