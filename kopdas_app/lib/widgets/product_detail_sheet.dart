import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/product.dart';
import 'product_image.dart';

/// Preview detail minuman: gambar besar, deskripsi, harga, jumlah, dan tombol
/// tambah ke keranjang. Dipakai sebagai isi bottom sheet (layar sempit, diberi
/// [scrollController]) atau dialog (layar lebar).
class ProductDetailSheet extends StatefulWidget {
  final ProductModel product;
  final int available;
  final int inCart;
  final ScrollController? scrollController;
  final bool isDialog;
  final void Function(int qty) onAdd;

  const ProductDetailSheet({
    super.key,
    required this.product,
    required this.available,
    required this.inCart,
    required this.onAdd,
    this.scrollController,
    this.isDialog = false,
  });

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  int _qty = 1;

  int get _remaining => widget.available - widget.inCart;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final canAdd = _remaining > 0;

    final content = <Widget>[
      _buildImage(p),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.textDark,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _stockBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _categoryChip(p.categoryName ?? 'Menu'),
                Text(
                  formatRupiah(p.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            if (p.description != null && p.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                p.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildQtyRow(canAdd),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ];

    final scrollable = widget.scrollController != null
        ? ListView(
            controller: widget.scrollController,
            padding: EdgeInsets.zero,
            children: content,
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          );

    return Column(
      children: [
        if (!widget.isDialog)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.brown.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        Expanded(child: scrollable),
        _buildBottomBar(canAdd),
      ],
    );
  }

  Widget _buildImage(ProductModel p) {
    return SizedBox(
      height: widget.isDialog ? 260 : 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'pos-product-${p.id}',
            child: ProductImage(imageUrl: p.imageUrl, cacheWidth: 900),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black26, Colors.transparent, Colors.black38],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.white.withValues(alpha: 0.92),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Tutup',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 20),
                color: AppConstants.textDark,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockBadge() {
    final Color color;
    final String label;
    if (widget.available <= 0) {
      color = AppConstants.statusDanger;
      label = 'Habis';
    } else if (_remaining <= 0) {
      color = AppConstants.statusPending;
      label = 'Maks. di keranjang';
    } else if (widget.available <= 5) {
      color = AppConstants.statusPending;
      label = 'Stok menipis';
    } else {
      color = AppConstants.statusSuccess;
      label = 'Tersedia';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _categoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.accentColor.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppConstants.primaryDark,
        ),
      ),
    );
  }

  Widget _buildQtyRow(bool canAdd) {
    return Row(
      children: [
        const Text(
          'Jumlah',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppConstants.textDark,
          ),
        ),
        const Spacer(),
        Text(
          'Sisa stok: ${widget.available}',
          style: const TextStyle(fontSize: 11, color: Colors.black45),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: AppConstants.backgroundColor.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.brown.shade100),
          ),
          child: Row(
            children: [
              _qtyButton(Icons.remove, canAdd && _qty > 1, () {
                setState(() => _qty--);
              }),
              SizedBox(
                width: 36,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Text(
                    '$_qty',
                    key: ValueKey(_qty),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.textDark,
                    ),
                  ),
                ),
              ),
              _qtyButton(Icons.add, canAdd && _qty < _remaining, () {
                setState(() => _qty++);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, bool enabled, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppConstants.primaryColor : Colors.black26,
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool canAdd) {
    final total = widget.product.price * _qty;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        border: Border(top: BorderSide(color: Colors.brown.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Text(
                    formatRupiah(total),
                    key: ValueKey(total),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: canAdd
                  ? () {
                      widget.onAdd(_qty);
                      Navigator.of(context).pop();
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                disabledBackgroundColor: Colors.brown.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_shopping_cart, size: 19),
              label: Text(
                canAdd ? 'Tambah ke Keranjang' : 'Stok tidak cukup',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
