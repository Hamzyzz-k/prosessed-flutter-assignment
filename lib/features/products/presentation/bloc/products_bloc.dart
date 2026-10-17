import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/utils/event_transformers.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(
    this._getProducts,
    this._getCategories, {
    Duration searchDebounce = const Duration(milliseconds: 400),
  }) : super(const ProductsState()) {
    on<ProductsStarted>(_onStarted);
    on<ProductsRefreshed>(_onRefreshed);
    on<ProductsSearchChanged>(
      _onSearchChanged,
      transformer: debounceRestartable(searchDebounce),
    );
    on<ProductsCategorySelected>(_onCategorySelected);
    on<ProductsSortChanged>(_onSortChanged);
    on<ProductsFiltersCleared>(_onFiltersCleared);
    // Ignore extra "load more" events while one page is already loading.
    on<ProductsNextPageRequested>(_onNextPage, transformer: droppable());
  }

  final GetProducts _getProducts;
  final GetCategories _getCategories;

  /// Bumped on every new first-page load. A response whose generation is
  /// out of date belongs to an old query and is thrown away.
  int _generation = 0;

  Future<void> _onStarted(
    ProductsStarted event,
    Emitter<ProductsState> emit,
  ) async {
    await Future.wait([
      _loadCategories(emit),
      _loadFirstPage(state.query, emit),
    ]);
  }

  Future<void> _onRefreshed(
    ProductsRefreshed event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      await Future.wait([
        if (state.categories.isEmpty) _loadCategories(emit),
        _loadFirstPage(state.query, emit, keepContent: state.items.isNotEmpty),
      ]);
    } finally {
      if (!event.completer.isCompleted) event.completer.complete();
    }
  }

  Future<void> _onSearchChanged(
    ProductsSearchChanged event,
    Emitter<ProductsState> emit,
  ) async {
    final text = event.text.trim();
    if (text == state.query.search) return;
    await _loadFirstPage(
      ProductQuery(search: text, sort: state.query.sort),
      emit,
    );
  }

  Future<void> _onCategorySelected(
    ProductsCategorySelected event,
    Emitter<ProductsState> emit,
  ) async {
    if (event.slug == state.query.category && !state.query.isSearching) {
      return;
    }
    // Picking a category ends the search (the API can't do both at once).
    await _loadFirstPage(
      ProductQuery(category: event.slug, sort: state.query.sort),
      emit,
    );
  }

  Future<void> _onSortChanged(
    ProductsSortChanged event,
    Emitter<ProductsState> emit,
  ) async {
    if (event.sort == state.query.sort) return;
    await _loadFirstPage(
      ProductQuery(
        search: state.query.search,
        category: state.query.category,
        sort: event.sort,
      ),
      emit,
    );
  }

  Future<void> _onFiltersCleared(
    ProductsFiltersCleared event,
    Emitter<ProductsState> emit,
  ) => _loadFirstPage(const ProductQuery(), emit);

  Future<void> _onNextPage(
    ProductsNextPageRequested event,
    Emitter<ProductsState> emit,
  ) async {
    final canLoad =
        state.status == ProductsStatus.success &&
        (state.pagination == PaginationStatus.idle ||
            state.pagination == PaginationStatus.failed);
    if (!canLoad) return;

    final generation = _generation;
    emit(state.copyWith(pagination: PaginationStatus.loadingMore));
    final result = await _getProducts(state.query, skip: state.items.length);
    if (generation != _generation) return;

    switch (result) {
      case Ok(:final value):
        final known = state.items.map((p) => p.id).toSet();
        final items = [
          ...state.items,
          ...value.items.where((p) => !known.contains(p.id)),
        ];
        final reachedEnd = !value.hasMore || value.items.isEmpty;
        emit(
          state.copyWith(
            items: items,
            total: value.total,
            pagination: reachedEnd
                ? PaginationStatus.reachedEnd
                : PaginationStatus.idle,
          ),
        );
      case Err():
        emit(state.copyWith(pagination: PaginationStatus.failed));
    }
  }

  Future<void> _loadCategories(Emitter<ProductsState> emit) async {
    final result = await _getCategories();
    if (result case Ok(:final value)) {
      emit(state.copyWith(categories: value));
    }
    // Categories are a nice-to-have: if they fail the grid still works and
    // pull-to-refresh tries again.
  }

  Future<void> _loadFirstPage(
    ProductQuery query,
    Emitter<ProductsState> emit, {
    bool keepContent = false,
  }) async {
    final generation = ++_generation;
    emit(
      keepContent
          ? state.copyWith(query: query, refreshFailure: () => null)
          : state.copyWith(
              query: query,
              status: ProductsStatus.loading,
              pagination: PaginationStatus.idle,
              items: const [],
              failure: () => null,
              refreshFailure: () => null,
            ),
    );

    final result = await _getProducts(query);
    if (generation != _generation) return;

    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            status: value.items.isEmpty
                ? ProductsStatus.empty
                : ProductsStatus.success,
            items: value.items,
            total: value.total,
            isFromCache: value.isFromCache,
            pagination: value.hasMore
                ? PaginationStatus.idle
                : PaginationStatus.reachedEnd,
            failure: () => null,
          ),
        );
      case Err(:final failure) when keepContent:
        emit(state.copyWith(refreshFailure: () => failure));
      case Err(:final failure):
        emit(
          state.copyWith(
            status: ProductsStatus.failure,
            failure: () => failure,
          ),
        );
    }
  }
}
