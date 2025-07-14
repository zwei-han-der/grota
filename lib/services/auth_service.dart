import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? usuario;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      usuario = user;
      notifyListeners();
    });
  }

  Future<UserCredential> login(String email, String senha) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
    usuario = cred.user;
    // Garante que existe o documento no Firestore
    final doc = await _firestore.collection('users').doc(usuario!.uid).get();
    if (!doc.exists) {
      await _firestore.collection('users').doc(usuario!.uid).set({
        'nome': '',
        'email': email,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    notifyListeners();
    return cred;
  }

  Future<UserCredential> registrar(String email, String senha, {String nome = ''}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
    usuario = cred.user;
    // Cria documento do usuário no Firestore
    await _firestore.collection('users').doc(usuario!.uid).set({
      'nome': nome,
      'email': email,
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
    return cred;
  }

  Future<void> logout() async {
    await _auth.signOut();
    usuario = null;
    notifyListeners();
  }

  bool get autenticado => usuario != null;
}
