import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';

class CryptolicaiApp extends StatelessWidget {
  const CryptolicaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Crypto Earn',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
