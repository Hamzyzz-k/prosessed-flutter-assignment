import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shopsphere/app/app.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Reads the stored session while the splash screen is showing.
  unawaited(sl<AuthCubit>().checkSession());
  runApp(const ShopSphereApp());
}
