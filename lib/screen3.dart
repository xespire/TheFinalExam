import 'package:flutter/material.dart';
import 'screen2.dart';

class Screen3 extends StatelessWidget {
  final int score;

  Screen3(this.score);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('貪食蛇遊戲'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GAME OVER',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            Text(
              '得分: $score',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Screen2()),
                );
              },
              child: Text('重新開始'),
            ),
          ],
        ),
      ),
    );
  }
}
