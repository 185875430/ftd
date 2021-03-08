import 'package:example/page3.dart';
import 'package:flutter/material.dart';
import 'package:ftd/ftd.dart';

@PageId(id:'page/page2')
// ignore: must_be_immutable
class Page2 extends StatelessWidget {
  String pageId;

  Page2({Key key,this.pageId}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TextButton(
        child: Text("Page2"),
        onPressed: () {
          //导航到新路由
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Page3();
          }));
        },
      ),
    );
  }
}
