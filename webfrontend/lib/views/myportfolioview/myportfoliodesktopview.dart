import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/provider/contractinteraction.dart';
import 'package:web_app_template/provider/loginprovider.dart';
import '../../widgets/myportfolio/mybalancesdesktopview.dart';
import '../../functions/functions.dart';
import '../../widgets/sidebar/sidebardesktop.dart';

class MyPortfolioDesktopView extends StatefulWidget {
  @override
  _MyPortfolioDesktopViewState createState() => _MyPortfolioDesktopViewState();
}

class _MyPortfolioDesktopViewState extends State<MyPortfolioDesktopView> {
  Future myAssets;
  var txold;
  var userold;
  @override
  void initState() {
    myAssets = getBalances();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tx = Provider.of<Contractinteraction>(context).tx;
    var user = Provider.of<LoginModel>(context).user;
    if (txold != tx) {
      setState(() {
        txold = tx;
        myAssets = getBalances();
      });
    }
    if (userold != user) {
      setState(() {
        userold = user;
        myAssets = getBalances();
      });
    }
    return SingleChildScrollView(
      child: Row(
        children: [
          SidebarDesktop(1),
          user != null
              ? Container(
                  width: MediaQuery.of(context).size.width - 150,
                  child: FutureBuilder(
                      future: myAssets,
                      builder: (ctx, balancesnapshot) {
                        if (balancesnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: Theme.of(context).accentColor,
                          ));
                        } else {
                          return Container(
                            padding: EdgeInsets.all(10),
                            width: (MediaQuery.of(context).size.width - 150) *
                                (3 / 4),
                            height: MediaQuery.of(context).size.height,
                            child: MyBalancesDesktopView(balancesnapshot.data),
                          );
                        }
                      }),
                )
              : Container(
                  width: (MediaQuery.of(context).size.width - 150),
                  child: Center(
                      child: Text("Please log in with Metamask",
                          style: TextStyle(
                              color: Theme.of(context).highlightColor)))),
        ],
      ),
    );
  }
}
