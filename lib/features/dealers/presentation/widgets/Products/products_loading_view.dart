import 'package:flutter/material.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/product_card_skeleton.dart';

class ProductsLoadingView extends StatelessWidget {
  const ProductsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 6,
      itemBuilder: (_, __) => const ProductCardSkeleton(),
    );
  }
}
