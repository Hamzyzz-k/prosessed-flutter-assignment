import 'package:flutter/widgets.dart';

/// Material 3 window size classes, as required by the brief.
enum WindowSize {
  /// < 600 dp: phones in portrait. 2-column grid, bottom navigation.
  compact,

  /// 600–1024 dp: small tablets, phones in landscape. Rail, 3–4 columns.
  medium,

  /// > 1024 dp: tablets in landscape. Rail, master–detail.
  expanded;

  static WindowSize fromWidth(double width) {
    if (width < 600) return compact;
    if (width <= 1024) return medium;
    return expanded;
  }

  bool get isCompact => this == compact;
  bool get isExpanded => this == expanded;
}

extension WindowSizeX on BuildContext {
  WindowSize get windowSize =>
      WindowSize.fromWidth(MediaQuery.sizeOf(this).width);
}

/// How many product columns fit in [width] (the width of the grid itself).
int productGridColumns(double width) {
  if (width < 600) return 2;
  if (width < 840) return 3;
  return 4;
}
