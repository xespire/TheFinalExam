import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'screen3.dart';

class Screen2 extends StatefulWidget {
  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  double cellSize = 20.0;
  late Timer snakeTimer;
  double gameSpeed = 1.0;
  List<Offset> snake = [Offset(1, 1)];
  Offset food = Offset(5, 5);
  bool isGameOver = false;
  String direction = '右';
  int score = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('貪食蛇遊戲'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: SnakeGameWidget(
              snake: snake,
              food: food,
              cellSize: cellSize,
            ),
          ),
          Expanded(
            flex: 2, // 調整下半部分高度的比例
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 40.0),
                    buildArrowButton('上'),
                    SizedBox(width: 40.0),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildArrowButton('左'),
                    SizedBox(width: 60.0),
                    buildArrowButton('右'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 40.0),
                    buildArrowButton('下'),
                    SizedBox(width: 40.0),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SpeedButton('x2', 2.0, adjustGameSpeed),
                SpeedButton('x0.5', 0.5, adjustGameSpeed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildArrowButton(String newDirection) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.all(16.0),
      ),
      onPressed: () {
        if (!isOppositeDirection(newDirection) && !isSameDirection(newDirection)) {
          setState(() {
            changeDirection(newDirection);
          });
        }
      },
      child: Text(newDirection),
    );
  }

  void adjustGameSpeed(double multiplier) {
    setState(() {
      gameSpeed *= multiplier;
      snakeTimer.cancel();
      startGame();
    });
  }

  void startGame() {
    int calculateInterval() {
      // 根據遊戲速度和固定的基礎時間計算每一步的時間間隔
      return (1000 ~/ gameSpeed).round();
    }

    snakeTimer = Timer.periodic(Duration(milliseconds: calculateInterval()), (timer) {
      if (!isGameOver) {
        moveSnake();
      }
    });
  }

  void moveSnake() {
    Offset head = snake.first;

    switch (direction) {
      case '上':
        head = Offset(head.dx, (head.dy - 1).clamp(0.0, (MediaQuery.of(context).size.height / (cellSize * 2) - 1)));
        break;
      case '下':
        head = Offset(head.dx, (head.dy + 1).clamp(0.0, (MediaQuery.of(context).size.height / (cellSize * 2) - 1)));
        break;
      case '左':
        head = Offset((head.dx - 1).clamp(0.0, (MediaQuery.of(context).size.width / cellSize - 1)), head.dy);
        break;
      case '右':
        head = Offset((head.dx + 1).clamp(0.0, (MediaQuery.of(context).size.width / cellSize - 1)), head.dy);
        break;
    }

    if (head == food) {
      setState(() {
        snake.add(Offset(0, 0));
        generateFood();
        score++;
      });
    }

    if (isCollision()) {
      setState(() {
        isGameOver = true;
        snakeTimer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Screen3(score)),
        );
      });
      return;
    }

    setState(() {
      snake.insert(0, head);
      if (snake.length > 1) {
        snake.removeLast();
      }
    });
  }

  void generateFood() {
    // 生成食物的邏輯，確保食物不會生成在蛇身上
    Random random = Random();
    int maxX = (MediaQuery.of(context).size.width / cellSize-2).floor();
    int maxY = (MediaQuery.of(context).size.height / (cellSize * 2)-2).floor();

    do {
      int randomX = random.nextInt(maxX) + 1; // 從 1 開始
      int randomY = random.nextInt(maxY) + 1; // 從 1 開始
      food = Offset(
        randomX.toDouble(),
        randomY.toDouble(),
      );
    } while (snake.contains(food));
    print('Generated Food at: $food');
  }

  bool isCollision() {
    Offset head = snake.first;

    // 檢查是否與邊界碰撞
    if (head.dx == 0 || head.dy == 0 ||
        head.dx >= (MediaQuery.of(context).size.width / cellSize-2) ||
        head.dy >= (MediaQuery.of(context).size.height / (cellSize * 2))-2) {
      return true;
    }

    // 檢查是否與自身身體碰撞
    for (int i = 1; i < snake.length; i++) {
      if (head == snake[i]) {
        return true;
      }
    }

    return false;
  }

  bool isOppositeDirection(String newDirection) {
    return (direction == '上' && newDirection == '下') ||
        (direction == '下' && newDirection == '上') ||
        (direction == '左' && newDirection == '右') ||
        (direction == '右' && newDirection == '左');
  }

  bool isSameDirection(String newDirection) {
    return direction == newDirection;
  }

  void changeDirection(String newDirection) {
    direction = newDirection;
  }
}

class SnakeGameWidget extends StatelessWidget {
  final List<Offset> snake;
  final Offset food;
  final double cellSize;

  SnakeGameWidget({
    required this.snake,
    required this.food,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GridView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (MediaQuery.of(context).size.width / cellSize).floor(),
        ),
        itemBuilder: (context, index) {
          int x = index % (MediaQuery.of(context).size.width / cellSize).floor();
          int y = index ~/ (MediaQuery.of(context).size.width / cellSize).floor();
          Offset cell = Offset(x.toDouble(), y.toDouble());

          if (x == 0 || x == ((MediaQuery.of(context).size.width / cellSize).floor() - 1) ||
              y == 0 || y == ((MediaQuery.of(context).size.height / (cellSize * 2)).floor() - 1)) {
            // 在邊界上繪製黑色方塊
            return Container(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            );
          } else if (snake.contains(cell)) {
            // 蛇身部分
            return Container(
              decoration: BoxDecoration(
                color: Colors.green,
                border: Border.all(color: Colors.white),
              ),
            );
          } else if (cell == food) {
            // 食物部分
            return Container(
              decoration: BoxDecoration(
                color: Colors.red,
                border: Border.all(color: Colors.white),
              ),
            );
          } else {
            // 空白部分
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
              ),
            );
          }
        },
        itemCount: ((MediaQuery.of(context).size.width / cellSize).floor() *
            (MediaQuery.of(context).size.height / (cellSize * 2)).floor())
            .toInt(),
      ),
    );
  }
}

class SpeedButton extends StatelessWidget {
  final String label;
  final double speedMultiplier;
  final void Function(double) onPressed;

  SpeedButton(this.label, this.speedMultiplier, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        onPrimary: Colors.white,
        padding: EdgeInsets.all(16.0),
      ),
      onPressed: () {
        onPressed(speedMultiplier);
      },
      child: Text(label),
    );
  }
}

