import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_project/shared/components/components.dart';
import 'package:todo_project/shared/components/constants.dart';
import 'package:todo_project/shared/cubit/app_cubit.dart';

class Tasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          List tasks = AppCubit.get(context).newTasks;
          return ListView.separated(
              itemBuilder: (context, index) => bulidTaskItem(tasks[index],context),
              separatorBuilder: (context, index) => SizedBox(
                    height: 4.0,
                  ),
              itemCount: tasks.length);
        });
  }
}
