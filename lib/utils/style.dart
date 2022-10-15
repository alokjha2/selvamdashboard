import 'colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

ThemeData getAppTheme() {
  return ThemeData(
      scaffoldBackgroundColor: white,
      backgroundColor: Colors.black,
      primaryColor: primary,
      dividerColor: grayLite,
      disabledColor: gray,
      appBarTheme: AppBarTheme(color: white),
      textTheme: GoogleFonts.nunitoTextTheme(textTheme));
}

final TextTheme textTheme = TextTheme(
    headline5: TextStyle(
        fontSize: 14.sp,
        color: primaryTextDark,
        fontWeight: FontWeight.w400), //medium
    headline4: TextStyle(
        fontSize: 14.sp,
        color: primaryTextDark,
        fontWeight: FontWeight.w700), //semi-bold
    headline3: TextStyle(
        fontSize: 18.sp,
        color: primaryTextDark,
        fontWeight: FontWeight.w600), //semi-bold
    headline2: TextStyle(
        fontSize: 18.sp,
        color: primaryTextDark,
        fontWeight: FontWeight.w700), //bold
    headline1: TextStyle(
        fontSize: 22.sp, color: primaryTextDark, fontWeight: FontWeight.w700),
    bodyText1: TextStyle(
        fontSize: 14.sp,
        color: primaryTextDark,
        fontWeight: FontWeight.w400), //regular/normal/plain
    bodyText2: TextStyle(
        fontSize: 16.sp,
        color: primaryTextDark,
        fontWeight: FontWeight.w400), //medium
    overline: TextStyle(
        fontSize: 14.sp,
        color: secondaryTextDark,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5),
    button: TextStyle(
        fontSize: 12.sp,
        color: white,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5),
    subtitle1: TextStyle(
        fontSize: 14.sp,
        color: primaryTextDark,
        fontWeight: FontWeight.w600), //semibold
    subtitle2: TextStyle(
        fontSize: 16.sp,
        color: primaryTextDark,
        fontWeight: FontWeight.w600), //semibold
    caption: TextStyle(
        fontSize: 12.sp,
        color: secondaryTextDark,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5));
