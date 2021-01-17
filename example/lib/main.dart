import 'dart:io';

import 'package:ali_real_person/fl_ali_realperson.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  void initPlatformState() async {
    String platformVersion = "1";
    try {
      String token = 'cc033bffb9xx4b53a73e4d28d24fed48';
      dynamic param;
      if (Platform.isIOS) {
        param = token;
      } else {
        param = {"token": token};
      }
      await QAliRealperson.startRealPerson(param, (result) {
        print("the realPerson result is :" + result);
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FlatButton(
              onPressed: () => initPlatformState(), child: Text("点击测试实人认证")),
        ),
      ),
    );
  }
}
