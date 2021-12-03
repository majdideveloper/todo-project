import 'package:flutter/material.dart';
import 'package:todo_project/shared/compo/components.dart';
import 'package:todo_project/shared/compo/constants.dart';

class Tasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) => bulidTaskItem(tasks[index]),
        separatorBuilder: (context, index) => SizedBox(
              height: 4.0,
            ),
        itemCount: tasks.length);
  }
}