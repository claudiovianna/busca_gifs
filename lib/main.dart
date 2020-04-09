import 'package:flutter/material.dart';
import 'view/home.dart';

void main(){
  runApp(
    MaterialApp(
      theme: ThemeData(
        hintColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white
            )
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white
            )
          )
        )
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    )
  );
}