<p align="center">
  <img src="assets/brand/wordmark.png" alt="Basketly" width="360">
</p>

<p align="center">
  A hypermarket shopping app built with Flutter, BLoC and Supabase:
  groceries, fashion, electronics and home in one basket.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/State-BLoC%20%2F%20Cubit-3D1440" alt="BLoC">
  <img src="https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white" alt="Supabase">
  <img src="https://img.shields.io/badge/Cost-free%20tier%20only-F2A20C" alt="Free tier">
</p>

| Home | Product | Basket | Tracking |
|---|---|---|---|
| ![Home](screenshots/home.png) | ![Product](screenshots/product.png) | ![Basket](screenshots/basket.png) | ![Tracking](screenshots/tracking.png) |

## What it does

- **Shop four departments.** Home shows today's deal with a live countdown, departments and a Buy again row. Browse filters by department and sorts by popularity, price or newest.
- **Product options.** Sizes (sold-out sizes can't be picked), colours and quantity.
- **A basket that feels alive.** Products fly into the basket along a curved path and the basket bounces when they land. Swipe to remove with Undo, a free-delivery progress bar, and the promo code `BASKET10`. The basket is saved on the phone.
- **Search** that waits for you to stop typing before it asks the server.
- **Checkout** with address, a delivery slot and payment by cash on delivery or a demo card.
- **Orders and tracking.** Your order list, plus a tracking screen with a timeline and an arrival bar.
- **Accounts** with Supabase Auth. Checkout, orders and account are behind sign-in, and you come back to where you were after signing in.

## The part I'm proudest of: the server sets the price

The app never tells the server what to charge. It sends only product ids, quantities and options. A Supabase **Edge Function** (`supabase/functions/place-order`) then:

1. checks the signed-in user from their token,
2. loads real prices from the database and re-checks sizes and sold-out items,
3. applies the promo and delivery rules itself,
4. writes the order and its items, and removes the order again if the items fail to save.

Orders are **read-only** to the app through Row Level Security, so even a modified app can't change a price or write an order directly. The demo card is checked on the phone with the Luhn algorithm and never sent anywhere.

## Built with

| | |
|---|---|
| UI | Flutter, Material 3, Schibsted Grotesk, CustomPainter and overlay animations |
| State | `flutter_bloc` Cubits with sealed states and Equatable |
| Navigation | `go_router` with a stateful shell (tabs keep their place) and auth redirects |
| Backend | Supabase Postgres with Row Level Security, Auth, Storage, Edge Functions (Deno) |
| Local | `shared_preferences` for the saved basket |
| Dart 3 | sealed classes, records, pattern matching, switch expressions |

## Project structure

```
lib/
  core/        theme, router, shared widgets, Result type, money formatting
  features/
    catalog/   home, browse, product, search   (data / domain / presentation)
    basket/    basket cubit, pricing rules, fly-to-basket animation
    auth/      sign in and sign up
    checkout/  address, slots, payment, place order
    orders/    order list and tracking
    account/   profile and sign out
supabase/      SQL for each module + the place-order Edge Function
test/          unit tests for pricing, cubits, checkout rules and tracking
```

Each feature keeps the same three layers. **domain** holds plain Dart models and rules with no Flutter, so they are easy to test. **data** holds the repositories that talk to Supabase. **presentation** holds the cubits, screens and widgets.

## Run it yourself

Everything runs on Supabase's free tier.

1. Create a Supabase project, then run these in the SQL Editor, in order:
   `schema.sql`, `module2.sql`, `module4.sql`, `module6.sql`, `module6b.sql`.
2. **Edge Functions → Deploy a new function → Via Editor**, name it `place-order`, and paste `supabase/functions/place-order/index.ts`.
3. Upload the product and department images to the `products` Storage bucket.
4. **Authentication → Email:** turn it on (turn *Confirm email* off for quick testing).
5. Create `env.json` in the project root. It's git-ignored, and it holds only the public key, never the service role key:
   ```json
   { "SUPABASE_URL": "https://YOUR-PROJECT.supabase.co", "SUPABASE_ANON_KEY": "your publishable key" }
   ```
6. Run:
   ```bash
   flutter pub get
   flutter run --dart-define-from-file=env.json
   flutter test
   ```

Promo code: `BASKET10`. Demo card: `4242 4242 4242 4242`, any future expiry, any 3 digits.

## Notes

- This is a portfolio project. Payments, the rider and the tracking progress are demo features. Tracking moves with the clock, and you can also set an order's `status` in the Table Editor.
- The product and department illustrations are original artwork made for this project.

Made by **Ali Hassan Baloch**. [GitHub](https://github.com/alihassanbalochdev)
