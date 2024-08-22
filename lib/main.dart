import 'package:flutter/material.dart';
import 'package:presensi_flutter_new/home-page.dart';
import 'package:presensi_flutter_new/login-page.dart';
import 'package:presensi_flutter_new/simpan-page.dart';
import 'package:presensi_flutter_new/registration-page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}
