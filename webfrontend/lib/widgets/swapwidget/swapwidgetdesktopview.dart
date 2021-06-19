import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_app_template/widgets/charts/barchart.dart';
import '../../functions/functions.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/inputfields/inputField.dart';

class SwapWidgetDesktopview extends StatefulWidget {
  final TextEditingController swapamount = TextEditingController();
  @override
  _SwapWidgetDesktopviewState createState() => _SwapWidgetDesktopviewState();
}

class _SwapWidgetDesktopviewState extends State<SwapWidgetDesktopview> {
  String ticker = "HT";
  String amount;
  String price;
  TextEditingController amountLimitOrderController =
      new TextEditingController();
  TextEditingController amountMarketOrderController =
      new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  Future tokens;
  int side = 0;
  List buyOrderBook = [];
  List sellOrderBook = [];
  String decimals;

  List colors = [Colors.purpleAccent, Colors.white];
  List choosenColor = [0, 1];

  @override
  void initState() {
    tokens = getTokenlist();
    super.initState();
  }

  Future setTicker(List _arguments) async {
    buyOrderBook = await getOrderbook([0, ticker]);
    sellOrderBook = await getOrderbook([1, ticker]);
    decimals = await getTokenDecimals([ticker]);
    setState(() {
      String _ticker = _arguments[0];
      ticker = _ticker;
    });
  }

  setSide(int _side) {
    setState(() {
      side = _side;
      choosenColor = [1, 1];
      choosenColor[_side] = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    //var width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: tokens,
      builder: (ctx, tokensnapshot) {
        if (tokensnapshot.connectionState == ConnectionState.waiting) {
          return Container(
              width: (MediaQuery.of(context).size.width - 150) / 2,
              child: Center(child: CircularProgressIndicator()));
        } else {
          return Container(
            height: (MediaQuery.of(context).size.height) / 1.5,
            width: (MediaQuery.of(context).size.width - 150) / 1.5,
            child: Card(
              color: Theme.of(context).primaryColor,
              //elevation: 10,
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 500,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: tokensnapshot.data.length,
                            itemBuilder: (ctx, idx) {
                              return button(
                                  Theme.of(context).buttonColor,
                                  Theme.of(context).highlightColor,
                                  "Eth/" + tokensnapshot.data[idx],
                                  setTicker,
                                  [tokensnapshot.data[idx]]);
                            }),
                      ),
                      Row(
                        children: [
                          TextButton(
                              onPressed: () => setSide(0),
                              child: Text(
                                "Buy",
                                style:
                                    TextStyle(color: colors[choosenColor[0]]),
                              )),
                          TextButton(
                              onPressed: () => setSide(1),
                              child: Text("Sell",
                                  style: TextStyle(
                                      color: colors[choosenColor[1]]))),
                        ],
                      ),
                      Row(
                        children: [
                          inputField(
                            ctx: context,
                            controller: amountLimitOrderController,
                            labelText: "Input Tradingamount",
                            leftMargin: 0,
                            topMargin: 5,
                            rightMargin: 0,
                            bottomMargin: 0,
                            onChanged: (value) {
                              setState(() {
                                amount = value;
                              });
                            },
                            onSubmitted: (value) {
                              setState(() {
                                amount = value;
                              });
                            },
                          ),
                          inputField(
                            ctx: context,
                            controller: priceController,
                            labelText: "Input Limit Price",
                            leftMargin: 0,
                            topMargin: 5,
                            rightMargin: 0,
                            bottomMargin: 0,
                            onChanged: (value) {
                              setState(() {
                                price = value;
                              });
                            },
                            onSubmitted: (value) {
                              setState(() {
                                price = value;
                              });
                            },
                          ),
                          button(
                              Theme.of(context).buttonColor,
                              Theme.of(context).highlightColor,
                              "Place Limit Order",
                              newLimitOrder,
                              [side, ticker, amount, price])
                        ],
                      ),
                      Row(
                        children: [
                          inputField(
                            ctx: context,
                            controller: amountMarketOrderController,
                            labelText: "Input Tradingamount",
                            leftMargin: 0,
                            topMargin: 5,
                            rightMargin: 0,
                            bottomMargin: 0,
                            onChanged: (value) {
                              setState(() {
                                amount = value;
                              });
                            },
                            onSubmitted: (value) {
                              setState(() {
                                amount = value;
                              });
                            },
                          ),
                          button(
                              Theme.of(context).buttonColor,
                              Theme.of(context).highlightColor,
                              "Place Market Order",
                              newMarketOrder,
                              [side, ticker, amount])
                        ],
                      )
                    ],
                  ),
                  Container(
                      child: Row(
                    children: [
                      buyOrderBook.length == 0
                          ? Text("Empty Orderbook for Buy Side")
                          : BarChartWidget(
                              orderBook: buyOrderBook,
                              side: 0,
                              tokenDecimals: decimals),
                      sellOrderBook.length == 0
                          ? Text("Empty Orderbook for Sell Side")
                          : BarChartWidget(
                              orderBook: sellOrderBook,
                              side: 1,
                              tokenDecimals: decimals),
                    ],
                  ))
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
