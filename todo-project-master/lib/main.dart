import 'package:flutter/material.dart';
import 'package:todo_project/layout/homescreen.dart';
import 'package:todo_project/shared/bloc_observer.dart';

void main() {
  blocObserver: MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeLayout(),
    );
  }
}
