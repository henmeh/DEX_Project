import 'dart:math';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:provider/provider.dart';
import '../../provider/contractinteraction.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/inputfields/inputField.dart';

class MyBalancesDesktopView extends StatefulWidget {
  final List myBalances;

  MyBalancesDesktopView(this.myBalances);

  @override
  _MyBalancesDesktopViewState createState() => _MyBalancesDesktopViewState();
}

class _MyBalancesDesktopViewState extends State<MyBalancesDesktopView> {
  var amount;
  List depositControllers = [];
  List withdrawControllers = [];

  @override
  Widget build(BuildContext context) {
    if (widget.myBalances != null) {
      for (var i = 0; i < widget.myBalances.length; i++) {
        depositControllers.add(new TextEditingController());
      }
      for (var i = 0; i < widget.myBalances.length; i++) {
        withdrawControllers.add(new TextEditingController());
      }
    }
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
                          "Balance deposited in DEX",
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
                          "Withdraw Funds from Dex",
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
                                    DataCell(element["exchangeBalance"] != null
                                        ? Text(
                                            (int.parse(element[
                                                        "exchangeBalance"]) /
                                                    pow(
                                                        10,
                                                        int.parse(element[
                                                            "decimals"])))
                                                .toStringAsFixed(5),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .highlightColor),
                                          )
                                        : Text(
                                            "0",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .highlightColor),
                                          )),
                                    DataCell(
                                      Row(
                                        children: [
                                          inputField(
                                            ctx: context,
                                            controller: depositControllers[
                                                widget.myBalances
                                                    .indexOf(element)],
                                            //labelText: "",
                                            leftMargin: 0,
                                            topMargin: 0,
                                            rightMargin: 0,
                                            bottomMargin: 0,
                                            height: 40,
                                            width: 50,
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
                                                  "Deposit",
                                                  Provider.of<Contractinteraction>(
                                                          context)
                                                      .depositNewEth,
                                                  [
                                                      amount
                                                    ])
                                              : button(
                                                  Theme.of(context).buttonColor,
                                                  Theme.of(context)
                                                      .highlightColor,
                                                  "Deposit",
                                                  Provider.of<Contractinteraction>(
                                                          context)
                                                      .depositNewToken,
                                                  [
                                                      amount,
                                                      element["symbol"],
                                                      element["decimals"]
                                                    ])
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          inputField(
                                            ctx: context,
                                            controller: withdrawControllers[
                                                widget.myBalances
                                                    .indexOf(element)],
                                            //labelText: "",
                                            leftMargin: 0,
                                            topMargin: 0,
                                            rightMargin: 0,
                                            bottomMargin: 0,
                                            height: 40,
                                            width: 50,
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
                                                  "Withdraw",
                                                  Provider.of<Contractinteraction>(
                                                          context)
                                                      .withdrawNewEth,
                                                  [
                                                      amount
                                                    ])
                                              : button(
                                                  Theme.of(context).buttonColor,
                                                  Theme.of(context)
                                                      .highlightColor,
                                                  "Withdraw",
                                                  Provider.of<Contractinteraction>(
                                                          context)
                                                      .withdrawNewToken,
                                                  [
                                                      amount,
                                                      element["symbol"],
                                                      element["decimals"]
                                                    ])
                                        ],
                                      ),
                                    ),
                                    DataCell(element["address"] != null
                                        ? button(
                                            Theme.of(context).buttonColor,
                                            Theme.of(context).highlightColor,
                                            "Add Token",
                                            Provider.of<Contractinteraction>(
                                                    context)
                                                .addNewToken,
                                            [
                                                element["symbol"],
                                                element["token_address"]
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
