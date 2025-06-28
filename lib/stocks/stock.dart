import 'package:flutter/material.dart';

// 字段的索引值
enum FieldIndex {
  indexHeader,
  indexName,
  indexCode,
  indexPrice,
  indexLastclose,
  indexOpen,
  indexTotalcount,
  indexBuy, //外盘（买入）
  indexSale, //内盘（卖出）
  indexBuy1,
  indexBuyvolume1,
  indexBuy2,
  indexBuyvolume2,
  indexBuy3,
  indexBuyvolume3,
  indexBuy4,
  indexBuyvolume4,
  indexBuy5,
  indexBuyvolume5,
  indexSale1,
  indexSalevolume1,
  indexSale2,
  indexSalevolume2,
  indexSale3,
  indexSalevolume3,
  indexSale4,
  indexSalevolume4,
  indexSale5,
  indexSalevolume5,
  indexLastdeal, //最近逐笔成交
  indexTime, //包含日期的时间，20250619140814
  indexIncrease, //涨跌
  indexIncreaseRate, //涨跌%
  indexHighest, //最高
  indexLowest, //最低
  indexPriceCountMoney, //价格/成交量（手）/成交额
  indexCount, //成交量（手）
  indexMoney, //成交量（万）
}

class Stock {
  // 字段数
  static const fieldCount = 38;

  String codeEx = "";
  String code = "";
  double increase = 0.0;
  List<String> datas = [];

  Stock(final String data) {
    datas = data.split("~");
    if (datas.length < fieldCount) {
      return;
    }

    code = datas[FieldIndex.indexCode.index];
    codeEx = datas[FieldIndex.indexHeader.index].substring(2, 10);
    increase = getDoubleData(FieldIndex.indexIncrease.index);
  }

  // 股票颜色
  Color get color {
    if (increase > 0) {
      return Colors.red;
    } else if (increase < 0) {
      return Colors.green;
    }
    return Colors.black;
  }

  // 根据索引取值
  String getData(int index) {
    if (index < 0 || index >= datas.length) {
      return "";
    }
    return datas[index];
  }

  // 取整数值
  int getIntData(int index) {
    String s = getData(index);
    if (s.isNotEmpty) {
      return int.parse(s);
    }
    return 0;
  }

  // 取浮点值
  double getDoubleData(int index) {
    String s = getData(index);
    if (s.isNotEmpty) {
      return double.parse(s);
    }
    return 0.0;
  }

  Widget briefWidget() {
    String sIncreaseRate = getData(FieldIndex.indexIncreaseRate.index);
    sIncreaseRate = "${increase >= 0 ? "+" : ""}$sIncreaseRate%";
    String sIncrease = getData(FieldIndex.indexIncreaseRate.index);
    sIncrease = "${increase >= 0 ? "+" : ""}$sIncrease%";

    return Container(
      height: 74,
      // decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Card(
        color: Colors.white,
        child: ListTile(
          title: Text(
            getData(FieldIndex.indexName.index),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey.shade800,
            ),
          ),
          subtitle: Text(
            getData(FieldIndex.indexCode.index),
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),
          trailing: Container(
            width: 260,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  getData(FieldIndex.indexPrice.index),
                  style: TextStyle(fontSize: 18, color: color),
                ),
                Text(
                  sIncreaseRate,
                  // getData(FieldIndex.indexIncreaseRate.index),
                  style: TextStyle(fontSize: 18, color: color),
                ),
                Text(
                  sIncrease,
                  // getData(FieldIndex.indexIncrease.index),
                  style: TextStyle(fontSize: 18, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
