import 'dart:async';

import 'package:flutter/services.dart';

class QAliRealperson {
  static const MethodChannel _channel =
      // const MethodChannel('fl_ali_realperson');
      const MethodChannel('ali_real_person');
  static Function _callBack;

  static Future<dynamic> _handler(MethodCall methodCall) {
    if ("onRealPersonResult" == methodCall.method) {
      print("onRealPersonResult: " + methodCall.arguments);
      _callBack(methodCall.arguments);
    }
    return Future.value(true);
  }

  ///  开始人脸认证
  /// [param], 如果是安卓，则是map格式{"token": 'xxxx'}, ios则是String, 'xxxxx'
  static Future<Null> startRealPerson(param, callBack) async {
    _channel.setMethodCallHandler(_handler);
    _callBack = callBack;

    await _channel.invokeMethod('startRealPerson', param);
  }
}
