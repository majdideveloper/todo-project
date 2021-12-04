import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_project/shared/components/components.dart';
import 'package:todo_project/shared/cubit/app_cubit.dart';

class Archived extends StatelessWidget {
  const Archived({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          List tasks = AppCubit.get(context).archivedTasks;
          return ListView.separated(
              itemBuilder: (context, index) => bulidTaskItem(tasks[index],context),
              separatorBuilder: (context, index) => SizedBox(
                    height: 4.0,
                  ),
              itemCount: tasks.length);
        });
  }
}
