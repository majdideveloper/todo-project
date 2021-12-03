import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
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

  void changeIndex (int index) {
    currentIndex = index ;
    emit(AppChangeBottomNavbarState());
  }
}
