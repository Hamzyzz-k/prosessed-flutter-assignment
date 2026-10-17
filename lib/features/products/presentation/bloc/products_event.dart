part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

/// First load: categories and the first page.
final class ProductsStarted extends ProductsEvent {
  const ProductsStarted();
}

/// Pull-to-refresh or "Try again".
final class ProductsRefreshed extends ProductsEvent {
  ProductsRefreshed({Completer<void>? completer})
    : completer = completer ?? Completer<void>();

  /// Completes when the refresh is done, so the pull-to-refresh spinner
  /// knows when to stop.
  final Completer<void> completer;
}

/// The grid scrolled near its end.
final class ProductsNextPageRequested extends ProductsEvent {
  const ProductsNextPageRequested();
}

/// Text typed in the search bar (debounced inside the bloc).
final class ProductsSearchChanged extends ProductsEvent {
  const ProductsSearchChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// A category chip was tapped (`null` = "All").
final class ProductsCategorySelected extends ProductsEvent {
  const ProductsCategorySelected(this.slug);

  final String? slug;

  @override
  List<Object?> get props => [slug];
}

final class ProductsSortChanged extends ProductsEvent {
  const ProductsSortChanged(this.sort);

  final ProductSort sort;

  @override
  List<Object?> get props => [sort];
}

/// Back to "All, recommended" (from the empty state).
final class ProductsFiltersCleared extends ProductsEvent {
  const ProductsFiltersCleared();
}
