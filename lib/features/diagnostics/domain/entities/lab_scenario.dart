/// Failure scenarios from section 4 of the brief, runnable on demand.
enum LabScenario {
  /// `GET /http/500`.
  serverError,

  /// `GET /products?delay=3000`: the loader must stay visible.
  slowNetwork,

  /// 5 s server delay against a 2 s receive timeout.
  timeout,

  /// Corrupt the access token, then call `/auth/me`: the interceptor must
  /// refresh it and retry without the user noticing.
  expiredAccessToken,

  /// Corrupt both tokens: refresh fails with 403 and the user is signed out.
  badRefreshToken,
}
