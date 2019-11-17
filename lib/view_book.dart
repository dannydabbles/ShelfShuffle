import 'package:flutter/material.dart';

class EditBookView extends StatefulWidget {
  @override
  _EditBookViewState createState() => _EditBookViewState();
}

class _EditBookViewState extends State<EditBookView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      print('Please fix the errors in red before submitting.');
    } else {
      print('Validated!');
    }
  }

  // controllers for form text controllers
  final TextEditingController _firstNameController = TextEditingController();
  String firstName = "TestFirst";
  final TextEditingController _lastNameController = TextEditingController();
  String lastName = "TestName";

  @override
  void initState() {
    _firstNameController.text = firstName;
    _lastNameController.text = lastName;
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final DateTime today = DateTime.now();

    return Scaffold(
        appBar: AppBar(title: const Text('Edit Book'), actions: <Widget>[
          Container(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 5.0, 10.0),
              child: MaterialButton(
                color: themeData.primaryColor,
                textColor: themeData.secondaryHeaderColor,
                child: Text('Save'),
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
                Container(
                  child: TextField(
                    decoration: const InputDecoration(
                        labelText: "First Name",
                        hintText: "What do people call you?"),
                    autocorrect: false,
                    controller: _firstNameController,
                    onChanged: (String value) {
                      firstName = value;
                    },
                  ),
                ),
                Container(
                  child: TextField(
                    decoration: const InputDecoration(labelText: "Last Name"),
                    autocorrect: false,
                    controller: _lastNameController,
                    onChanged: (String value) {
                      lastName = value;
                    },
                  ),
                ),
              ],
            )));
  }
}
