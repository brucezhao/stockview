// 市场的交易时间段
import 'package:flutter/material.dart';

class MarketTimezone {
  // 定义时间段
  final List<TimeOfDay> _timeSlots = [
    TimeOfDay(hour: 9, minute: 30),
    TimeOfDay(hour: 11, minute: 30),
    TimeOfDay(hour: 13, minute: 30),
    TimeOfDay(hour: 15, minute: 30),
  ];
  // 生成的数值
  final List<int> _timePoints = [];

  MarketTimezone() {
    DateTime now = DateTime.now();

    for (int i = 0; i < _timeSlots.length; i += 2) {
      TimeOfDay start = _timeSlots[i];
      TimeOfDay end = _timeSlots[i + 1];

      DateTime startTime = DateTime(
        now.year,
        now.month,
        now.day,
        start.hour,
        start.minute,
      );
      DateTime endTime = DateTime(
        now.year,
        now.month,
        now.day,
        end.hour,
        end.minute,
      );

      // 生成每个时间点
      for (
        DateTime time = startTime;
        time.isBefore(endTime);
        time = time.add(Duration(minutes: 5))
      ) {
        _timePoints.add(time.hour * 100 + time.minute);
      }
    }
  }

  int count(DateTime time) {
    int i = time.hour * 100 + time.minute;
    int index = _timePoints.where((tp) => tp <= i).length;
    return index;
  }
}

MarketTimezone marketTimezone = MarketTimezone();
