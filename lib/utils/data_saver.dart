import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockview/stocks/stock.dart';

import '../stocks/stockparse.dart';

class DataSaver {
  static const String _keyStockCodes = 'codes';
  static const String _keyStockDatas = 'datas';

  Future<void> saveStockCodes(List<String> codes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyStockCodes, codes);
  }

  Future<List<String>> loadStockCodes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyStockCodes) ?? [];
  }

  Future<void> saveStockDatas(String datas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStockDatas, datas);
  }

  Future<List<Stock>> loadStockDatas() async {
    final prefs = await SharedPreferences.getInstance();
    String datas = prefs.getString(_keyStockDatas) ?? "";
    if (datas.isEmpty) {
      return [];
    }

    List<Stock> stocks = [];
    final StockParse parse = StockParse();
    parse.parse(datas);
    stocks = parse.stocks;

    return stocks;
  }
}
