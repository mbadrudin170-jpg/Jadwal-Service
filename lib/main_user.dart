// path: lib/main_user.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/user/app_user.dart';
import 'package:wifi/user/firebase_option/firebase_option_user_dev.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Aktifkan cache offline Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  final prefs = await SharedPreferences.getInstance();
  runApp(AppUser(prefs: prefs));
}
