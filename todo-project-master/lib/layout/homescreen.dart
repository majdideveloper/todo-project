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
  // this booleen is about open bottomsheet and close
  bool isBottomSheetShown = false;
  // this variable icondata when open bottomsheet and when closed change
  IconData icon = Icons.add;

  // there controller about bottomsheet form
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  
  

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, Object? state) {},
        builder: (BuildContext context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body:true //tasks.length > 0
                ? cubit.screens[cubit.currentIndex]
                : Center(child: CircularProgressIndicator()),
            floatingActionButton: FloatingActionButton(
              child: Icon(icon),
              onPressed: () {
                if (isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    insertToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    ).then((value) {
                      getDataFromDatabase(db).then((value) {
                        Navigator.pop(context);
                        // setState(() {
                        //   isBottomSheetShown = false;
                        //   icon = Icons.add;
                        //   tasks = value;
                        // });
                      });
                    });
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                          (context) => ContainerBottomSheet(context),
                          backgroundColor: Colors.grey[600])
                      .closed
                      .then((value) {
                    isBottomSheetShown = false;
                    // setState(() {
                    //   icon = Icons.add;
                    // });
                  });

                  // setState(() {
                  //   isBottomSheetShown = true;
                  //   icon = Icons.edit;
                  // });
                }

                // insertToDatabase();
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: (index) {
                cubit.changeIndex(index);
                // setState(() {
                //   currentIndex = index;
                // });
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

  void createDatabase() async {
    // open the database
    db = await openDatabase('todo.db', version: 1,
        onCreate: (Database db, int version) {
      // When creating the db, create the table

      // id integer => INTEGER PRIMARY KEY = integer and the database write this id
      // title String
      // date String
      // time String
      // status String

      print('database created');
      db
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) {
        print('table created');
      }).catchError((error) {
        print('error when created database ${error.toString()}');
      });
    }, onOpen: (Database db) {
      getDataFromDatabase(db).then((value) {
        // setState(() {
        //   tasks = value;
        // });
      });
      print('database opened');
    });
  }

  Future insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await db.transaction((txn) async {
      await txn
          .rawInsert(
              'INSERT INTO tasks (title, date, time, status) VALUES("$title","$date","$time","new")')
          .then((value) {
        print('$value inserted successfully');
      }).catchError((error) {
        print('error when inserting new records ${error.toString()}');
      });
    });
  }

  Future<List<Map>> getDataFromDatabase(db) async {
    return await db.rawQuery("SELECT * FROM tasks");
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
