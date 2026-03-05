import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/dealers/data/models/product_model.dart';

class QuantitySelectionBottomSheet extends StatefulWidget {
  const QuantitySelectionBottomSheet({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  final ProductModel product;
  final Function(int quantity) onConfirm;

  @override
  State<QuantitySelectionBottomSheet> createState() => _QuantitySelectionBottomSheetState();
}

class _QuantitySelectionBottomSheetState extends State<QuantitySelectionBottomSheet> {
  late final TextEditingController _controller;
  int _quantity = 10;

  @override
  void initState() {
    super.initState();
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
    });
  }

  double get _totalEarnings {
    final earningsNum = double.tryParse(widget.product.earningsPerUnit?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0.0;
    return earningsNum * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MIQDORNI KIRITING:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.graySubtle,
                  letterSpacing: 1.1,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'BEKOR QILISH',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.graySubtle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkNavy,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _quantity = int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.keyboard_arrow_up, size: 16, color: AppColors.graySubtle),
                          Text(
                            widget.product.unitName?.toUpperCase() ?? 'QOP',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.graySubtle,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.graySubtle),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 64,
                width: 100,
                child: ElevatedButton(
                  onPressed: () => widget.onConfirm(_quantity),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.darkNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.gold.withValues(alpha: 0.5),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickButtons(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.background, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ISH HAQI TO\'PLANADI:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.graySubtle,
                  ),
                ),
                Text(
                  '${_formatPrice(_totalEarnings.toStringAsFixed(0))} sum',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButtons() {
    return Column(
      children: [
        Row(
          children: [
            _quickButton('-500', -500, isNegative: true),
            const SizedBox(width: 8),
            _quickButton('-50', -50, isNegative: true),
            const SizedBox(width: 8),
            _quickButton('-5', -5, isNegative: true),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _quickButton('+5', 5),
            const SizedBox(width: 8),
            _quickButton('+50', 50),
            const SizedBox(width: 8),
            _quickButton('+500', 500),
          ],
        ),
      ],
    );
  }

  Widget _quickButton(String label, int delta, {bool isNegative = false}) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _updateQuantity(delta),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: AppColors.background, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isNegative ? Colors.red.shade400 : const Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }

  String _formatPrice(String price) {
    try {
      final value = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      return value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } catch (_) {
      return price;
    }
  }
}
