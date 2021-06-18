import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  List orderBook;
  int side;
  double _maxY = 0;
  List orderData = [];
  List barData = [];
  double buyAmount = 0;
  String tokenDecimals;

  BarChartWidget({this.orderBook, this.side, this.tokenDecimals});

  @override
  Widget build(BuildContext context) {
    print(tokenDecimals);
    for (var i = 0; i < orderBook.length; i++) {
      if (double.parse(orderBook[i][4]) > _maxY) {
        _maxY = _maxY + double.parse(orderBook[i][4]);
      }
      buyAmount = buyAmount + double.parse(orderBook[i][4]);
      Map order = {
        "id": i,
        "amount": buyAmount.toString(),
        "price": (double.parse(orderBook[i][5]) / double.parse(orderBook[i][6]))
            .toString(),
      };
      orderData.add(order);
    }
    barData = side == 0 ? List.from(orderData.reversed) : orderData;
    return Container(
      height: 200,
      width: 200,
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.center,
        maxY: (_maxY / pow(10, double.parse(tokenDecimals))),
        minY: 0,
        groupsSpace: 12,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
              rotateAngle: 90,
              showTitles: true,
              getTextStyles: (value) =>
                  TextStyle(color: Theme.of(context).highlightColor),
              getTitles: (value) => barData
                  .firstWhere((element) => element["id"] == value)["price"]),
          leftTitles: side == 0
              ? SideTitles(
                  showTitles: true,
                  getTextStyles: (value) =>
                      TextStyle(color: Theme.of(context).highlightColor),
                  interval: (_maxY / pow(10, double.parse(tokenDecimals))) / 10)
              : SideTitles(showTitles: false),
          rightTitles: side == 1
              ? SideTitles(
                  showTitles: true,
                  getTextStyles: (value) =>
                      TextStyle(color: Theme.of(context).highlightColor),
                  interval: (_maxY / pow(10, double.parse(tokenDecimals))) / 10)
              : null,
        ),
        barGroups: barData
            .map((element) => BarChartGroupData(x: element["id"], barRods: [
                  BarChartRodData(
                      y: (double.parse(element["amount"]) /
                          pow(10, double.parse(tokenDecimals))),
                      colors: side == 0 ? [Colors.green] : [Colors.red])
                ]))
            .toList(),
      )),
    );
  }
}
