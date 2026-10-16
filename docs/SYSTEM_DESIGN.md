# ShopSphere — System Design

> Plain-words version first, details after. Read the [PRD](PRD.md) for *what* we build; this is *how*.

## 1. The big picture in one paragraph

The app is split into **features** (auth, products, cart, wishlist, profile, settings, diagnostics).
Each feature has three layers: **presentation** (screens + BLoC/Cubit), **domain** (plain Dart rules:
entities, repository contracts, use cases) and **data** (API calls, local storage, JSON models).
Screens only talk to Cubits. Cubits only talk to use cases. Use cases only talk to repository
*interfaces*. The real repositories are plugged in by **get_it** at startup. That way every layer
can be tested alone with fakes.

```
┌──────────────────────── Presentation (Flutter) ────────────────────────┐
│  Pages / Widgets  ──events──▶  Bloc / Cubit  ──states──▶  Pages         │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ calls
┌──────────────────────── Domain (pure Dart) ────────────────────────────┐
│  Use cases  ──▶  Repository interfaces      Entities      Failures     │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ implemented by
┌──────────────────────── Data ──────────────────────────────────────────┐
│  RepositoryImpl ──▶ RemoteDataSource (Dio) ──▶ DummyJSON                │
│                 └─▶ LocalDataSource (SharedPreferences / SecureStorage) │
│  Models (fromJson/toJson)  ──toEntity()──▶ Entities                     │
└─────────────────────────────────────────────────────────────────────────┘
```

**Rule of thumb:** arrows only point *down*. The domain layer imports nothing from Flutter, Dio or storage.

## 2. Folder structure

```
lib/
  main.dart                 # boot: DI, then runApp
  app.dart                  # MaterialApp.router, theme, locale, session listener
  core/
    di/                     # get_it registrations (injection.dart)
    network/                # DioClient, AuthInterceptor, ApiEndpoints, ErrorMapper
    error/                  # AppException (data layer) + Failure (domain layer)
    result/                 # Result<T> = Success | Err  (sealed class)
    router/                 # go_router config, route names, auth redirect
    theme/                  # colours, spacing, ThemeData (light + dark)
    utils/                  # breakpoints, formatters, debounce transformer
    widgets/                # ErrorView, EmptyView, Shimmer, PriceTag, RatingBadge...
    l10n/                   # ARB files (en, hi) + context.l10n extension
  features/
    auth/        data/ domain/ presentation/
    products/    data/ domain/ presentation/
    cart/        data/ domain/ presentation/
    wishlist/    data/ domain/ presentation/
    profile/     data/ domain/ presentation/
    settings/    data/ domain/ presentation/
    diagnostics/ data/ domain/ presentation/    # Error Lab
test/                        # mirrors lib/, plus fixtures/ with real API samples
```

## 3. Key choices (and why)

| Area | Choice | Why | Trade-off |
|---|---|---|---|
| State | **flutter_bloc** (Cubit mostly, one Bloc) | Explicit states, easy `bloc_test`, clear separation. | More boilerplate than Riverpod. |
| Search stream | **Bloc** with `debounce + restartable` transformer | Waits 400 ms *and* cancels stale requests, so an old search can never overwrite a newer one. | Slightly harder to read than a Timer. |
| DI | **get_it** | Simple, no code generation, works with Bloc. | Service locator, so keep calls at the composition root only. |
| HTTP | **dio** | Interceptors (auth, refresh, logging), timeouts, cancel tokens. | Bigger than `http`. |
| Errors | **sealed `Result<T>`** + sealed `Failure` | Dart 3 `switch` forces every case to be handled; no extra package. | Hand-rolled instead of `fpdart`. |
| Tokens | **flutter_secure_storage** | Keystore-backed on Android. | Async; slower than prefs (fine for 2 values). |
| Local data | **shared_preferences** (JSON) | Cart, wishlist, settings, product cache are tiny. | Not for large data; Hive/Isar would be next. |
| Routing | **go_router** | Declarative routes, redirect on auth, `StatefulShellRoute` keeps each tab's scroll. | Learning curve. |
| Images | **cached_network_image** | Disk cache + placeholders = smooth grids and offline thumbnails. | — |
| Models | Hand-written `fromJson` | No build_runner step; every line is easy to explain. | More typing than `freezed`. |

## 4. One request, end to end (load products)

```
ShopPage            ProductsBloc          GetProducts        ProductRepositoryImpl     ProductRemoteDataSource    Dio
   │  scroll end       │                     │                      │                         │                   │
   │──NextPageRequested▶                     │                      │                         │                   │
   │                   │ emit(loadingMore)   │                      │                         │                   │
   │                   │──call(query, skip)─▶│──getProducts()──────▶│──fetchProducts()───────▶│──GET /products──▶│
   │                   │                     │                      │                         │◀──JSON / DioError─│
   │                   │                     │                      │◀── ProductPageModel ─────│   (or throws      │
   │                   │                     │                      │     or AppException)     │    AppException)  │
   │                   │                     │◀─ Result<ProductPage>│  (maps to Failure,       │                   │
   │                   │◀────────────────────│                      │   cache fallback)        │                   │
   │◀─ state: items+=page, hasReachedEnd? ───│                      │                         │                   │
```

