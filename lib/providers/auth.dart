import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../helpers/http_exception.dart';

class Auth with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late UserCredential userCredential;

  Future<void> signInWithEmail(
      {required String email, required String password}) async {
    try {
      userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        HttpException('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        HttpException('The account already exists for that email.');
      }
      rethrow;
    } catch (e) {
      HttpException('error: $e');
      rethrow;
    }
  }

  Future<void> signUpWithEmail(
      {required String email, required String password}) async {
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final users = FirebaseFirestore.instance.collection('users');

      await users.doc(userCredential.user!.uid).set({
        'email': email,
      });
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> signOut() async {
    {
      try {
        await _auth.signOut();
      } catch (e) {
        print(e);
      }
    }
  }
}
