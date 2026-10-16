/// Every DummyJSON path the app uses, in one place.
abstract final class ApiEndpoints {
  static const baseUrl = 'https://dummyjson.com';

  static const login = '/auth/login';
  static const me = '/auth/me';
  static const refresh = '/auth/refresh';

  static const products = '/products';
  static const productSearch = '/products/search';
  static const categories = '/products/categories';
  static String product(int id) => '/products/$id';
  static String productsByCategory(String slug) => '/products/category/$slug';

  static const addCart = '/carts/add';

  /// Test endpoint that answers with the given HTTP status code.
  static String httpStatus(int code) => '/http/$code';

  /// How long issued tokens should live, in minutes.
  static const tokenLifetimeMinutes = 30;
}
