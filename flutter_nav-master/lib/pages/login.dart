import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:f_nav/modules/homepage.dart';
import 'package:f_nav/pages/signup.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  bool _loggingIn = false;

  _login() async {
    setState(() {
      _loggingIn = true;
    });

    _key.currentState.removeCurrentSnackBar();
    _key.currentState.showSnackBar(SnackBar(
      content: Text('Loging you in ....'),
    ));

    try {
      FirebaseUser _user = await _firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(SnackBar(
        content: Text('Login successful'),
      ));

      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
        return HomePage();
      }));

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
    return Scaffold(
      key: _key,
      backgroundColor: Colors.amber,
      body: Form(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 72.0, bottom: 36.0),
              child: Icon(
                Icons.wb_cloudy,

                size: 180.0,
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
                      Icons.email,
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
                    child: TextFormField(
                      controller: _emailController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your email",
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(.5),
                        ),
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
                    child: TextFormField(
                      controller: _passwordController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your password",
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(.5),
                        ),
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
                    child: FlatButton(
                      splashColor: Colors.black,
                      color: Colors.black,
                      disabledColor: Colors.black.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onPressed: _loggingIn == true
                          ? null
                          : () {
                        _login();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'LOGIN',
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
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext ctx) {
                              return SignupPage();
                            }));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'Dont have an Account?  Create one.',
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
          ],
        ),
      ),
    );
  }
}
