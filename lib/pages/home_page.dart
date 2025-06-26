import 'package:flutter/material.dart';
import 'package:stockview/main.dart';
import 'package:stockview/network/httputils.dart';
import 'package:stockview/stocks/stockparse.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double appBarIconSize = 18;

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
      body: DragToMoveArea(child: Center()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final res = HttpUtil().getText(
            "https://qt.gtimg.cn/q=sz300599,sz399001",
          );
          res.then((value) {
            StockParse parse = StockParse();
            parse.parse(value.data.toString());
          });
        },
        // elevation: 10,
        mini: true,
        // shape: const CircleBorder(),
        tooltip: '添加股票',
        child: const Icon(Icons.add),
      ),
    );
  }
}
