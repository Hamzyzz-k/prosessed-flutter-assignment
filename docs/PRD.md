# ShopSphere — Product Requirements (PRD)

> Written in plain words. If something here and the code ever disagree, the code is wrong.

## 1. What are we building?

ShopSphere is a small shopping app for Android phones and tablets. You sign in, look through
products, search and filter them, read the details, put things in a cart and place a (pretend)
order. All data comes from the free [DummyJSON](https://dummyjson.com) API, so no real money and
no real orders.

## 2. Who is it for?

| Person | What they want |
|---|---|
| **Shopper** (main user) | Find something quickly, see the real price after discount, buy it in a few taps. |
| **Reviewer** at Prosessed | Run the app in minutes, see clean code, and see that errors are handled well. |

## 3. Goals

1. **Fast to understand.** Every screen has one main job and one main button.
2. **Never a dead end.** Every loading, empty or error screen tells you what happened and what to do next.
3. **Works everywhere.** Phone, tablet, portrait, landscape, big font sizes, light and dark mode.
4. **Your stuff stays.** Cart, wishlist, theme and language survive closing the app.

### Not goals (on purpose)

- Real payments, addresses or order history (DummyJSON does not store anything).
- Sign-up / forgot-password flows (the API has no such endpoints).
- iOS release build (the code should still compile for iOS).

## 4. User stories

### Sign in
- As a shopper, I open the app and, if I was signed in before, I go straight to the shop.
- As a shopper, I can sign in with username and password. I see a clear message if a field is empty
  or too short, and a friendly "Invalid username or password" if the server says no.
- As a reviewer, I can tap **"Use demo account"** to fill in `emilys / emilyspass`.

### Browse
- I see products in a grid: picture, name, price, discount and rating.
- More products load as I scroll (20 at a time). A small loader shows at the bottom and stops at the end.
- I can pull down to refresh.
- I can tap a category chip to see only that category.
- I can search. The app waits until I stop typing (~400 ms) before searching.
- I can sort by price (low→high, high→low), rating, or name.
- While the first page loads I see grey placeholder cards, not a blank screen.
- If nothing matches, I see "No products found" and a button to clear the search/filter.

### Product details
- I see a swipeable image gallery with dots, name, brand (if there is one), price, discount, rating,
  stock and the description, plus customer reviews.
- I can pick a quantity and **Add to cart**. If the item is out of stock the button is disabled and says so.
- If the product doesn't exist, I see "Product not found" and a way back.

### Cart and checkout
- I can change quantity (never below 1, never above stock) or remove an item (with **Undo**).
- I always see subtotal, discount and the final total.
- The cart icon shows a live count badge.
- **Checkout** shows a short review; **Place order** sends it, shows a success screen and empties the cart.

### Profile
- I see my photo, name, email and phone.
- I can switch theme (System / Light / Dark) and language (English / हिन्दी).
- I can log out (with a confirm dialog). That clears my session, cart and wishlist on this device.
- If my session expires and can't be renewed, I'm sent to sign in with a message explaining why.

### Extras (bonus)
- **Wishlist:** heart any product; it's saved on the device.
- **Offline:** a banner says "You are offline"; the last product list is still shown.
- **Silent token refresh:** an expired token is renewed in the background and the request is retried.
- **Error Lab:** a screen in Profile that triggers each failure on purpose (500, 404, slow network,
  timeout, expired token, bad refresh token) so the error handling can be seen in the demo video.

## 5. Screens

| Screen | Main job | Main action |
|---|---|---|
| Splash | Decide where to go | — (automatic) |
| Login | Sign in | **Sign in** |
| Shop | Find products | Tap a product |
| Product | Decide to buy | **Add to cart** |
| Wishlist | Come back to saved items | Tap a product |
| Cart | Adjust and check out | **Checkout** |
| Checkout | Confirm the order | **Place order** |
| Order placed | Reassure | **Continue shopping** |
| Profile | Account and settings | — |
| Error Lab | Show error handling | Run a scenario |

## 6. Every screen's states

Each screen that loads data has the same five states, so the app always feels the same:

| State | What you see |
|---|---|
| Loading | Placeholder cards / spinner (never a blank screen) |
| Success | The content |
| Empty | Friendly illustration + text + one button (e.g. "Clear filters") |
| Error | What went wrong in plain words + **Try again** |
| Loading more | Content + small loader at the bottom |

Error messages in plain words:

| Problem | Message |
|---|---|
| No internet | "You're offline. Check your connection and try again." |
| Took too long | "This is taking too long. Please try again." |
| Server broke (5xx) | "Something went wrong on our side. Please try again." |
| Not found (404) | "We couldn't find that." |
| Wrong login (400) | "Invalid username or password." |
| Session expired | "Your session expired. Please sign in again." |

## 7. Layout rules

| Screen width | Navigation | Product grid |
|---|---|---|
| < 600 dp (phone) | Bottom bar | 2 columns |
| 600–1024 dp (small tablet / phone landscape) | Side rail | 3–4 columns |
| > 1024 dp (tablet landscape) | Side rail | List on the left, details on the right |

No text may overflow at 1.3× font size.

## 8. How we'll know it's done

- Every **[Must]** item in the brief works on a phone and a tablet emulator.
- `flutter analyze` shows 0 issues; `flutter test` passes (15+ unit tests, aim for 60%+ coverage).
- The error scenarios in section 4 of the brief behave as listed.
- The release APK installs on Android 8.0+.

## 9. Open questions / assumptions

- **Logout clears cart and wishlist.** They belong to the signed-in person, and a shared device
  shouldn't show the last person's cart. A *forced* logout (expired session) keeps them, because
  the same person is usually signing back in.
- **Search ignores the category.** DummyJSON's search endpoint can't filter by category, so starting
  a search clears the category chip (the UI makes this visible).
- **Order uses the signed-in user's id** for `POST /carts/add`.
