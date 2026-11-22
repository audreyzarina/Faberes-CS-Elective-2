import 'package:brewleaf_shop/core/theme.dart';
import 'package:brewleaf_shop/models/product.dart';
import 'package:brewleaf_shop/models/shop_category.dart';
import 'package:brewleaf_shop/models/user_profile.dart';
import 'package:brewleaf_shop/pages/products/product_list_page.dart';
import 'package:brewleaf_shop/providers/auth_providers.dart';
import 'package:brewleaf_shop/providers/category_providers.dart';
import 'package:brewleaf_shop/providers/product_providers.dart';
import 'package:brewleaf_shop/providers/theme_provider.dart';
import 'package:brewleaf_shop/widgets/account_menu.dart';
import 'package:brewleaf_shop/widgets/ui_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('theme choice changes the app theme and is saved',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const _ThemeTestApp(),
      ),
    );

    expect(find.text('light'), findsOneWidget);
    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();

    expect(find.text('dark'), findsOneWidget);
    expect(preferences.getString('theme_mode'), 'dark');

    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light mode'));
    await tester.pumpAndSettle();

    expect(find.text('light'), findsOneWidget);
    expect(preferences.getString('theme_mode'), 'light');
  });

  testWidgets('message uses its requested short duration', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showMessage(
                context,
                'Added to your cart',
                duration: const Duration(seconds: 2),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    expect(find.text('Added to your cart'), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, const Duration(seconds: 2));
  });

  testWidgets('admin add-product button does not cover pagination',
      (tester) async {
    tester.view.physicalSize = const Size(800, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => 'admin'),
          categoriesProvider.overrideWith((ref) async => <ShopCategory>[]),
          priceCeilingProvider.overrideWith((ref) async => 100),
          productsProvider.overrideWith((ref) async {
            final items = List.generate(
              6,
              (index) => Product(
                id: index + 1,
                name: 'Product ${index + 1}',
                price: 10,
                stock: 5,
                createdAt: DateTime(2026),
              ),
            );
            return ProductsResult(items: items, total: 7);
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProductListPage(isAdmin: true),
            bottomNavigationBar: SizedBox(height: 80),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Next page'), findsOneWidget);
    final addButton = tester.getRect(find.byType(FloatingActionButton));
    final nextPageButton = tester.getRect(find.byTooltip('Next page'));
    expect(addButton.overlaps(nextPageButton), isFalse);
  });
}

class _ThemeTestApp extends ConsumerWidget {
  const _ThemeTestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      home: Scaffold(
        appBar: AppBar(
          actions: [
            AccountMenu(
              profile: const UserProfile(id: 'test', role: 'customer'),
            ),
          ],
        ),
        body: Builder(
          builder: (context) => Center(
            child: Text(Theme.of(context).brightness.name),
          ),
        ),
      ),
    );
  }
}
