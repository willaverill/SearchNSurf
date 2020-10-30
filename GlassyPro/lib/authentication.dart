import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login/flutter_login.dart';

abstract class BaseAuth {
  Future<String> signIn(LoginData data);

  Future<String> signUp(LoginData data);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(LoginData data) async {
    bool hasError = false;
    await _firebaseAuth.signInWithEmailAndPassword(email: data.name, password: data.password).catchError((Object error) {
      hasError = true;
    });
    if (!hasError) {
      return null;
    } else {
      return "Email or password is incorrect.";
    }
  }

  Future<String> signUp(LoginData data) async {
    bool hasError = false;
    await _firebaseAuth.createUserWithEmailAndPassword(email: data.name, password: data.password).catchError((Object error) {
      hasError = true;
    });
    if (!hasError) {
      return null;
    } else {
      return "Email is already taken or passwords do not match.";
    }
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<String> recoverPassword(String email) async {
    _firebaseAuth.sendPasswordResetEmail(email: email);
    return null;
  }
}