/// Anything that stores per-user data on the device (cart, wishlist...).
///
/// Logging out calls [clearUserData] on every registered cleaner, so the auth
/// feature never needs to know which other features keep data.
abstract interface class UserDataCleaner {
  Future<void> clearUserData();
}
