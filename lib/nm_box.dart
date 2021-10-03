import 'package:flutter/material.dart';

Color mC = Colors.grey.shade100;
Color mCL = Colors.white;
Color mCD = Colors.black.withOpacity(0.075);
Color mCC = Colors.green.withOpacity(0.65);
Color fCL = Colors.grey.shade600;

BoxDecoration nMBoxCirc =
    BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [
  BoxShadow(
    color: mCD,
    offset: Offset(10, 10),
    blurRadius: 10,
  ),
  BoxShadow(
    color: mCL,
    offset: Offset(-10, -10),
    blurRadius: 10,
  ),
]);
BoxDecoration nMBox = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: mC,
    boxShadow: [
      BoxShadow(
        color: mCD,
        offset: Offset(5, 5),
        blurRadius: 5,
      ),
      BoxShadow(
        color: mCL,
        offset: Offset(-10, -10),
        blurRadius: 10,
      ),
    ]);

BoxDecoration nMBoxInvert = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: mCD,
    boxShadow: [
      BoxShadow(
          color: mCL, offset: Offset(3, 3), blurRadius: 3, spreadRadius: -3),
    ]);
