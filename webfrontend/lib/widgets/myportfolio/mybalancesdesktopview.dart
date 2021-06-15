import 'dart:math';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:web_app_template/functions/functions.dart';
import 'package:web_app_template/widgets/buttons/button.dart';
import 'package:web_app_template/widgets/inputfields/inputField.dart';

class MyBalancesDesktopView extends StatefulWidget {
  final List myBalances;

  MyBalancesDesktopView(this.myBalances);

  @override
  _MyBalancesDesktopViewState createState() => _MyBalancesDesktopViewState();
}

class _MyBalancesDesktopViewState extends State<MyBalancesDesktopView> {
  var amount;
  List controllers = [];
  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < widget.myBalances.length; i++) {
      controllers.add(new TextEditingController());
    }
    print(widget.myBalances);
    return widget.myBalances != []
        ? SingleChildScrollView(
            child: Row(
              children: [
                Container(
                  height: 500,
                  width: MediaQuery.of(context).size.width - 170,
                  child: Card(
                    color: Theme.of(context).primaryColor,
                    child: DataTable2(
                      columns: [
                        DataColumn(
                            label: Text(
                          "Name",
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        )),
                        DataColumn(
                            label: Text(
                          "Symbol",
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        )),
                        DataColumn(
                            label: Text(
                          "Balance",
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        )),
                        DataColumn(
                            label: Text(
                          "Deposit Funds in Dex",
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        )),
                        DataColumn(
                            label: Text(
                          "Add Token (only Exchangeadmin)",
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        )),
                      ],
                      rows: widget.myBalances
                          .map(
                            ((element) => DataRow(
                                  cells: [
                                    DataCell(Text(
                                      element["name"],
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).highlightColor),
                                    )),
                                    DataCell(Text(
                                      element["symbol"],
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).highlightColor),
                                    )),
                                    DataCell(Text(
                                      (int.parse(element["balance"]) /
                                              pow(
                                                  10,
                                                  int.parse(
                                                      element["decimals"])))
                                          .toStringAsFixed(5),
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).highlightColor),
                                    )),
                                    DataCell(
                                      Row(
                                        children: [
                                          inputField(
                                            ctx: context,
                                            controller: controllers[widget
                                                .myBalances
                                                .indexOf(element)],
                                            labelText: "Input Amount",
                                            leftMargin: 0,
                                            topMargin: 0,
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
                                          element["symbol"] == "Eth"
                                              ? button(
                                                  Theme.of(context).buttonColor,
                                                  Theme.of(context)
                                                      .highlightColor,
                                                  "Deposit Eth",
                                                  depositNewEth,
                                                  [amount])
                                              : button(
                                                  Theme.of(context).buttonColor,
                                                  Theme.of(context)
                                                      .highlightColor,
                                                  "Deposit Token",
                                                  depositNewToken,
                                                  [amount, element["symbol"]])
                                        ],
                                      ),
                                    ),
                                    DataCell(element["address"] != null
                                        ? button(
                                            Theme.of(context).buttonColor,
                                            Theme.of(context).highlightColor,
                                            "Add Token",
                                            addNewToken, [
                                            element["symbol"],
                                            element["address"]
                                          ])
                                        : Container()),
                                  ],
                                )),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
