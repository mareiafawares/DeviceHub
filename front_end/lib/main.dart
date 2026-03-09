import 'package:flutter/material.dart';
import 'package:front_end/features/auth/presentation/pages/login_page.dart';

import 'core/app_theme.dart';
import 'core/service_locator.dart';
void main() {
  setupServiceLocator();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeviceHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: LoginPage(),
    );
  }
}