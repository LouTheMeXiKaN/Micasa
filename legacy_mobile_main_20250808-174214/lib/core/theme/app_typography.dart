import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Base text styles
  static TextStyle get _baseTextStyle => GoogleFonts.inter();
  
  // Display font (Dallas Print Shop placeholder using similar serif)
  static TextStyle get displayFont => GoogleFonts.instrumentSerif();
  
  // Text scales - Mobile first
  static TextStyle get textXs => _baseTextStyle.copyWith(fontSize: 12);
  static TextStyle get textSm => _baseTextStyle.copyWith(fontSize: 14);
  static TextStyle get textBase => _baseTextStyle.copyWith(fontSize: 16);
  static TextStyle get textLg => _baseTextStyle.copyWith(fontSize: 18);
  static TextStyle get textXl => _baseTextStyle.copyWith(fontSize: 24);
  static TextStyle get text2xl => _baseTextStyle.copyWith(fontSize: 32);
  static TextStyle get text3xl => _baseTextStyle.copyWith(fontSize: 40);
  
  // Display text scales
  static TextStyle get displayXl => displayFont.copyWith(fontSize: 24);
  static TextStyle get display2xl => displayFont.copyWith(fontSize: 32);
  static TextStyle get display3xl => displayFont.copyWith(fontSize: 40);
  
  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}