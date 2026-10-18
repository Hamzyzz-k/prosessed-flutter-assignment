import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/theme/app_theme.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside the real theme and localisations.
  Future<void> pumpApp(
    Widget widget, {
    List<BlocProvider> providers = const [],
    Size size = const Size(400, 800),
    double textScale = 1,
  }) async {
    view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(view.reset);
    final app = MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(body: widget),
    );
    await pumpWidget(
      providers.isEmpty
          ? app
          : MultiBlocProvider(providers: providers, child: app),
    );
  }
}
