import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _loggingIn = false;

  _signup() async {
    if (_passwordController.text.trim() !=
        _passwordConfirmController.text.trim()) {
      /// notifies user that passwords do not match
      _key.currentState.showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    setState(() {
      _loggingIn = true;
    });

    _key.currentState.removeCurrentSnackBar();
    _key.currentState.showSnackBar(
      SnackBar(
        content: Text('Creating your acount...'),
      ),
    );

    try {
      FirebaseUser _user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      UserUpdateInfo info = UserUpdateInfo();
      info.displayName = _nameController.text.trim();

      await _user.updateProfile(info);

      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(
        SnackBar(
          content: Text('Your account has been created successfully.'),
        ),
      );
    } catch (e) {
      String errorMessage = (e as PlatformException).message;
      print('Console Error: $errorMessage');

      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } finally {
      setState(() {
        _loggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      key: _key,
      backgroundColor: Colors.white,
      child: Form(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 72.0, bottom: 36.0),
              child: Icon(
                Icons.wb_cloudy,
                size: 60.0,
                color: Colors.black,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              padding: const EdgeInsets.all(
                4.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(
                  20.0,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.black.withOpacity(0.5),
                    margin: EdgeInsets.only(right: 10.0),
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      controller: _nameController,
                        placeholder: "Enter your name",
                        style: TextStyle(
                          color: Colors.black.withOpacity(.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              padding: const EdgeInsets.all(
                4.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(
                  20.0,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    child: Icon(
                      Icons.alternate_email,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.black.withOpacity(0.5),
                    margin: EdgeInsets.only(right: 10.0),
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      controller: _emailController,
                        placeholder: "Enter your email",
                        style: TextStyle(
                          color: Colors.black.withOpacity(.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              padding: const EdgeInsets.all(
                4.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(
                  20.0,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    child: Icon(
                      Icons.lock_open,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.black.withOpacity(0.5),
                    margin: EdgeInsets.only(right: 10.0),
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      controller: _passwordController,

                      obscureText: true,
                        placeholder: "Enter your password",
                        style: TextStyle(
                          color: Colors.black.withOpacity(.5),
                        ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              padding: const EdgeInsets.all(
                4.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(
                  20.0,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    child: Icon(
                      Icons.lock_open,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.black.withOpacity(0.5),
                    margin: EdgeInsets.only(right: 10.0),
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      controller: _passwordConfirmController,
                      obscureText: true,
                        placeholder: "Re-enter your password",
                        style: TextStyle(
                          color: Colors.black.withOpacity(.5),
                        ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CupertinoButton(
                      color: Colors.black,
//                      disabledColor: Colors.black.withOpacity(.5),
                      onPressed:
                      _loggingIn == true ? null : () {
                        if(_nameController != null || _emailController != null || _passwordConfirmController != null || _passwordController != null) {
                          _signup();
                        }
                        },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'Sign up',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Icon(CupertinoIcons.back, color:  Colors.black,)
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
