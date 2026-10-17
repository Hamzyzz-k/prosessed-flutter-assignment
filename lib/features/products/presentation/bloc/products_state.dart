part of 'products_bloc.dart';

/// State of the first page (what fills the screen).
enum ProductsStatus { initial, loading, success, empty, failure }

/// State of the footer while scrolling.
enum PaginationStatus { idle, loadingMore, failed, reachedEnd }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.pagination = PaginationStatus.idle,
    this.query = const ProductQuery(),
    this.items = const [],
    this.total = 0,
    this.categories = const [],
    this.isFromCache = false,
    this.failure,
    this.refreshFailure,
  });

  final ProductsStatus status;
  final PaginationStatus pagination;
  final ProductQuery query;
  final List<ProductSummary> items;
  final int total;
  final List<Category> categories;

  /// The items are the saved offline copy.
  final bool isFromCache;

  /// Why the first page failed (only set when [status] is failure).
  final Failure? failure;

  /// A refresh failed while content was already on screen. Shown as a
  /// snackbar so the shopper keeps what they were looking at.
  final Failure? refreshFailure;

  ProductsState copyWith({
    ProductsStatus? status,
    PaginationStatus? pagination,
    ProductQuery? query,
    List<ProductSummary>? items,
    int? total,
    List<Category>? categories,
    bool? isFromCache,
    Failure? Function()? failure,
    Failure? Function()? refreshFailure,
  }) {
    return ProductsState(
      status: status ?? this.status,
      pagination: pagination ?? this.pagination,
      query: query ?? this.query,
      items: items ?? this.items,
      total: total ?? this.total,
      categories: categories ?? this.categories,
      isFromCache: isFromCache ?? this.isFromCache,
      failure: failure != null ? failure() : this.failure,
      refreshFailure: refreshFailure != null
          ? refreshFailure()
          : this.refreshFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    pagination,
    query,
    items,
    total,
    categories,
    isFromCache,
    failure,
    refreshFailure,
  ];
}
