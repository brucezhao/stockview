// 封装网络操作
import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';
import 'package:http/http.dart' as http;
// import 'dart:ui';

class HttpResult {
  int code = 0;
  String message = "";
  dynamic data;

  HttpResult({required this.code, required this.message, this.data});

  @override
  String toString() {
    return 'HttpResult{code: $code, message: $message, data: $data}';
  }
}

class HttpUtil {
  Future<HttpResult> getText(String url) async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      String s = gbk.decode(response.bodyBytes);
      // String s = response.body;
      if (response.statusCode == 200) {
        return HttpResult(code: 0, message: "success", data: s);
      } else {
        return HttpResult(code: -1, message: s);
      }
    } catch (e) {
      return HttpResult(code: -1, message: e.toString());
    }
  }
}
