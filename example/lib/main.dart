import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:micinputtextfield/mic_input_textfield.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int noofincrement = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: MicInputTextField(
            onSend: (ou) async {
              log("OnSend");
              noofincrement = ++noofincrement;

              log(ou.toJson().toString());
              log(noofincrement.toString());
            },
          ),
        ),
      ),
    );
  }
}
