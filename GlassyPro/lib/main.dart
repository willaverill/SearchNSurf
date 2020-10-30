import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/flutter_login.dart';
import 'authentication.dart';
import 'main_page.dart';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  @override
  _LoginAppState createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginPage> {
  Auth auth = new Auth();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GlassyPro',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          accentColor: Colors.cyan,
          cursorColor: Colors.cyan,
          textTheme: TextTheme(
            display2: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 45.0,
              color: Colors.black,
            ),
            button: TextStyle(
              fontFamily: 'OpenSans',
            ),
            subhead: TextStyle(fontFamily: 'NotoSans'),
            body1: TextStyle(fontFamily: 'NotoSans'),
          ),
        ),
        home: Builder(
            builder: (context) => Center(
                child: FlutterLogin(
                  title: 'GlassyPro',
                  logo: 'assets/images/logo.png',
                  onLogin: auth.signIn,
                  onSignup: auth.signUp,
                  onSubmitAnimationCompleted: () {
                    Auth().getCurrentUser().then((FirebaseUser user) {
                      Firestore.instance.collection('settings')
                          .document(user.uid)
                          .get()
                          .then((DocumentSnapshot ds) {
                        if (!ds.exists) {
                          Firestore.instance.collection('settings').document(
                              user.uid)
                              .setData({
                            'wave_height': true,
                            'wind_speed': true,
                            'temperature': true
                          });
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainPage()),
                        );
                      });
                    });
                  },
                  onRecoverPassword: auth.recoverPassword,
                )
            )
        )
    );
  }
}
