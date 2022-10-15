import 'package:selvam_broilers/pages/home_page.dart';
import 'package:selvam_broilers/pages/login_page.dart';
import 'package:flutter/material.dart';

class PageRoutes {
  static const String homePage = '/home';
  static const String loginPage = '/login';
  Map<String, WidgetBuilder> routes() {
    return {
      homePage: (context) => HomePage(),
      loginPage: (context) => LoginPage(),
    };
  }
}
