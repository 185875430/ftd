import 'package:example/route_aware.dart';
import 'package:flutter/material.dart';

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TextButton(
        child: Text("Page3"),
        onPressed: () {
          //导航到新路由
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return RouteAwareWidget();
          }));
        },
      ),
    );
  }
}
