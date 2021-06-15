@JS()
library blockchainlogic.js;

import 'dart:js';

import 'package:js/js.dart';

@JS()
external dynamic login();
external dynamic loggedIn();
external dynamic logout();
external dynamic getTokenBalances();
external dynamic getEthBalance();
external dynamic getMyTransactions();
external dynamic getTokens();
external dynamic createLimitOrder(
    int _side, String _ticker, String _amount, String _price);
external dynamic createMarketOrder(int _side, String _ticker, String _amount);
external dynamic getOrderBook(String _ticker, int _side);
external dynamic depositToken(String _amount, String _ticker);
external dynamic withdrawToken(String _amount, String _ticker);
external dynamic depositEth(String _amount);
external dynamic withdrawEth(String _amount);
external dynamic addToken(String _ticker, String _address);
