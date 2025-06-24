import 'package:flutter/material.dart';
import 'package:stockview/main.dart';
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
    );
  }
}
