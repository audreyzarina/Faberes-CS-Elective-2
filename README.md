# Supabase Shop — Price Filter + Pagination

CS Elective 2 · Supabase-Flutter Activity

## What was added
- **Price filter**: a `RangeSlider` (min/max auto-detected from the products table). Releasing the slider re-queries Supabase with `.gte('price', min).lte('price', max)`.
- **Pagination**: **6 products per page**, done in the Supabase query with `.range(from, to)` plus `.count(CountOption.exact)` for total pages. Filters are chained first, then `.order()`, then `.range()`.
- **State management**: `Provider` (`ChangeNotifier`) in `lib/providers/product_provider.dart`. The UI only reads state and calls methods (`setPriceRange`, `goToPage`, `nextPage`, ...).
- Also included from the earlier session: add / update (`.update().eq()`) / delete (`.delete().eq()`).

## Run it
1. Supabase Dashboard -> SQL Editor -> run `supabase/schema.sql` (creates `products`, RLS policies, 20 sample rows).
2. Put your Project URL + **anon** key in `lib/config/supabase_config.dart`.
3. In this folder:
   ```
   flutter create . --project-name supabase_shop   # generates android/ios/web folders
   flutter pub get
   flutter run
   ```

## Using your own project instead
Copy these into your repo (keep your own table/columns if they differ, then adjust `Product.fromMap`):
- `lib/providers/product_provider.dart`
- `lib/widgets/price_filter.dart`, `lib/widgets/pagination_bar.dart`
- `lib/screens/shop_screen.dart` (or reuse its grid + `PriceFilter` + `PaginationBar` layout)
- add `provider: ^6.1.2` to `pubspec.yaml` and wrap your app in `ChangeNotifierProvider(create: (_) => ProductProvider()..init())`

## Submission
```
git checkout -b backend-filter-pagination
git add .
git commit -m "Add price filter and pagination"
git push -u origin backend-filter-pagination
```
Then submit the branch link in the submission bin on Daigler.
