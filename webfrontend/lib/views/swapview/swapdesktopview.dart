import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app_template/provider/loginprovider.dart';
import 'package:web_app_template/widgets/oneinchanaytics/oneinchanalytics.dart';
import '../../widgets/swapwidget/swapwidgetdesktopview.dart';
import '../../widgets/sidebar/sidebardesktop.dart';

class SwapDesktopView extends StatefulWidget {
  @override
  _SwapDesktopViewState createState() => _SwapDesktopViewState();
}

class _SwapDesktopViewState extends State<SwapDesktopView> {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<LoginModel>(context).user;

    return Row(
      children: [
        SidebarDesktop(2),
        user != null
            ? Container(
                //padding: EdgeInsets.all(15),
                width: MediaQuery.of(context).size.width - 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SwapWidgetDesktopview(),
                    //OneInchAnalytics(),
                  ],
                ),
              )
            : Container(
                width: (MediaQuery.of(context).size.width - 150),
                child: Center(
                    child: Text("Please log in with Metamask",
                        style: TextStyle(
                            color: Theme.of(context).highlightColor)))),
      ],
    );
  }
}
