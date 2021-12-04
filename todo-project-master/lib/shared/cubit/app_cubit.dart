import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_project/modules/archived.dart';
import 'package:todo_project/modules/done.dart';
import 'package:todo_project/modules/tasks.dart';

part 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitial());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  // this List of Screens we change
  List<Widget> screens = [
    Tasks(),
    Done(),
    Archived(),
  ];
  // this List of TitleOfScreen we change
  List<String> titles = [
    'Tasks',
    'Done',
    'Archived',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavbarState());
  }

// this list of tasks from database
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  // this is the varaible of database
  late Database db;

  //code of state create database
  void createDatabase() {
    // open the database
    openDatabase('todo.db', version: 1, onCreate: (Database db, int version) {
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
      getDataFromDatabase(db);
      print('database opened');
    }).then((value) => {
          db = value,
          emit(AppCreateDatabaseState()),
        });
  }

// code of state insert in database
  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await db.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks (title, date, time, status) VALUES("$title","$date","$time","new")')
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDatabaseState());

        getDataFromDatabase(db);
      }).catchError((error) {
        print('error when inserting new records ${error.toString()}');
      });
    });
  }

  void updateData({
    required String status,
    required int id,
  }) async {
    db.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
          getDataFromDatabase(db);
      emit(AppUpdateDatabaseState());
    });
  }
 
  void deleteData ({
    required int id ,
  })async {
      db
    .rawDelete('DELETE FROM tasks WHERE id = ?', [id])
    .then((value) {
         getDataFromDatabase(db);
      emit(AppDeleteDatabaseState());

    });

  }

  // code of state get from database
  void getDataFromDatabase(db)
   {
     newTasks = [];
     doneTasks = [];
     archivedTasks = [];


    db.rawQuery("SELECT * FROM tasks").then((value) {
      value.forEach((element) {
        if(element['status']=='new')
        newTasks.add(element);
        else if(element['status']=='done')
        doneTasks.add(element);
         else 
        archivedTasks.add(element);
      });

      emit(AppGetDatabaseState());
    });
  }

  /*
  this code of state change icon bottomsheet
  */
  // this booleen is about open bottomsheet and close
  bool isBottomSheetShown = false;
  // this variable icondata when open bottomsheet and when closed change
  IconData icon = Icons.add;
  // methode of change bottomsheet and icon
  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    this.icon = icon;
    emit(AppChangeBottomNavBarState());
  }
}
