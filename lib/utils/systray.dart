// 封装Tray功能
// import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class SysTray {
  static const defaultIcon = "assets/images/icons/main_up.png";
  static const iconUp = "assets/images/icons/main_up.png";
  static const iconDown = "assets/images/icons/main_down.png";

  final Menu _menu = Menu();
  final AppWindow _appWindow = AppWindow();
  final SystemTray _systemTray = SystemTray();

  final String title;

  SysTray(this.title);

  void init() async {
    await _systemTray.initSystemTray(iconPath: defaultIcon);
    // await _systemTray.setTitle(title);

    await _menu.buildFrom([
      MenuItemLabel(label: 'Show', onClicked: (menuItem) => _showApp()),
      MenuItemLabel(label: 'Hide', onClicked: (menuItem) => _hideApp()),
      MenuItemLabel(label: 'Exit', onClicked: (menuItem) => _appWindow.close()),
    ]);

    // set context menu
    await _systemTray.setContextMenu(_menu);

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        // Platform.isWindows ? _appWindow.show() : _systemTray.popUpContextMenu();
        if (Platform.isWindows) {
          // if ( windowManager.isVisible()) {
          windowManager.hide();
          // } else {
          //   windowManager.show();
          //   windowManager.focus();
          // }
        } else {
          _systemTray.popUpContextMenu();
        }
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? _systemTray.popUpContextMenu() : _appWindow.show();
      }
    });
  }

  void _showApp() async {
    await windowManager.show();
    await windowManager.focus();
  }

  void _hideApp() async {
    await _appWindow.hide();
  }

  void up() async {
    // await _systemTray.setTitle(title);
    await _systemTray.setImage(iconUp);
  }

  void down() async {
    await _systemTray.setImage(iconDown);
  }

  void setTitle(String title) async {
    await _systemTray.setTitle(title);
  }
}
