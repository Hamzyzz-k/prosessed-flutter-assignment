import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/connectivity/connectivity_cubit.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/utils/breakpoints.dart';
import 'package:shopsphere/core/widgets/brand_mark.dart';
import 'package:shopsphere/core/widgets/status_view.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/presentation/bloc/products_bloc.dart';
import 'package:shopsphere/features/products/presentation/pages/product_details_view.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';
import 'package:shopsphere/features/products/presentation/widgets/shop_widgets.dart';

/// Home tab: search, categories, sort and the product grid.
///
/// On wide tablets it becomes master–detail: the grid on the left and the
/// selected product on the right.
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final _search = TextEditingController();
  final _scroll = ScrollController();

  /// Product shown in the side pane on expanded layouts.
  int? _selectedId;

  ProductsBloc get _bloc => context.read<ProductsBloc>();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Ask for the next page when the user is ~2 rows from the end.
  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.extentAfter < 600) {
      _bloc.add(const ProductsNextPageRequested());
    }
  }

  /// If the first page doesn't fill the screen there is nothing to scroll,
  /// so check once after layout as well.
  void _fillViewportIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoadMore();
    });
  }

  Future<void> _refresh() {
    final event = ProductsRefreshed();
    _bloc.add(event);
    return event.completer.future;
  }

  void _clearSearch() {
    _search.clear();
    _bloc.add(const ProductsSearchChanged(''));
  }

  void _selectCategory(String? slug) {
    _search.clear();
    _bloc.add(ProductsCategorySelected(slug));
  }

  void _clearFilters() {
    _search.clear();
    _bloc.add(const ProductsFiltersCleared());
  }

  Future<void> _pickSort(ProductSort current) async {
    final sort = await showSortSheet(context, current);
    if (sort != null && mounted) _bloc.add(ProductsSortChanged(sort));
  }

  void _open(int id, {required bool sideBySide}) {
    if (sideBySide) {
      setState(() => _selectedId = id);
    } else {
      unawaited(context.push(Routes.product(id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sideBySide = context.windowSize.isExpanded;
    final online = context.watch<ConnectivityCubit>().state;

    return MultiBlocListener(
      listeners: [
        BlocListener<ProductsBloc, ProductsState>(
          listenWhen: (a, b) =>
              b.refreshFailure != null && a.refreshFailure != b.refreshFailure,
          listener: (context, state) => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.refreshFailure!.describe(l10n))),
            ),
        ),
        BlocListener<ProductsBloc, ProductsState>(
          listenWhen: (a, b) =>
              b.status == ProductsStatus.success && a.items != b.items,
          listener: (_, _) => _fillViewportIfNeeded(),
        ),
        // Back online: quietly replace saved or failed results.
        BlocListener<ConnectivityCubit, bool>(
          listenWhen: (wasOnline, isOnline) => !wasOnline && isOnline,
          listener: (context, _) {
            final state = _bloc.state;
            if (state.isFromCache || state.status == ProductsStatus.failure) {
              unawaited(_refresh());
            }
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BlocSelector<ProductsBloc, ProductsState, bool>(
                selector: (s) => s.isFromCache,
                builder: (context, fromCache) => AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: !online || fromCache
                      ? OfflineBanner(showingCache: fromCache)
                      : const SizedBox(width: double.infinity),
                ),
              ),
              Expanded(
                child: sideBySide
                    ? Row(
                        children: [
                          Expanded(flex: 3, child: _browser(sideBySide: true)),
                          const VerticalDivider(width: 1),
                          Expanded(
                            flex: 2,
                            child: _selectedId == null
                                ? EmptyView(
                                    icon: Icons.touch_app_outlined,
                                    title: l10n.selectProductHint,
                                  )
                                : ProductDetailsView(
                                    key: ValueKey(_selectedId),
                                    productId: _selectedId!,
                                    embedded: true,
                                    onBack: () =>
                                        setState(() => _selectedId = null),
                                  ),
                          ),
                        ],
                      )
                    : _browser(sideBySide: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _browser({required bool sideBySide}) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = productGridColumns(constraints.maxWidth);
        return BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    titleSpacing: Insets.lg,
                    title: Row(
                      children: [
                        const BrandMark(size: 32),
                        Gaps.md,
                        Flexible(child: Text(l10n.appTitle)),
                      ],
                    ),
                    actions: [
                      IconButton(
                        tooltip: l10n.sortTooltip,
                        onPressed: () => _pickSort(state.query.sort),
                        icon: Badge(
                          isLabelVisible:
                              state.query.sort != ProductSort.relevance,
                          smallSize: 8,
                          child: const Icon(Icons.swap_vert_rounded),
                        ),
                      ),
                      Gaps.xs,
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Insets.lg,
                        Insets.xs,
                        Insets.lg,
                        Insets.md,
                      ),
                      child: ShopSearchField(
                        controller: _search,
                        onChanged: (text) =>
                            _bloc.add(ProductsSearchChanged(text)),
                        onCleared: _clearSearch,
                      ),
                    ),
                  ),
                  if (state.categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: CategoryChips(
                        categories: state.categories,
                        selected: state.query.isSearching
                            ? ''
                            : state.query.category,
                        onSelected: _selectCategory,
                      ),
                    ),
                  if (state.query.isSearching)
                    SliverToBoxAdapter(child: _SearchHeader(state: state)),
                  const SliverToBoxAdapter(child: Gaps.md),
                  ..._content(state, columns, sideBySide),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _content(ProductsState state, int columns, bool sideBySide) {
    final l10n = context.l10n;
    const padding = EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.lg);
    switch (state.status) {
      case ProductsStatus.initial:
      case ProductsStatus.loading:
        return [
          SliverPadding(
            padding: padding,
            sliver: ProductGridSkeleton(columns: columns),
          ),
        ];
      case ProductsStatus.failure:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(failure: state.failure!, onRetry: _refresh),
          ),
        ];
      case ProductsStatus.empty:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              icon: Icons.search_off_rounded,
              title: l10n.noProductsTitle,
              message: l10n.noProductsMessage,
              actionLabel: l10n.clearFilters,
              actionIcon: Icons.filter_alt_off_outlined,
              onAction: _clearFilters,
            ),
          ),
        ];
      case ProductsStatus.success:
        return [
          SliverPadding(
            padding: padding,
            sliver: SliverGrid(
              gridDelegate: productGridDelegate(context, columns),
              delegate: SliverChildBuilderDelegate(
                childCount: state.items.length,
                (context, index) {
                  final product = state.items[index];
                  return ProductCard(
                    product: product,
                    selected: sideBySide && product.id == _selectedId,
                    onTap: () => _open(product.id, sideBySide: sideBySide),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _PaginationFooter(
              status: state.pagination,
              onRetry: () => _bloc.add(const ProductsNextPageRequested()),
            ),
          ),
        ];
    }
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.state});

  final ProductsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.resultsFor(state.query.search),
            style: theme.textTheme.titleMedium,
          ),
          Text(
            state.status == ProductsStatus.success
                ? '${l10n.itemCount(state.total)} · '
                      '${l10n.searchClearsCategory}'
                : l10n.searchClearsCategory,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.status, required this.onRetry});

  final PaginationStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final child = switch (status) {
      PaginationStatus.loadingMore => const SizedBox.square(
        dimension: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
      PaginationStatus.failed => TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(l10n.retry),
      ),
      PaginationStatus.reachedEnd => Text(
        l10n.endOfList,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      PaginationStatus.idle => const SizedBox(height: 28),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.xxl),
      child: Center(child: child),
    );
  }
}
