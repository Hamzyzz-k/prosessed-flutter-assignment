/// Every route path in one place, so features never hard-code strings.
abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';

  static const shop = '/shop';
  static const wishlist = '/wishlist';
  static const cart = '/cart';
  static const profile = '/profile';

  static const checkout = '/checkout';
  static const orderPlaced = '/order-placed';
  static const errorLab = '$profile/error-lab';

  /// Details pushed on top of the current tab, so the bottom bar stays.
  static String product(int id, {String from = shop}) => '$from/product/$id';
}
