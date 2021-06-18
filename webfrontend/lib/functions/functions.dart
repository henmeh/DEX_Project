import 'dart:convert';
import 'dart:js_util';
import 'dart:math';
import '../widgets/javascript_controller.dart';

//get my Balances from Moralis
Future getBalances() async {
  var myBalances = [];
  var ethbalance = await getMyEthBalance();
  var myexchangeBalance = await getMyExchangeBalance("Eth");
  Map eth = {
    "name": "Ether",
    "symbol": "Eth",
    "balance": ethbalance,
    "decimals": "18",
    "exchangeBalance": myexchangeBalance
  };
  myBalances.add(eth);

  var promise = getTokenBalances();
  var balance = await promiseToFuture(promise);
  for (var i = 0; i < balance.length; i++) {
    var myBalance = json.decode(balance[i]);
    var myexchangeBalance = await getMyExchangeBalance(myBalance["symbol"]);
    myBalance["exchangeBalance"] = myexchangeBalance;
    myBalances.add(myBalance);
  }
  return myBalances;
}

//get my EthBalance from Moralis
Future getMyEthBalance() async {
  var promise = getEthBalance();
  var ethbalance = await promiseToFuture(promise);
  return ethbalance;
}

//get my Tokendecimals from Moralis
Future getTokenDecimals(List _arguments) async {
  String ticker = _arguments[0];
  var promise = getTokenDecimal(ticker);
  var decimals = await promiseToFuture(promise);
  return decimals;
}

Future getMyExchangeBalance(String ticker) async {
  var promise = getExchangeBalance(ticker);
  var exchangebalance = await promiseToFuture(promise);
  return exchangebalance;
}

//get my Transactions from Moralis
Future getAllMyTransactions() async {
  var promise = getMyTransactions();
  var transactions = await promiseToFuture(promise);
  var transactionsdecoded = json.decode(transactions);
  return transactionsdecoded;
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
  List orderbook = [];
  var promise = getOrderBook(_ticker, _side);
  orderbook = await promiseToFuture(promise);
  return orderbook;
}

Future getTokenlist() async {
  var promise = getTokens();
  var tokens = await promiseToFuture(promise);
  return tokens;
}

Future depositNewToken(List _arguments) async {
  String _amount = _arguments[0];
  String _ticker = _arguments[1];
  String _decimals = _arguments[2];
  double _depositAmount = double.parse(_amount) * pow(10, int.parse(_decimals));
  var promise = depositToken(_depositAmount.toString(), _ticker);
  var deposit = await promiseToFuture(promise);
}

Future withdrawNewToken(List _arguments) async {
  String _amount = _arguments[0];
  String _ticker = _arguments[1];
  String _decimals = _arguments[2];
  double _withdrawAmount =
      double.parse(_amount) * pow(10, int.parse(_decimals));
  var promise = withdrawToken(_withdrawAmount.toString(), _ticker);
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
