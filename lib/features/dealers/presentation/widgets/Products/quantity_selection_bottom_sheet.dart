import 'package:flutter/material.dart';
import 'package:sement_market_customer/features/dealers/data/models/product_model.dart';

class QuantitySelectionBottomSheet extends StatefulWidget {
  const QuantitySelectionBottomSheet({
    super.key,
    required this.product,
    required this.onConfirm,
    this.initialQuantity = 0,
  });

  final ProductModel product;
  final Function(int quantity) onConfirm;
  final int initialQuantity;

  @override
  State<QuantitySelectionBottomSheet> createState() =>
      _QuantitySelectionBottomSheetState();
}

class _QuantitySelectionBottomSheetState
    extends State<QuantitySelectionBottomSheet> {
  late final TextEditingController _controller;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
    _controller = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateQuantity(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(1, 999999);
      _controller.text = _quantity.toString();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  double get _totalEarnings {
    final earningsNum = double.tryParse(
            widget.product.earningsPerUnit?.replaceAll(RegExp(r'[^\d.]'), '') ??
                '0') ??
        0.0;
    return earningsNum * _quantity;
  }

  double get _totalPrice {
    final priceNum = double.tryParse(
            widget.product.price.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ??
        0.0;
    return priceNum * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MIQDORNI TANLANG',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E2D3D),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Color(0xFF1E2D3D)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuantityInput(),
          const SizedBox(height: 20),
          _buildQuickButtons(),
          const SizedBox(height: 24),
          _buildTotalPriceInfo(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                widget.onConfirm(_quantity);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5BF1A),
                foregroundColor: const Color(0xFF1E2D3D),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'TASDIQLASH',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInput() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _updateQuantity(-1),
            icon: const Icon(Icons.remove_circle_outline, size: 28),
            color: const Color(0xFF1E2D3D),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E2D3D),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "1",
              ),
              onChanged: (v) {
                if (v.isEmpty) {
                  _quantity = 1;
                } else {
                  int? val = int.tryParse(v);
                  if (val != null) {
                    _quantity = val.clamp(1, 999999);
                  }
                }
                setState(() {});
              },
            ),
          ),
          IconButton(
            onPressed: () => _updateQuantity(1),
            icon: const Icon(Icons.add_circle_outline, size: 28),
            color: const Color(0xFF1E2D3D),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPriceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Jami narxi :',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
            ),
          ),
          // Narxlarni ustma-ust chiqarish uchun Column ishlatamiz
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_formatPrice(_totalPrice.toStringAsFixed(0))} sum',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B5E20),
                ),
              ),
              // Agar foyda (earnings) ham kerak bo'lsa:
              Text(
                'Ish haqi: ${_formatPrice(_totalEarnings.toStringAsFixed(0))} sum',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF43A047), // Sal ochroq yashil
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _quickButton('-5', -5, isNeg: true),
        _quickButton('-50', -50, isNeg: true),
        _quickButton('-500', -500, isNeg: true),
        _quickButton('+5', 5),
        _quickButton('+50', 50),
        _quickButton('+500', 500),
      ],
    );
  }

  Widget _quickButton(String label, int delta, {bool isNeg = false}) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 56) / 3,
      child: OutlinedButton(
        onPressed: () => _updateQuantity(delta),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side:
              BorderSide(color: isNeg ? Colors.red[100]! : Colors.green[100]!),
          backgroundColor: isNeg ? Colors.red[50] : Colors.green[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isNeg ? Colors.red[700] : Colors.green[700],
          ),
        ),
      ),
    );
  }

  String _formatPrice(String price) {
    try {
      final value =
          double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      return value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } catch (_) {
      return price;
    }
  }
}
