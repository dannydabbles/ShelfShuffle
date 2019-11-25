import 'package:flutter/material.dart';

class ExpandingFab extends StatefulWidget {
  final Function() barcodeScanner;
  final Function() lookUpISBN;
  final Function() lookUpCover;

  ExpandingFab({this.barcodeScanner, this.lookUpISBN, this.lookUpCover});

  @override
  _ExpandingFabState createState() => _ExpandingFabState(
        barcodeScanner: this.barcodeScanner,
        lookUpISBN: this.lookUpISBN,
        lookUpCover: this.lookUpCover,
      );
}

class _ExpandingFabState extends State<ExpandingFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  final Function() barcodeScanner;
  final Function() lookUpISBN;
  final Function() lookUpCover;

  _ExpandingFabState({this.barcodeScanner, this.lookUpISBN, this.lookUpCover});

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.grey,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget addCover() {
    return Container(
      child: FloatingActionButton(
        heroTag: 3,
        onPressed: this.lookUpCover,
        tooltip: 'Scan book cover',
        child: Icon(Icons.camera),
      ),
    );
  }

  Widget addBarcode() {
    return Container(
      child: FloatingActionButton(
        heroTag: 2,
        onPressed: this.barcodeScanner,
        tooltip: 'Scan barcode',
        child: RotationTransition(
            turns: AlwaysStoppedAnimation(90 / 360),
            child: Icon(Icons.line_weight)),
      ),
    );
  }

  Widget addISBN() {
    return Container(
      child: FloatingActionButton(
        heroTag: 1,
        onPressed: this.lookUpISBN,
        tooltip: 'Enter ISBN',
        child: Icon(Icons.library_add),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: 0,
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Add a book',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 3.0,
            0.0,
          ),
          child: addCover(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: addBarcode(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: addISBN(),
        ),
        toggle(),
      ],
    );
  }
}
