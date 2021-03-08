import 'package:example/page2.dart';
import 'package:flutter/material.dart';
import 'package:ftd/ftd.dart';

@PageId(id:'page/page1')
class Page1 extends StatefulWidget  {
  String pageId;

  Page1({Key key,this.pageId}) : super(key: key);

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> with WidgetsBindingObserver{


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state){
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TextButton(
        child: Text("Page1"),
        onPressed: () {
          //导航到新路由
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Page2(pageId: 'page2',);
          }));
        },
      ),
    );
  }


}
