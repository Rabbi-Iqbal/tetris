import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        width: 280,
        height: 650,
        color: Colors.deepPurple,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              // flex: 1,
              child: GridView.count(
                crossAxisCount: 10,
                children: List.generate(
                    200,
                    (index) => Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            color: Colors.black,
                          ),
                        )),
              ),
            ),
            Container(
              color: Colors.white12,
              child: Center(
                child: Container(
                  height: 90,
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.arrow_left_rounded,
                        size: 60,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.rotate_right,
                            size: 35,
                          ),
                          Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            size: 35,
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_right_rounded,
                        size: 60,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
