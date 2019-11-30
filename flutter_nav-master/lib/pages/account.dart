import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AccountScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Account"),
      ),
      child: Container(
          child: Center(
        child: Text("Account Screen"),
      )),
    );
  }
}
