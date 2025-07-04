import 'dart:async';
import 'dart:io';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockview/main.dart';
import 'package:stockview/network/httputils.dart';
import 'package:stockview/stocks/stock.dart';
import 'package:stockview/stocks/stockparse.dart';
import 'package:stockview/stocks/stockurls.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

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
    "sz002581",
    "sh600380",
    "sz300599",
  ];
  List<Stock> stocks = [];
  int currentIndex = -1;
  // 定时器
  Timer? timer;

  SysTray sysTray = SysTray(appTitle);

  // 启动定时器
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      List<Stock> tempStocks = await getStocks(stockCodes);

      if (tempStocks.isNotEmpty) {
        stocks.clear();
        stocks.addAll(tempStocks);
      }

      setState(() {});
    });
  }

  // 停止定时器
  void stopTimer() {
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();

    startTimer();
    sysTray.init();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  // void initTray() async {
  //   String path = Platform.isWindows
  //       ? 'assets/app_icon.ico'
  //       : 'assets/images/icons/main_up.png';

  //   final AppWindow appWindow = AppWindow();
  //   final SystemTray systemTray = SystemTray();

  //   // We first init the systray menu
  //   await systemTray.initSystemTray(title: "system tray", iconPath: path);

  //   // create context menu
  //   final Menu menu = Menu();
  //   await menu.buildFrom([
  //     MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
  //     MenuItemLabel(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
  //     MenuItemLabel(label: 'Exit', onClicked: (menuItem) => appWindow.close()),
  //   ]);

  //   // set context menu
  //   await systemTray.setContextMenu(menu);

  //   // handle system tray event
  //   systemTray.registerSystemTrayEventHandler((eventName) {
  //     debugPrint("eventName: $eventName");
  //     if (eventName == kSystemTrayEventClick) {
  //       Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
  //     } else if (eventName == kSystemTrayEventRightClick) {
  //       Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
  //     }
  //   });
  // }

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
        ],
      ),
      // ),
      // DragToMoveArea(child: Center()),
      floatingActionButton: FloatingActionButton(
        // mini: true,
        onPressed: () async {
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

    return GestureDetector(
      onTap: () => showStockDetail(index),
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
