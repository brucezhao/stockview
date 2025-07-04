import 'package:flutter/material.dart';
import 'package:stockview/stocks/stockurls.dart';
// 以 ~ 分割字符串中内容，下标从0开始，依次为
//  0: 未知
//  1: 名字
//  2: 代码
//  3: 当前价格
//  4: 昨收
//  5: 今开
//  6: 成交量（手）
//  7: 外盘
//  8: 内盘
//  9: 买一
// 10: 买一量（手）
// 11-18: 买二 买五
// 19: 卖一
// 20: 卖一量
// 21-28: 卖二 卖五
// 29: 最近逐笔成交
// 30: 时间
// 31: 涨跌
// 32: 涨跌%
// 33: 最高
// 34: 最低
// 35: 价格/成交量（手）/成交额
// 36: 成交量（手）
// 37: 成交额（万）
// 38: 换手率
// 39: 市盈率
// 40:
// 41: 最高
// 42: 最低
// 43: 振幅
// 44: 流通市值
// 45: 总市值
// 46: 市净率
// 47: 涨停价
// 48: 跌停价

// 字段的索引值
enum FieldIndex {
  indexHeader, //头部
  indexName, // 名字
  indexCode, // 代码
  indexPrice, // 当前价格
  indexLastclose, // 昨收
  indexOpen, // 今开
  indexTotalcount, // 成交量（手）
  indexBuy, //外盘（买入）
  indexSale, //内盘（卖出）
  indexBuy1,
  indexBuyVolume1,
  indexBuy2,
  indexBuyVolume2,
  indexBuy3,
  indexBuyVolume3,
  indexBuy4,
  indexBuyVolume4,
  indexBuy5,
  indexBuyVolume5,
  indexSale1,
  indexSaleVolume1,
  indexSale2,
  indexSaleVolume2,
  indexSale3,
  indexSaleVolume3,
  indexSale4,
  indexSaleVolume4,
  indexSale5,
  indexSaleVolume5,
  indexLastdeal, //最近逐笔成交
  indexTime, //包含日期的时间，20250619140814
  indexIncrease, //涨跌
  indexIncreaseRate, //涨跌%
  indexHighest, //最高
  indexLowest, //最低
  indexPriceCountMoney, //价格/成交量（手）/成交额
  indexCount, //成交量（手）
  indexMoney, //成交额（万）
  indexChangeRate, // 换手率
  indexEarnRate, // 市盈率
  indexBlank1, // 空白
  indexHighest2, // 最高
  indexLowest2, // 最低
  indexAmplitude, // 振幅
  indexCirculationValue, // 流通市值
  indexTotalValue, // 总市值
  indexNetRate, // 市净率
  indexLimitUp, // 涨停价
  indexLimitDown, // 跌停价
}

class Stock {
  // 字段数
  static const fieldCount = 38;

  String codeEx = "";
  String code = "";
  double openPrice = 0.0;
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
    openPrice = getDoubleData(FieldIndex.indexOpen.index);
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

