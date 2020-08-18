import 'package:QBGround/screens/subscriptions_screen.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("QB Test app"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("QB Test App"),
            Spacer(),
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SubscriptionScreen();
                    },
                  ),
                );
              },
              child: Text("Open next page"),
            )
          ],
        ),
      ),
    );
  }
}
