import 'package:flutter/material.dart';

 class RouteAwareWidget extends StatefulWidget {
   State<RouteAwareWidget> createState() => RouteAwareWidgetState();
 }

 // Implement RouteAware in a widget's state and subscribe it to the RouteObserver.
 class RouteAwareWidgetState extends State<RouteAwareWidget> with RouteAware {

   final RouteObserver<ModalRoute> routeObserver =
   RouteObserver<ModalRoute>();

   @override
   void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
   }

   @override
   void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
     // Route was pushed onto navigator and is now topmost route.
    print("yongyuan.wu didpush");
   }

   @override
   void didPopNext() {
     // Covering route was popped off the navigator.
     print("yongyuan.wu didPopNext");
   }


   @override
  void didPushNext() {
//
     print("yongyuan.wu didPushNext");
  }


   @override
  void didPop() {
//
     print("yongyuan.wu didPop");
  }

  @override
   Widget build(BuildContext context) => Container();

 }