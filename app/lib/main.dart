import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'data/auth/auth_controller.dart';
import 'data/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  final refreshToken = prefs.getString('refreshToken');
  final localeCode = prefs.getString('localeCode');
  runApp(
    ProviderScope(
      overrides: [
        initialTokenProvider.overrideWithValue(token),
        initialRefreshTokenProvider.overrideWithValue(refreshToken),
        initialLocaleProvider.overrideWithValue(localeCode),
      ],
      child: const FertwaysApp(),
    ),
  );
}