## 5. Error handling

Errors change shape **once per layer**, so each layer only knows its own words:

| Layer | Type | Example |
|---|---|---|
| Dio | `DioException` | `connectionError`, `receiveTimeout`, `badResponse(404)` |
| Data | `AppException` (thrown) | `NetworkException`, `TimeoutException`, `ServerException(500)`, `NotFoundException`, `UnauthorizedException`, `BadRequestException(msg)`, `ParseException` |
| Domain | `Failure` (returned in `Result.err`) | `NetworkFailure`, `TimeoutFailure`, `ServerFailure`, `NotFoundFailure`, `InvalidCredentialsFailure`, `SessionExpiredFailure`, `UnexpectedFailure` |
| UI | Localised message + icon | "You're offline…" + **Try again** |

- `ErrorMapper` turns `DioException` → `AppException` (one place, unit-tested).
- Every repository wraps its work in a small `guard()` helper that turns `AppException` → `Failure`.
- A bad JSON shape becomes `ParseException`, never a crash.
- Widgets get `Failure` and call `failure.message(l10n)`; they never see a stack trace.

## 6. Auth & session

```
          ┌──────────┐   token in secure storage?   ┌───────────┐
 launch ─▶│  Splash  │──────────── yes ────────────▶│   Shop    │
          └────┬─────┘                              └─────▲─────┘
               │ no                                       │ login ok
               ▼                                          │
          ┌──────────┐ ───── POST /auth/login ────────────┘
          │  Login   │
          └──────────┘
```

- **AuthCubit** (app-wide) holds `unknown | authenticated(user) | unauthenticated(reason?)`.
  go_router listens to it and redirects. No screen navigates on login/logout by hand.
- **AuthInterceptor** (a `QueuedInterceptor`, so parallel requests wait in line):
  1. Adds `Authorization: Bearer <token>` to requests marked `requiresAuth`.
  2. On **401**, calls `POST /auth/refresh` once with a *separate* Dio (so it can't loop),
     saves the new tokens and **retries** the original request.
  3. If refresh fails (**401/403**), it clears tokens and fires `SessionExpired` on a small
     `SessionEvents` stream. AuthCubit hears it and signs the user out with the message
     "Your session expired. Please sign in again."

## 7. Data & caching

| Data | Where | Lives until |
|---|---|---|
| Access + refresh token | Secure storage | Logout / session expiry |
| Cart lines | SharedPreferences (JSON list) | Order placed / logout |
| Wishlist | SharedPreferences (JSON list) | Logout |
| Theme + language | SharedPreferences | Forever |
| First page of the default product list | SharedPreferences (JSON) | Next successful load |

**Offline rule:** if loading the *default* first page fails with `NetworkFailure`, return the cached
page and mark it `isFromCache` so the UI shows the offline banner instead of an error.

## 8. Cart maths (pure domain, unit-tested)

```
line subtotal  = price × qty
line discount  = price × qty × discount% / 100
subtotal       = Σ line subtotal
discount       = Σ line discount
total          = subtotal − discount        (all rounded to 2 decimals for display only)
```

Quantity is always clamped to `1 … stock`. Adding an item that's already in the cart increases
its quantity instead of adding a second line.

## 9. Responsive layout

```
width < 600          600 ≤ width ≤ 1024         width > 1024
┌───────────┐        ┌──┬──────────────┐        ┌──┬──────────┬──────────┐
│  grid ×2  │        │R │   grid ×3–4  │        │R │ grid ×2  │ details  │
│           │        │a │              │        │a │ (master) │ (detail) │
├───────────┤        │i │              │        │i │          │          │
│ bottom nav│        │l │              │        │l │          │          │
└───────────┘        └──┴──────────────┘        └──┴──────────┴──────────┘
```

`AppShell` picks `NavigationBar` or `NavigationRail` with a `LayoutBuilder`. `ShopPage` switches to
master–detail on expanded widths: tapping a card selects it instead of pushing a new route.

## 10. Testing plan

| What | How |
|---|---|
| JSON models | Parse real API samples from `test/fixtures/` |
| ErrorMapper | Each `DioException` type → the right `AppException` |
| Repositories | Mocked data sources (mocktail): success / server failure / network failure / cache fallback |
| Use cases | Login validation, product query routing, cart totals |
| Blocs / Cubits | `bloc_test` for state sequences (loading → success → loadingMore → reachedEnd, etc.) |
| Interceptor | Fake HTTP adapter: 401 → refresh → retry; refresh 403 → session expired |
| Widgets | Login validation, ErrorView retry, ProductCard + golden |

CI (GitHub Actions) runs `dart format`, `flutter analyze` and `flutter test --coverage` on every push.

## 11. Things I'd do with more time

- Swap SharedPreferences for Hive/Isar for a bigger offline catalogue.
- Integration tests with `patrol` on a real device farm.
- Flavours (dev/prod) with `--dart-define` base URLs.
- Analytics + crash reporting (Sentry/Crashlytics).
