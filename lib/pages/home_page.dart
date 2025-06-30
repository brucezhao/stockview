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
  // static const double appBarIconSize = 18;
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
  int currentIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kWindowCaptionHeight + 10),
        child: DragToMoveArea(
          child: AppBar(
            leading: IconButton(
              onPressed: () {},
              icon: Icon(Icons.menu, size: 22, color: Colors.grey.shade800),
            ),
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
      body: Column(
        children: [
          stockIndexsWidget(),
          // const Divider(height: 5, color: Colors.black12),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                if (stocks.length <= index + 3) {
                  return Container();
                }
                return stocks[index + 3].briefWidget(index == currentIndex, () {
                  setState(() {
                    currentIndex = index;
                  });
                  showStockDetail(index + 3);
                });
              },
              separatorBuilder: (context, index) {
                return Divider(color: Colors.transparent, height: 0);
              },
              itemCount: stocks.length > 3 ? stocks.length - 3 : 0,
              shrinkWrap: true,
            ),
          ),
          // const Divider(height: 5, color: Colors.black12),
          // Container(
          //   height: 300,
          //   width: double.infinity,
          //   margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
          //   child: Card(
          //     color: Colors.white,
          //     child: stocks.length > 3
          //         ? stocks[currentIndex + 3].detailWidget()
          //         : null,
          //   ),
          // ),
        ],
      ),
      // ),
      // DragToMoveArea(child: Center()),
      floatingActionButton: FloatingActionButton(
        // mini: true,
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
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          stockIndexWidget(0),
          stockIndexWidget(1),
          stockIndexWidget(2),
        ],
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

    return Column(
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
    );
  }

  void showStockDetail(int index) {
    if (index < 0 || index >= stocks.length) {
      return;
    }
    final stock = stocks[index];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
          child: stock
              .detailWidget(), //Card(color: Colors.white, child: stock.detailWidget()),
        );
      },
    );
  }
}
