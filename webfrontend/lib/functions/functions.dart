import 'dart:convert';
import 'dart:js_util';
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
  if (balance.length != 0) {
    for (var i = 0; i < balance.length; i++) {
      var myBalance = json.decode(balance[i]);
      var myexchangeBalance = await getMyExchangeBalance(myBalance["symbol"]);
      myBalance["exchangeBalance"] = myexchangeBalance;
      myBalances.add(myBalance);
    }
  } else {
    var myHTExchangeBalance = await getMyExchangeBalance("HT");
    var myBalance = {
      "name": "HenningToken",
      "symbol": "HT",
      "balance": "0",
      "decimals": "18",
      "exchangeBalance": myHTExchangeBalance
    };
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
