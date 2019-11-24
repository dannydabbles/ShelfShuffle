import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
        "title TEXT UNIQUE, "
        "date INTEGER, "
        "author TEXT, "
        "authorLastName TEXT, "
        "series TEXT, "
        "isbn TEXT, "
        "description TEXT, "
        "cover TEXT, "
        "goodreadsAPIXML TEXT"
        ")",
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  return database;
}

Widget slideToDeleteRightBackground() {
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

Widget slideToDeleteLeftBackground() {
  return Card(
    color: Colors.red,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
          Icon(
            Icons.delete,
            color: Colors.white,
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
      authorLastName: maps[i]['authorLastName'],
      series: maps[i]['series'],
      isbn: maps[i]['isbn'],
      description: maps[i]['description'],
      cover: maps[i]['cover'],
      goodreadsAPIXML: maps[i]['goodreadsAPIXML'],
    );
  });
}

Future<List<String>> getAuthors() async {
  // Get a reference to the database.
  final Database db = await database;

  // Query the table for all The Books.
  final List<Map<String, dynamic>> maps =
      await db.rawQuery("SELECT DISTINCT author FROM books ORDER BY authorLastName");
  print(maps);

  // Convert the List<Map<String, dynamic> into a List<Book>.
  return List.generate(maps.length, (i) {
    return maps[i]['author'];
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

Future<void> deleteBooksByAuthor(String author) async {
  // Get a reference to the database.
  final db = await database;

  // Remove the Book from the database.
  await db.delete(
    'books',
    // Use a `where` clause to delete a specific book.
    where: "author = ?",
    // Pass the Book's id as a whereArg to prevent SQL injection.
    whereArgs: [author],
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

class Book {
  final int id;
  final String title;
  final int date;
  final String author;
  final String authorLastName;
  final String series;
  final String isbn;
  final String description;
  final String cover;
  final String goodreadsAPIXML;

  Book({
    this.id,
    this.title,
    this.date,
    this.author,
    this.authorLastName,
    this.series,
    this.isbn,
    this.description,
    this.cover,
    this.goodreadsAPIXML,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'author': author,
      'authorLastName': authorLastName,
      'series': series,
      'isbn': isbn,
      'description': description,
      'cover': cover,
      'goodreadsAPIXML': goodreadsAPIXML,
    };
  }

  // Implement toString to make it easier to see information about
  // each book when using the print statement.
  @override
  String toString() {
    return 'Book{id: $id, title: $title, date: ${DateTime.fromMillisecondsSinceEpoch(date)}, author: $author, series: $series, isbn: $isbn, description: $description}';
  }
}