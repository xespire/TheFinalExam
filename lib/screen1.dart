import 'package:flutter/material.dart';
import 'screen2.dart';

void main() {
  runApp(MaterialApp(
    home: Screen1(),
  ));
}

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('貪食蛇遊戲'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Screen2()),
            );
          },
          child: Text('開始遊戲'),
        ),
      ),
    );
  }
}
