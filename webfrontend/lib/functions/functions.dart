import 'dart:convert';
import 'dart:js_util';
import '../widgets/javascript_controller.dart';

//get my Balances from Moralis
Future getBalances() async {
  var myBalances = [];
  var ethbalance = await getMyEthBalance();
  Map eth = {
    "name": "Ether",
    "symbol": "Eth",
    "balance": ethbalance,
    "decimals": "18"
  };
  myBalances.add(eth);

  var promise = getTokenBalances();
  var balance = await promiseToFuture(promise);
  for (var i = 0; i < balance.length; i++) {
    myBalances.add(json.decode(balance[i]));
  }
  return myBalances;
}

//get my EthBalance from Moralis
Future getMyEthBalance() async {
  var promise = getEthBalance();
  var ethbalance = await promiseToFuture(promise);
  return ethbalance;
}

//get my Transactions from Moralis
Future getAllMyTransactions() async {
  var promise = getMyTransactions();
  var transactions = await promiseToFuture(promise);
  var transactionsdecoded = json.decode(transactions);
  return transactionsdecoded;
}

//get all my Assests
Future getMyAssets() async {
  var tokens = await getBalances();
  return tokens;
}

//Limit Order
Future newLimitOrder(List _arguments) async {
  int _side = _arguments[0];
  String _ticker = _arguments[1];
  String _amount = _arguments[2];
  String _price = _arguments[3];
  var promise = createLimitOrder(_side, _ticker, _amount, _price);
  var order = await promiseToFuture(promise);
}

Future newMarketOrder(List _arguments) async {
  int _side = _arguments[0];
  String _ticker = _arguments[1];
  String _amount = _arguments[2];
  var promise = createMarketOrder(_side, _ticker, _amount);
  var order = await promiseToFuture(promise);
}

Future getOrderbook(List _arguments) async {
  int _side = _arguments[0];
  String _ticker = _arguments[1];
  var promise = getOrderBook(_ticker, _side);
  var orderbook = await promiseToFuture(promise);
  print(orderbook);
  return orderbook;
}

Future getTokenlist() async {
  var promise = getTokens();
  var tokens = await promiseToFuture(promise);
  print(tokens);
  return tokens;
}

Future depositNewToken(List _arguments) async {
  String _amount = _arguments[0];
  String _ticker = _arguments[1];
  var promise = depositToken(_amount, _ticker);
  var deposit = await promiseToFuture(promise);
}

Future withdrawNewToken(List _arguments) async {
  String _amount = _arguments[0];
  String _ticker = _arguments[1];
  var promise = withdrawToken(_amount, _ticker);
  var withdraw = await promiseToFuture(promise);
}

Future depositNewEth(List _arguments) async {
  String _amount = _arguments[0];
  var promise = depositEth(_amount);
  var deposit = await promiseToFuture(promise);
}

Future withdrawNewEth(List _arguments) async {
  String _amount = _arguments[0];
  var promise = withdrawEth(_amount);
  var deposit = await promiseToFuture(promise);
}

Future addNewToken(List _arguments) async {
  String _ticker = _arguments[0];
  String _address = _arguments[1];
  var promise = addToken(_ticker, _address);
  var adding = await promiseToFuture(promise);
}
