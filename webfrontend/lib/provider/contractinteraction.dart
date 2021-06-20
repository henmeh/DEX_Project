import 'dart:math';

import 'package:flutter/material.dart';
import 'package:js/js_util.dart';
import '../widgets/javascript_controller.dart';

class Contractinteraction with ChangeNotifier {
  var _tx;

  String get tx {
    return _tx;
  }

  setTxHash() {
    _tx = "pending";
    notifyListeners();
  }

  //Limit Order
  Future newLimitOrder(List _arguments) async {
    setTxHash();
    int _side = _arguments[0];
    String _ticker = _arguments[1];
    String _amount = _arguments[2];
    String _price = _arguments[3];
    var promise = createLimitOrder(_side, _ticker, _amount, _price);
    var order = await promiseToFuture(promise);
    _tx = order.toString();
    notifyListeners();
  }

  Future newMarketOrder(List _arguments) async {
    setTxHash();
    int _side = _arguments[0];
    String _ticker = _arguments[1];
    String _amount = _arguments[2];
    var promise = createMarketOrder(_side, _ticker, _amount);
    var order = await promiseToFuture(promise);
    _tx = order.toString();
    notifyListeners();
  }

  Future depositNewToken(List _arguments) async {
    setTxHash();
    String _amount = _arguments[0];
    String _ticker = _arguments[1];
    String _decimals = _arguments[2];
    double _depositAmount =
        double.parse(_amount) * pow(10, int.parse(_decimals));
    var promise = depositToken(_depositAmount.toString(), _ticker);
    var deposit = await promiseToFuture(promise);
    _tx = deposit.toString();
    notifyListeners();
  }

  Future withdrawNewToken(List _arguments) async {
    setTxHash();
    String _amount = _arguments[0];
    String _ticker = _arguments[1];
    String _decimals = _arguments[2];
    double _withdrawAmount =
        double.parse(_amount) * pow(10, int.parse(_decimals));
    var promise = withdrawToken(_withdrawAmount.toString(), _ticker);
    var withdraw = await promiseToFuture(promise);
    _tx = withdraw.toString();
    notifyListeners();
  }

  Future depositNewEth(List _arguments) async {
    setTxHash();
    String _amount = _arguments[0];
    var promise = depositEth(_amount);
    var deposit = await promiseToFuture(promise);
    _tx = deposit.toString();
    notifyListeners();
  }

  Future withdrawNewEth(List _arguments) async {
    setTxHash();
    String _amount = _arguments[0];
    var promise = withdrawEth(_amount);
    var deposit = await promiseToFuture(promise);
    _tx = deposit.toString();
    notifyListeners();
  }

  Future addNewToken(List _arguments) async {
    setTxHash();
    String _ticker = _arguments[0];
    String _address = _arguments[1];
    var promise = addToken(_ticker, _address);
    var adding = await promiseToFuture(promise);
    _tx = adding.toString();
    notifyListeners();
  }
}
