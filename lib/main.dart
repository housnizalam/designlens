import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';


void main() {
  runApp(const DesignLensApp());
}

class DesignLensApp extends StatelessWidget {
  const DesignLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DesignLens',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2455A4)),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      ),
      home: const HomeScreen(),
    );
  }
}
