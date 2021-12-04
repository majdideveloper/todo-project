import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import 'package:todo_project/modules/archived.dart';
import 'package:todo_project/modules/done.dart';
import 'package:todo_project/modules/tasks.dart';

import 'package:todo_project/shared/components/components.dart';
import 'package:todo_project/shared/components/constants.dart';
import 'package:todo_project/shared/cubit/app_cubit.dart';

class HomeLayout extends StatelessWidget {
  // this is the varaible of database
  late Database db;
// key for bottom sheet
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  // there controller about bottomsheet form
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, Object? state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: cubit.screens[cubit.currentIndex],
            floatingActionButton: FloatingActionButton(
              child: Icon(cubit.icon),
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text);
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                          (context) => ContainerBottomSheet(context),
                          backgroundColor: Colors.grey[600])
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                        isShow: false, icon: Icons.add);
                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.edit);
                }

                // insertToDatabase();
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: (index) {
                cubit.changeIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.done_all),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget ContainerBottomSheet(context) => Container(
        color: Colors.grey[400],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: defaultFormField(
                        controller: titleController,
                        type: TextInputType.text,
                        validate: (String? value) {
                          if (value!.isEmpty) {
                            return 'title must not be empty';
                          }
                        },
                        label: 'title',
                        prefix: Icons.title),
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: defaultFormField(
                        controller: timeController,
                        type: TextInputType.none,
                        onTap: () {
                          showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now())
                              .then((value) {
                            timeController.text = value!.format(context);
                            print(value);
                          });
                        },
                        validate: (String? value) {
                          if (value!.isEmpty) {
                            return 'time must not be empty';
                          }
                        },
                        label: 'time task',
                        prefix: Icons.watch),
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: defaultFormField(
                      controller: dateController,
                      type: TextInputType.none,
                      onTap: () {
                        showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2200))
                            .then((value) {
                          dateController.text =
                              DateFormat.yMMMd().format(value!);
                        });
                      },
                      validate: (String? value) {
                        if (value!.isEmpty) {
                          return 'date must not be empty';
                        }
                      },
                      label: 'date task',
                      prefix: Icons.calendar_today,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
