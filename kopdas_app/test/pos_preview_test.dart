import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopdas_app/core/constants.dart';
import 'package:kopdas_app/models/product.dart';
import 'package:kopdas_app/widgets/product_detail_sheet.dart';
import 'package:kopdas_app/widgets/product_image.dart';

ProductModel _cappuccino() => ProductModel(
      id: 'prd-07',
      categoryId: 'cat-01',
      name: 'Cappuccino',
      description: 'Espresso dengan steamed milk dan foam tebal yang lembut',
      price: 14000,
      status: 'ACTIVE',
      imageUrl: '/static/products/cappuccino.jpg',
      categoryName: 'Coffee',
      options: const [
        ProductOptionGroup(id: 'size', name: 'Ukuran', choices: [
          ProductOptionChoice(id: 'regular', name: 'Regular'),
          ProductOptionChoice(id: 'large', name: 'Large', priceDelta: 3000),
          ProductOptionChoice(id: 'extra_large', name: 'Extra Large', priceDelta: 5000),
        ]),
        ProductOptionGroup(id: 'serving', name: 'Penyajian', choices: [
          ProductOptionChoice(id: 'hot', name: 'Hot'),
          ProductOptionChoice(id: 'ice', name: 'Ice'),
        ]),
        ProductOptionGroup(id: 'extras', name: 'Tambahan', multi: true, choices: [
          ProductOptionChoice(id: 'extra_shot', name: 'Extra Shot', priceDelta: 4000),
          ProductOptionChoice(id: 'extra_milk', name: 'Extra Milk', priceDelta: 3000),
          ProductOptionChoice(id: 'extra_sugar', name: 'Extra Sugar', priceDelta: 1000),
        ]),
      ],
    );

void main() {
  group('ProductModel varian', () {
    test('fromJson memetakan options backend', () {
      final p = ProductModel.fromJson({
        'id': 'prd-07',
        'category_id': 'cat-01',
        'name': 'Cappuccino',
        'price': 14000,
        'status': 'ACTIVE',
        'image_url': '/static/products/cappuccino.jpg',
        'options': [
          {
            'id': 'size',
            'name': 'Ukuran',
            'multi': false,
            'choices': [
              {'id': 'regular', 'name': 'Regular', 'price_delta': 0},
              {'id': 'large', 'name': 'Large', 'price_delta': 3000},
            ],
          },
        ],
      });
      expect(p.options, hasLength(1));
      expect(p.options.first.choices[1].priceDelta, 3000);
      expect(p.defaultOptionIds, ['regular']);
      expect(p.unitPriceFor(['large']), 17000);
      expect(p.variantLabelFor(['large']), 'Large');
    });

    test('harga & label varian mengikuti urutan grup', () {
      final p = _cappuccino();
      expect(p.defaultOptionIds, ['regular', 'hot']);
      expect(p.unitPriceFor(['large', 'hot', 'extra_shot']), 21000);
      expect(p.variantLabelFor(['extra_shot', 'large', 'hot']),
          'Large · Hot · Extra Shot');
      expect(p.unitPriceFor([]), 14000);
      expect(p.variantLabelFor([]), isNull);
    });
  });

  group('ProductImage', () {
    test('resolveUrl relatif ke origin backend', () {
      final origin = Uri.parse(AppConstants.apiBaseUrl).origin;
      expect(ProductImage.resolveUrl('/static/products/a.jpg'),
          '$origin/static/products/a.jpg');
      expect(ProductImage.resolveUrl('https://cdn.example.com/a.jpg'),
          'https://cdn.example.com/a.jpg');
      expect(ProductImage.resolveUrl(null), isNull);
      expect(ProductImage.resolveUrl(''), isNull);
    });

    testWidgets('tanpa URL memakai aset fallback', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SizedBox(width: 100, height: 100, child: ProductImage()),
      ));
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName, ProductImage.fallbackAsset);
    });
  });

  group('ProductDetailSheet', () {
    Future<void> pumpSheet(
      WidgetTester tester, {
      required int available,
      int inCart = 0,
      required void Function(int) onAdd,
    }) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () => showDialog(
                  context: ctx,
                  builder: (_) => Dialog(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 540, maxHeight: 760),
                      child: ProductDetailSheet(
                        product: _cappuccino(),
                        available: available,
                        inCart: inCart,
                        isDialog: true,
                        onAdd: onAdd,
                      ),
                    ),
                  ),
                ),
                child: const Text('buka'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
    }

    testWidgets('menampilkan detail tanpa opsi varian, subtotal harga dasar',
        (tester) async {
      await pumpSheet(tester, available: 50, onAdd: (_) {});
      expect(find.text('Cappuccino'), findsOneWidget);
      expect(find.text('Espresso dengan steamed milk dan foam tebal yang lembut'),
          findsOneWidget);
      // Data backend tetap membawa options, tetapi UI tidak boleh menampilkannya.
      expect(find.text('Ukuran'), findsNothing);
      expect(find.text('Penyajian'), findsNothing);
      expect(find.text('Tambahan'), findsNothing);
      expect(find.text('Regular'), findsNothing);
      expect(find.text('Large'), findsNothing);
      expect(find.text('Ice'), findsNothing);
      expect(find.text('Hot'), findsNothing);
      expect(find.text('Extra Milk'), findsNothing);
      expect(find.text('Extra Sugar'), findsNothing);
      expect(find.text('Rp 14.000'), findsWidgets); // harga + subtotal
      expect(find.text('Tambah ke Keranjang'), findsOneWidget);
    });

    testWidgets('subtotal mengikuti qty dengan harga dasar', (tester) async {
      await pumpSheet(tester, available: 50, onAdd: (_) {});
      expect(find.text('Rp 14.000'), findsWidgets);
      await tester.ensureVisible(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      // qty 2 × harga dasar 14.000 = 28.000, tanpa delta varian
      expect(find.text('Rp 28.000'), findsOneWidget);
    });

    testWidgets('tambah ke keranjang mengirim qty benar', (tester) async {
      int? qty;
      await pumpSheet(tester, available: 50, onAdd: (q) => qty = q);
      await tester.ensureVisible(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah ke Keranjang'));
      await tester.pumpAndSettle();
      expect(qty, 2);
    });

    testWidgets('stok habis menonaktifkan tombol tambah', (tester) async {
      await pumpSheet(tester, available: 0, onAdd: (_) {});
      expect(find.text('Stok tidak cukup'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(find.text('Habis'), findsOneWidget);
    });

    testWidgets('qty tidak melebihi sisa stok', (tester) async {
      await pumpSheet(tester, available: 5, inCart: 4, onAdd: (_) {});
      // sisa 1: tombol + qty disabled sejak awal
      await tester.ensureVisible(find.byIcon(Icons.add));
      final plusInkWell = tester.widget<InkWell>(find.ancestor(
        of: find.byIcon(Icons.add),
        matching: find.byType(InkWell),
      ));
      expect(plusInkWell.onTap, isNull);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Rp 14.000'), findsWidgets);
    });
  });
}
