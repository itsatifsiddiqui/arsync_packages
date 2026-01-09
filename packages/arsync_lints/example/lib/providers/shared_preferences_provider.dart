import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user/app_user.dart';
import 'theme_provider.dart';

///Override provider in provider scope
final sharedPreferencesProvider = Provider.autoDispose<SharedPreferencesProvider>((ref) {
  throw UnimplementedError();
});

class SharedPreferencesProvider {
  const SharedPreferencesProvider(this.prefs, this.ref);
  final SharedPreferences prefs;
  final Ref ref;

  final onboardingKey = 'onboarding';
  final themeModeKey = 'themeMode';
}
