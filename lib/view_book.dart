import 'package:flutter/material.dart';
import 'package:shelf_shuffle/shelf.dart';

class EditBookView extends StatefulWidget {
  final Book book;

  EditBookView(this.book);

  @override
  _EditBookViewState createState() => _EditBookViewState(book);
}

class _EditBookViewState extends State<EditBookView> {
  final Book book;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _EditBookViewState(this.book);

  // controllers for form text controllers
  final TextEditingController _titleController = TextEditingController();
  String title = "e.g. The Hound of the Baskervilles";
  final TextEditingController _dateController = TextEditingController();
  String date = "e.g. 1901";
  final TextEditingController _authorController = TextEditingController();
  String author = "e.g. Arthur Conan Doyle";
  final TextEditingController _seriesController = TextEditingController();
  String series = "e.g. Sherlock Holmes";
  final TextEditingController _descriptionController = TextEditingController();
  String description =
      "e.g. The rich landowner Sir Charles Baskerville is found dead in the park of his manor surrounded by the grim moor of Dartmoor, in the county of Devon. His death seems to have been caused by a heart attack, but the victim's best friend, Dr. Mortimer, is convinced that the strike was due to a supernatural creature, which haunts the moor in the shape of an enormous hound, with blazing eyes and jaws. In order to protect Baskerville's heir, Sir Henry, who's arriving to London from Canada, Dr. Mortimer asks for Sherlock Holmes' help, telling him also of the so-called Baskervilles' curse, according to which a monstrous hound has been haunting and killing the family males for centuries, in revenge for the misdeeds of one Sir Hugo Baskerville, who lived at the time of Oliver Cromwell.";

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (form != null && !form.validate()) {
      print('Please fix the errors in red before submitting.');
    } else {
      print('Validated!');
      int milli = 0;
      try {
        milli = DateTime.parse(_dateController.text).millisecondsSinceEpoch;
      } catch (Exception) {
        print(Exception);
        milli = DateTime.parse(_dateController.text + "-01-01").millisecondsSinceEpoch;
      }
      updateBook(Book(
        id: book.id,
        title: _titleController.text,
        date: milli,
        author: _authorController.text,
        authorLastName: book.authorLastName,
        series: _seriesController.text,
        description: _descriptionController.text,
        isbn: book.isbn,
        cover: book.cover,
        goodreadsAPIXML: book.goodreadsAPIXML,
      ));
    }
  }

  @override
  void initState() {
    _titleController.text = book.title;
    _dateController.text =
        DateTime.fromMillisecondsSinceEpoch(book.date).year.toString();
    _authorController.text = book.author;
    _seriesController.text = book.series;
    _descriptionController.text = book.description;
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
            title: Container(
              child: Text(
                'Book Information',
                textAlign: TextAlign.center,
              ),
              constraints: BoxConstraints.expand(),
              alignment: Alignment.center,
            ),
            actions: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                  child: MaterialButton(
                    color: themeData.primaryColor,
                    textColor: themeData.secondaryHeaderColor,
                    child: Text('Update'),
                    onPressed: () {
                      _handleSubmitted();
                      Navigator.pop(context);
                    },
                  ))
            ]),
        body: Form(
            key: _formKey,
            autovalidate: true,
            onWillPop: () async {
              return true;
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    child: Image.network(book.cover),
                    height: 100,
                  ),
                ),
                Container(
                  child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Title",
                        hintText: "e.g. The Hound of the Baskervilles"),
                    autocorrect: false,
                    minLines: 1,
                    maxLines: 3,
                    controller: _titleController,
                    onChanged: (String value) {
                      title = value;
                    },
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                Container(
                  child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Published", hintText: "e.g. 1901"),
                    autocorrect: false,
                    controller: _dateController,
                    minLines: 1,
                    maxLines: 1,
                    onChanged: (String value) {
                      date = value;
                    },
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                Container(
                  child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Author",
                        hintText: "e.g. Arthur Conan Doyle"),
                    autocorrect: false,
                    minLines: 1,
                    maxLines: 3,
                    controller: _authorController,
                    onChanged: (String value) {
                      author = value;
                    },
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                Container(
                  child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Series", hintText: "e.g. Sherlock Holmes"),
                    autocorrect: false,
                    minLines: 1,
                    maxLines: 3,
                    controller: _seriesController,
                    onChanged: (String value) {
                      series = value;
                    },
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                Container(
                  child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Description",
                        hintText:
                            "e.g. The rich landowner Sir Charles Baskerville is found dead in the park of his manor surrounded by the grim moor of Dartmoor, in the county of Devon. His death seems to have been caused by a heart attack, but the victim's best friend, Dr. Mortimer, is convinced that the strike was due to a supernatural creature, which haunts the moor in the shape of an enormous hound, with blazing eyes and jaws. In order to protect Baskerville's heir, Sir Henry, who's arriving to London from Canada, Dr. Mortimer asks for Sherlock Holmes' help, telling him also of the so-called Baskervilles' curse, according to which a monstrous hound has been haunting and killing the family males for centuries, in revenge for the misdeeds of one Sir Hugo Baskerville, who lived at the time of Oliver Cromwell."),
                    autocorrect: false,
                    controller: _descriptionController,
                    onChanged: (String value) {
                      description = value;
                    },
                    minLines: 1,
                    maxLines: 50,
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
              ],
            )));
  }
}
