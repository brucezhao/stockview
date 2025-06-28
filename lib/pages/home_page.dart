import 'package:flutter/material.dart';
import 'package:stockview/main.dart';
import 'package:stockview/network/httputils.dart';
import 'package:stockview/stocks/stock.dart';
import 'package:stockview/stocks/stockparse.dart';
import 'package:stockview/stocks/stockurls.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double appBarIconSize = 18;
  final StockParse parse = StockParse();
  final List<String> stockCodes = [
    "sh000001", // 沪
    "sz399001", // 深
    "sz399006", // 创
    "sz002581",
    "sh600380",
    "sz300599",
  ];
  List<Stock> stocks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kWindowCaptionHeight + 10),
        child: DragToMoveArea(
          child: AppBar(
            title: Text(
              appTitle,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            actions: [
              WindowCaptionButton.minimize(
                onPressed: () => windowManager.minimize(),
              ),
              // WindowCaptionButton.maximize(),
              WindowCaptionButton.close(
                onPressed: () => windowManager.destroy(),
              ),
            ],
            centerTitle: false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Row(children: []),
            stockIndexsWidget(),
            ListView.separated(
              itemBuilder: (context, index) {
                if (stocks.length <= index + 3) {
                  return Container();
                }
                return stocks[index + 3].briefWidget();
              },
              separatorBuilder: (context, index) {
                return Divider(color: Colors.transparent, height: 0);
              },
              itemCount: stocks.length > 3 ? stocks.length - 3 : 0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ],
        ),
      ),
      // DragToMoveArea(child: Center()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          stocks = await getStocks(stockCodes);
          setState(() {});
        },
        shape: const CircleBorder(),
        tooltip: '添加股票',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<Stock>> getStocks(List<String> codes) async {
    List<Stock> stocks = [];
    if (codes.isEmpty) {
      return stocks;
    }

    String sStocks = codes.join(",");
    final res = await HttpUtil().getText("$cUrlRealtime$sStocks");
    if (res.code == 0) {
      parse.parse(res.data.toString());
      stocks = parse.stocks;
    }

    return stocks;
  }

  Widget stockIndexsWidget() {
    if (stocks.isEmpty) {
      return Container();
    }

    return Container(
      height: 70,
      // color: Colors.yellow,
      alignment: Alignment.center,
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            stockIndexWidget(0),
            stockIndexWidget(1),
            stockIndexWidget(2),
          ],
        ),
      ),
    );
  }

  Widget stockIndexWidget(int index) {
    Stock stock = stocks[index];
    String name = "";
    if (stock.code == "000001") {
      name = "沪";
    } else if (stock.code == "399001") {
      name = "深";
    } else if (stock.code == "399006") {
      name = "创";
    }
    String increaseRate = stock.getData(FieldIndex.indexIncreaseRate.index);
    increaseRate = "${stock.increase >= 0 ? "+" : ""}$increaseRate%";

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stock.getData(FieldIndex.indexPrice.index),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: stock.color,
            ),
          ),
          Row(
            children: [
              Text(name, style: TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Text(
                increaseRate,
                style: TextStyle(color: stock.color, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