  Widget briefWidget(bool selected, final VoidCallback? onTap) {
    String sIncreaseRate = getData(FieldIndex.indexIncreaseRate.index);
    sIncreaseRate = "${increase >= 0 ? "+" : ""}$sIncreaseRate%";
    String sIncrease = getData(FieldIndex.indexIncrease.index);
    sIncrease = "${increase >= 0 ? "+" : ""}$sIncrease";

    return Container(
      height: 74,

      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Card(
        color: Colors.white,
        // color: selected
        //     ? const Color.fromARGB(255, 253, 241, 223)
        //     : Colors.white,
        child: ListTile(
          onTap: onTap,
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
          trailing: SizedBox(
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

  Widget detailWidget() {
    String url = "$codeEx.gif?${DateTime.now().millisecondsSinceEpoch}";
    final textStye = TextStyle(fontSize: 13);
    final String prePlus = increase >= 0 ? "+" : "";
    // 市值
    double dTotleValue = getDoubleData(FieldIndex.indexTotalValue.index);
    String sTotleValueunit = "亿";
    if (dTotleValue > 10000) {
      dTotleValue /= 10000;
      sTotleValueunit = "万亿";
    }
    // 成交量
    double dDealCount = getDoubleData(FieldIndex.indexCount.index) / 10000;
    String sDealCountunit = "万";
    if (dDealCount > 10000) {
      dDealCount /= 10000;
      sDealCountunit = "亿";
    }

    // 成交额
    double dDealVolume = getDoubleData(FieldIndex.indexMoney.index) / 10000;
    String sDealVolume = "亿";
    if (dDealVolume > 1000) {
      dDealVolume /= 10000;
      sDealVolume = "万亿";
    }

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            height: 40,
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 5,
              bottom: 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getData(FieldIndex.indexPrice.index),
                  style: TextStyle(fontSize: 24, color: color),
                ),
                const SizedBox(width: 20),
                Text(
                  "$prePlus${getData(FieldIndex.indexIncrease.index)}",
                  style: TextStyle(fontSize: 14, color: color),
                ),
                const SizedBox(width: 20),
                Text(
                  "$prePlus${getData(FieldIndex.indexIncreaseRate.index)}%",
                  style: TextStyle(fontSize: 14, color: color),
                ),
                const Spacer(),
                Text(formatedDateTime(), style: textStye),
              ],
            ),
          ),
          Container(
            height: 50,
            alignment: Alignment.center,

            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 5,
            ),
            width: double.infinity,
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 4.0,
              children: [
                Text(
                  "高 ${getData(FieldIndex.indexHighest.index)}",
                  style: textStye,
                ),
                Text(
                  "开 ${getData(FieldIndex.indexOpen.index)}",
                  style: textStye,
                ),
                Text(
                  "市值 ${dTotleValue.toStringAsFixed(2)}$sTotleValueunit",
                  style: textStye,
                ),
                Text(
                  "成交量 ${dDealCount.toStringAsFixed(2)}$sDealCountunit",
                  style: textStye,
                ),
                Text(
                  "低 ${getData(FieldIndex.indexLowest.index)}",
                  style: textStye,
                ),
                Text(
                  "换 ${getData(FieldIndex.indexChangeRate.index)}%",
                  style: textStye,
                ),
                Text(
                  "市盈 ${getData(FieldIndex.indexEarnRate.index)}",
                  style: textStye,
                ),
                Text(
                  "成交额 ${dDealVolume.toStringAsFixed(2)}$sDealVolume",
                  style: textStye,
                ),
              ],
            ),
          ),
          const Divider(height: 2, color: Colors.black12),
          TabBar(
            tabs: [
              Tab(text: "分时"),
              Tab(text: "日K"),
              Tab(text: "周K"),
              Tab(text: "月K"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          child: Image.network(
                            "$cUrlGifMin$url",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),

                      Container(
                        alignment: Alignment.center,
                        width: 110,
                        height: double.infinity,
                        margin: const EdgeInsets.only(
                          left: 5,
                          top: 5,
                          right: 5,
                        ),
                        child: GridView.count(
                          crossAxisCount: 3,
                          childAspectRatio: 1.6,
                          children: [
                            Text("卖5", style: textStye),
                            priceText(FieldIndex.indexSale5),
                            volumeText(FieldIndex.indexSaleVolume5),
                            Text("卖4", style: textStye),
                            priceText(FieldIndex.indexSale4),
                            volumeText(FieldIndex.indexSaleVolume4),
                            Text("卖3", style: textStye),
                            priceText(FieldIndex.indexSale3),
                            volumeText(FieldIndex.indexSaleVolume3),
                            Text("卖2", style: textStye),
                            priceText(FieldIndex.indexSale2),
                            volumeText(FieldIndex.indexSaleVolume2),
                            Text("卖1", style: textStye),
                            priceText(FieldIndex.indexSale1),
                            volumeText(FieldIndex.indexSaleVolume1),
                            // const Divider(height: 1, color: Colors.black12),
                            Text("买1", style: textStye),
                            priceText(FieldIndex.indexBuy1),
                            volumeText(FieldIndex.indexBuyVolume1),
                            Text("买2", style: textStye),
                            priceText(FieldIndex.indexBuy2),
                            volumeText(FieldIndex.indexBuyVolume2),
                            Text("买3", style: textStye),
                            priceText(FieldIndex.indexBuy3),
                            volumeText(FieldIndex.indexBuyVolume3),
                            Text("买4", style: textStye),
                            priceText(FieldIndex.indexBuy4),
                            volumeText(FieldIndex.indexBuyVolume4),
                            Text("买5", style: textStye),
                            priceText(FieldIndex.indexBuy5),
                            volumeText(FieldIndex.indexBuyVolume5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Image.network("$cUrlGifDay$url", fit: BoxFit.fill),
                ),
                Container(
                  child: Image.network("$cUrlGifWeek$url", fit: BoxFit.fill),
                ),
                Container(
                  child: Image.network("$cUrlGifMonth$url", fit: BoxFit.fill),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatedDateTime() {
    String sDate = getData(FieldIndex.indexTime.index);
    String s =
        "${sDate.substring(0, 4)}-${sDate.substring(4, 6)}-${sDate.substring(6, 8)} "
        "${sDate.substring(8, 10)}:${sDate.substring(10, 12)}:${sDate.substring(12, 14)}";
    return s;
  }

  Text priceText(FieldIndex index) {
    Color color = Colors.black;
    double tempPrice = getDoubleData(index.index);

    if (tempPrice == 0.0) {
      return Text("--", style: TextStyle(fontSize: 13, color: color));
    }

    if (tempPrice > openPrice) {
      color = Colors.red;
    } else if (tempPrice < openPrice) {
      color = Colors.green;
    }
    return Text(
      getData(index.index),
      style: TextStyle(fontSize: 12, color: color),
    );
  }

  Text volumeText(FieldIndex index) {
    String s = getData(index.index);
    if (s == "0") {
      s = "--";
    }

    return Text(
      s,
      style: const TextStyle(fontSize: 12),
      textAlign: TextAlign.right,
    );
  }
}
