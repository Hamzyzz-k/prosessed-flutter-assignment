// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShopSphere';

  @override
  String get splashTagline => 'Everything you love, in one place.';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get goBack => 'Go back';

  @override
  String get errorTitleOffline => 'You\'re offline';

  @override
  String get errorTitleTimeout => 'Taking too long';

  @override
  String get errorTitleServer => 'Something went wrong';

  @override
  String get errorTitleNotFound => 'Not found';

  @override
  String get errorTitleGeneric => 'Something went wrong';

  @override
  String get errorNetwork => 'Check your connection and try again.';

  @override
  String get errorTimeout => 'The server is slow to answer. Please try again.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Please try again.';

  @override
  String get errorNotFound => 'We couldn\'t find that.';

  @override
  String get errorInvalidCredentials => 'Invalid username or password.';

  @override
  String get errorSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get errorUnexpected =>
      'Something unexpected happened. Please try again.';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue shopping.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signIn => 'Sign in';

  @override
  String get useDemoAccount => 'Use demo account';

  @override
  String get usernameRequired => 'Enter your username';

  @override
  String get passwordRequired => 'Enter your password';

  @override
  String fieldTooShort(int min) {
    return 'Must be at least $min characters';
  }

  @override
  String get navShop => 'Shop';

  @override
  String get navWishlist => 'Wishlist';

  @override
  String get navCart => 'Cart';

  @override
  String get navProfile => 'Profile';

  @override
  String cartBadgeLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items in cart',
      one: '1 item in cart',
      zero: 'Cart is empty',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Search products';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get categoryAll => 'All';

  @override
  String get sortTooltip => 'Sort products';

  @override
  String get sortTitle => 'Sort by';

  @override
  String get sortRelevance => 'Recommended';

  @override
  String get sortPriceLowHigh => 'Price: low to high';

  @override
  String get sortPriceHighLow => 'Price: high to low';

  @override
  String get sortRating => 'Top rated';

  @override
  String get sortTitleAz => 'Name: A to Z';

  @override
  String get noProductsTitle => 'No products found';

  @override
  String get noProductsMessage => 'Try a different search or category.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String resultsFor(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get searchClearsCategory => 'Search looks in every category';

  @override
  String get endOfList => 'That\'s everything for now.';

  @override
  String get offlineBanner => 'You are offline';

  @override
  String get offlineCachedBanner => 'You are offline · showing saved products';

  @override
  String discountBadge(String percent) {
    return '-$percent';
  }

  @override
  String get addToWishlist => 'Add to wishlist';

  @override
  String get removeFromWishlist => 'Remove from wishlist';

  @override
  String ratingLabel(String rating) {
    return 'Rated $rating out of 5';
  }

  @override
  String priceLabel(String price, String original) {
    return 'Price $price, was $original';
  }

  @override
  String get productNotFoundTitle => 'Product not found';

  @override
  String get productNotFoundMessage =>
      'It may have been removed. Let\'s get you back to shopping.';

  @override
  String get backToShop => 'Back to shop';

  @override
  String byBrand(String brand) {
    return 'by $brand';
  }

  @override
  String get inStock => 'In stock';

  @override
  String lowStock(int count) {
    return 'Only $count left';
  }

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get descriptionTitle => 'Description';

  @override
  String reviewsTitle(int count) {
    return 'Reviews ($count)';
  }

  @override
  String get noReviews => 'No reviews yet.';

  @override
  String get quantity => 'Quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get viewCart => 'View cart';

  @override
  String get selectProductHint => 'Pick a product to see its details here.';

  @override
  String imagePosition(int index, int total) {
    return 'Image $index of $total';
  }

  @override
  String get cartTitle => 'Your cart';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyMessage => 'Find something you love and add it here.';

  @override
  String get startShopping => 'Start shopping';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get checkout => 'Checkout';

  @override
  String get removeItem => 'Remove';

  @override
  String itemRemoved(String title) {
    return '$title removed';
  }

  @override
  String get undo => 'Undo';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get checkoutTitle => 'Review order';

  @override
  String get deliverTo => 'Deliver to';

  @override
  String get payment => 'Payment';

  @override
  String get cashOnDelivery => 'Cash on delivery (demo)';

  @override
  String get orderSummary => 'Order summary';

  @override
  String get placeOrder => 'Place order';

  @override
  String get orderPlacedTitle => 'Order placed!';

  @override
  String orderPlacedMessage(int id) {
    return 'Order #$id is confirmed. This is a demo, so nothing will be shipped.';
  }

  @override
  String youSaved(String amount) {
    return 'You saved $amount';
  }

  @override
  String get continueShopping => 'Continue shopping';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistEmptyTitle => 'No favourites yet';

  @override
  String get wishlistEmptyMessage =>
      'Tap the heart on any product to save it here.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get developer => 'Developer';

  @override
  String get errorLab => 'Error Lab';

  @override
  String get errorLabSubtitle =>
      'Trigger failures on purpose and see how the app recovers.';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmMessage =>
      'Your cart and wishlist on this device will be cleared.';

  @override
  String get labIntro =>
      'Each scenario calls a real DummyJSON test endpoint. Nothing here can break the app.';

  @override
  String get labServerError => 'Server error (500)';

  @override
  String get labServerErrorDesc => 'GET /http/500 → friendly error with retry.';

  @override
  String get labNotFound => 'Missing product (404)';

  @override
  String get labNotFoundDesc =>
      'Opens /products/9999 → \"Product not found\" with a way back.';

  @override
  String get labSlow => 'Slow network (3 s)';

  @override
  String get labSlowDesc => 'GET /products?delay=3000 → loader stays visible.';

  @override
  String get labTimeout => 'Request timeout';

  @override
  String get labTimeoutDesc =>
      '5 s delay with a 2 s timeout → timeout message.';

  @override
  String get labExpiredToken => 'Expired access token';

  @override
  String get labExpiredTokenDesc =>
      'Corrupts the access token, then loads your profile. The app refreshes it silently and retries.';

  @override
  String get labBadRefresh => 'Bad refresh token';

  @override
  String get labBadRefreshDesc =>
      'Corrupts both tokens. Refresh fails (403) and you are signed out with a message.';

  @override
  String get labOfflineHint =>
      'Offline: turn on airplane mode and pull to refresh on Shop.';

  @override
  String get labRun => 'Run';

  @override
  String labSuccess(int ms) {
    return 'Success in $ms ms';
  }
}
