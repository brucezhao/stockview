import 'dart:async';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockview/main.dart';
import 'package:stockview/network/httputils.dart';
import 'package:stockview/stocks/five_min_data.dart';
import 'package:stockview/stocks/market_timezone.dart';
import 'package:stockview/stocks/stock.dart';
import 'package:stockview/stocks/stockparse.dart';
import 'package:stockview/stocks/stockurls.dart';
// import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import '../stocks/price_chart.dart';
import '../utils/data_saver.dart';
import '../utils/systray.dart';

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
    // "sz002581",
    // "sh600380",
    // "sz300599",
  ];
  List<Stock> stocks = [];
  // 保存每支股票对应的5分钟数据
  late FiveMinDatasManager fiveMinDatasManager;
  // 当前选中的股票
  int currentIndex = -1;
  // 定时器
  Timer? timer;
  bool isGettingStock = false;

  SysTray sysTray = SysTray(appTitle);
  DataSaver dataSaver = DataSaver();
  // bool isLoaded = false; // 是否已经读入数据

  // 启动定时器
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      setState(() {});

      if (!marketTimezone.inTrading(DateTime.now())) return;
    });
  }

  // 停止定时器
  void stopTimer() {
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    loadData();
    // getStocks(stockCodes);

    // fiveMinDatasManager = FiveMinDatasManager(stockCodes);
    // fiveMinDatasManager.init();

    startTimer();
    sysTray.init();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

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
              WindowCaptionButton.close(onPressed: () => windowManager.hide()),
            ],
            centerTitle: false,
          ),
        ),
      ),
      body: FutureBuilder(
        future: getStocks(stockCodes),
        builder: (context, snapshot) {
          return Column(
            children: [
              stockIndexsWidget(),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    if (stocks.length <= index + 3) {
                      return Container();
                    }
                    return stocks[index + 3].briefWidget(
                      index == currentIndex,
                      () {
                        setState(() {
                          currentIndex = index;
                        });
                        showStockDetail(index + 3);
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(color: Colors.transparent, height: 0);
                  },
                  itemCount: stocks.length > 3 ? stocks.length - 3 : 0,
                  shrinkWrap: true,
                ),
              ),
            ],
          );
        },
      ),
      // ),
      // DragToMoveArea(child: Center()),
      floatingActionButton: FloatingActionButton(
        // mini: true,
        onPressed: () async {
          await addStock();
          setState(() {});
        },
        shape: const CircleBorder(),
        tooltip: '添加股票',
        child: const Icon(Icons.add),
      ),
    );
  }

  // 获取股票实时数据
  Future<List<Stock>> getStocks(List<String> codes) async {
    if (isGettingStock) {
      return [];
    }
    isGettingStock = true;
    List<Stock> tempStocks = [];
    // String datas = "";

    try {
      if (codes.isEmpty) {
        return [];
      }

      String sStocks = codes.join(",");
      final res = await HttpUtil().getText("$cUrlRealtime$sStocks");
      if (res.code == 0) {
        // datas = res.data.toString();
        // dataSaver.saveStockDatas(datas);

        parse.parse(res.data.toString());
        tempStocks = parse.stocks;
      }
    } finally {
      isGettingStock = false;
    }

    if (tempStocks.isNotEmpty) {
      stocks.clear();
      stocks.addAll(tempStocks);

      // 将数据添加到5分钟曲线中
      for (int i = 0; i < stocks.length; i++) {
        fiveMinDatasManager.addStock(stocks[i]);
        stocks[i].fiveMinDatas = fiveMinDatasManager.fiveMinDatas(
          stocks[i].codeEx,
        );
      }

      // 取沪指，后面可以自定义指数
      final stock = stocks[0];
      if (stock.increase >= 0) {
        sysTray.up();
      } else {
        sysTray.down();
      }
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

    return GestureDetector(
      onTap: () => showStockDetail(index),
      child: Row(
        children: [
          Column(
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
          const SizedBox(width: 5),
          CustomPaint(
            size: const Size(50, 20),
            painter: PriceChart(stock.fiveMinDatas.toDoubleList(), stock.color),
          ),
        ],
      ),
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

  Future<bool> loadData() async {
    final codes = await dataSaver.loadStockCodes();
    if (codes.isNotEmpty) {
      stockCodes.clear();
      stockCodes.addAll(codes);
    }

    fiveMinDatasManager = FiveMinDatasManager(stockCodes);
    fiveMinDatasManager.init();

    return true;
  }

  // 添加股票
  final TextEditingController _controller = TextEditingController();
  Future<void> addStock() async {
    _controller.clear();

    String? res = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("添加股票"),
          content: Container(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: "sh/sz+股票代码"),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(""),
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                String res = "";
                if (stockCodes.contains(_controller.text)) {
                  res = "已存在该股票";
                } else {
                  stockCodes.add(_controller.text);
                  dataSaver.saveStockCodes(stockCodes);
                  res = "添加成功";
                }

                Navigator.of(context).pop(res);
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );

    if (res != null && res.isNotEmpty) {
      showSnackBar(res);
    }
  }

  // 删除股票
  Future removeStock() async {}

  // 显示snackbar
  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
