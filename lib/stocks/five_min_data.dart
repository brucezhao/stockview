// 5分钟行情数据
/*
http://money.finance.sina.com.cn/quotes_service/api/json_v2.php/CN_MarketData.getKLineData?symbol=[市场][股票代码]&scale=[周期]&ma=no&datalen=[长度]

返回结果：获取5、10、30、60分钟JSON数据；day日期、open开盘价、high最高价、low最低价、close收盘价、volume成交量；向前复权的数据。

注意，最多只能获取最近的1023个数据节点。

例如，https://money.finance.sina.com.cn/quotes_service/api/json_v2.php/CN_MarketData.getKLineData?symbol=sz300599&scale=60&ma=no&datalen=4，
获取深圳市场002095股票的60分钟数据，获取最近的1023个节点。
[
{"day":"2025-07-08 10:30:00","open":"8.650","high":"8.670","low":"8.530","close":"8.600","volume":"1732600"},
{"day":"2025-07-08 11:30:00","open":"8.600","high":"8.770","low":"8.600","close":"8.740","volume":"1345600"},
{"day":"2025-07-08 14:00:00","open":"8.730","high":"8.790","low":"8.720","close":"8.750","volume":"1114900"},
{"day":"2025-07-08 15:00:00","open":"8.750","high":"8.760","low":"8.710","close":"8.750","volume":"917100"}
]
*/

import 'dart:convert';

// import 'package:flutter/material.dart';
import 'package:stockview/stocks/market_timezone.dart';

import '../network/httputils.dart';
import 'stockurls.dart';

class FiveMinData {
  String date = "";
  int day = 0;
  int time = 0;
  double open = 0.0;
  double high = 0.0;
  double low = 0.0;
  double close = 0.0;
  int volume = 0;

  FiveMinData(Map<String, dynamic> json) {
    date = json["day"];
    day = int.parse(date.split(" ")[0].replaceAll("-", ""));
    time = int.parse(date.split(" ")[1].replaceAll(":", "")) ~/ 100;
    open = double.parse(json["open"]);
    high = double.parse(json["high"]);
    low = double.parse(json["low"]);
    close = double.parse(json["close"]);
    volume = int.parse(json["volume"]);
  }
}

class FiveMinDatas {
  final String code;
  List<FiveMinData> datas = [];

  // 构造函数
  FiveMinDatas(this.code);

  Future<List<double>> getDatas(double price) async {
    DateTime now = DateTime.now();
    int count = marketTimezone.count(now);
    int day = now.year * 10000 + now.month * 100 + now.day;

    String sUrl = "$cUrlFiveMin?symbol=$code&scale=5&ma=no&datalen=$count";
    final res = await HttpUtil().getText(sUrl);
    if (res.code == 0) {
      // 将sData转换为json格式
      List<dynamic> json = jsonDecode(res.data);
      datas.clear();
      for (var item in json) {
        FiveMinData data = FiveMinData(item);
        if (data.day == day) {
          datas.add(data);
        }
      }
    }

    final prices = datasToList(price);
    return prices;
  }

  // price为当前价格
  List<double> datasToList(double price) {
    final List<double> prices = [];

    if (datas.isEmpty) {
      return prices;
    }

    prices.add(datas[0].open);
    for (int i = 1; i < datas.length; i++) {
      prices.add(datas[i].close);
    }

    DateTime now = DateTime.now();
    int time = now.hour * 100 + now.minute;
    if (time >= 930 && time <= 1530) {
      // 在交易时间段内
      int iCount = datas.length;
      if (time < datas[iCount - 1].time) {
        // 如果当前时间在数据的最后一个时间之前，则修改最后的数据
        prices[prices.length - 1] = price;
      }
    }

    return prices;
  }
}
