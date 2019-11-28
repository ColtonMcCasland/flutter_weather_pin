import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:f_nav/pages/mapspage.dart';
import 'package:f_nav/pages/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_icons/weather_icons.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/logout';


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
        return MapsPage();
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
      backgroundColor: Colors.white,
      body: Form(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 72.0, bottom: 36.0),
              child: Icon(
                CupertinoIcons.location,

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
                      CupertinoIcons.mail,
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
                    child:

                    CupertinoTextField(
                      controller: _emailController,
                      style: TextStyle(
                        color: Colors.black,
                      ),


                      placeholder: 'Enter your email',

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
                      CupertinoIcons.padlock,
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
                    child:



                    CupertinoTextField(
                      controller: _passwordController,
                      style: TextStyle(
                        color: Colors.black,
                      ),


//                  decoration: InputDecoration(
//            hintText: 'Marker title',
//              errorText: _validate1 ? 'Value Can\'t Be Empty' : null,
//            border: InputBorder.none,
//            ),
                      placeholder: 'Enter your password',

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
                      disabledColor: Colors.black.withOpacity(0.5),
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
                              const EdgeInsets.symmetric(vertical: 1.0),
                              child:

                              CupertinoButton(
                                child: Text(
                                  'Login',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                borderRadius: BorderRadius.all(Radius.elliptical(50.0,50)),

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
                              child:
                              CupertinoButton(
                                child: Text(
                                  'Dont have an Account?  Create one.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
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
