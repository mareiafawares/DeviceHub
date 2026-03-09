import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.indigo,
      scaffoldBackgroundColor: Color(0xFFF8F9FA),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color:Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
    
