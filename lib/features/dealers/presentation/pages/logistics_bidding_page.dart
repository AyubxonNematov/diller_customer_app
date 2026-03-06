import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';

class LogisticsBiddingPage extends StatefulWidget {
  const LogisticsBiddingPage({
    super.key,
    required this.warehouseName,
    required this.offeredPrice,
  });

  final String warehouseName;
  final double offeredPrice;

  @override
  State<LogisticsBiddingPage> createState() => _LogisticsBiddingPageState();
}

class _LogisticsBiddingPageState extends State<LogisticsBiddingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Logistika Birjasi',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              widget.warehouseName.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildMyOfferCard(),
          const SizedBox(height: 24),
          Expanded(
            child: _buildDriverOffersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOfferCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'SIZNING TAKLIFINGIZ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatPrice(widget.offeredPrice.toStringAsFixed(0))} sum',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverOffersList() {
    // Mock data for UI demonstration as requested "Rasm bilan birhil qil"
    final mockDrivers = [
      {'name': 'Sirojiddin', 'vehicle': 'LABO (OQ)', 'price': 95000},
      {'name': 'Jasur', 'vehicle': 'CHEVROLET DAMAS', 'price': 85000},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: mockDrivers.length,
      itemBuilder: (context, index) {
        final driver = mockDrivers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.background,
                child: Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver['name'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                    ),
                    Text(
                      driver['vehicle'].toString(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatPrice(driver['price'].toString())} sum',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.darkNavy),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF161C26),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      minimumSize: const Size(0, 28),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('TANLASH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatPrice(String price) {
    try {
      final val = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      return val.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } catch (_) {
      return price;
    }
  }
}
