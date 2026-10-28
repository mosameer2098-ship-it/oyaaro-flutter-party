import 'package:flutter/material.dart';

import 'main_navigation.dart';
import 'theme.dart';

class OyaaroApp extends StatelessWidget {
  const OyaaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oyaaro',
      debugShowCheckedModeBanner: false,
      theme: buildOyaaroTheme(),
      home: const MainNavigation(),
    );
  }
}
