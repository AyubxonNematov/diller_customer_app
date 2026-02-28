import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final api = getIt<ApiClient>();
      final r = await api.dio.get('/me');
      setState(() {
        _user = r.data as Map<String, dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.darkNavy))
            : _error != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.grayText),
            const SizedBox(height: 16),
            Text(_error ?? '', textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grayText)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                setState(() { _loading = true; _error = null; });
                _fetchProfile();
              },
              child: const Text('QAYTA URINISH'),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _logout, child: const Text('CHIQISH')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final name = _user?['name'] ?? 'Foydalanuvchi';
    final phone = _user?['phone'] ?? '';
    final balance = _user?['balance'] ?? '0';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            color: AppColors.darkNavy,
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'D',
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MARKETPLACE',
                          style: TextStyle(fontSize: 10, color: Colors.white54,
                              fontWeight: FontWeight.w600, letterSpacing: 1)),
                      Text(name,
                          style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text('$balance sum',
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Profil',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                        color: AppColors.darkNavy)),
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('CHIQISH',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                            color: AppColors.darkNavy)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Balance card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
                    blurRadius: 20, offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.wallet, color: Colors.white, size: 20),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('MENING HISOBIM',
                              style: TextStyle(fontSize: 12, color: Colors.white70,
                                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Text('Diller Market Gold',
                              style: TextStyle(fontSize: 13,
                                  color: Colors.amber[400],
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("TO'PLANGAN ISH HAQI",
                      style: TextStyle(fontSize: 11, color: Colors.white54,
                          letterSpacing: 1, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(balance,
                          style: const TextStyle(fontSize: 36,
                              fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text('SUM',
                            style: TextStyle(fontSize: 16, color: Colors.white70,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_maskPhone(phone),
                          style: const TextStyle(fontSize: 13, color: Colors.white38,
                              letterSpacing: 2)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC40),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('YECHIB OLISH',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Rules section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ISH HAQI TIZIMI QOIDALARI',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy, letterSpacing: 0.5)),
                  const SizedBox(height: 16),
                  _ruleItem('Har bir mahsulot haridi uchun sizga '
                      'kafolatlangan ish haqi yoziladi.'),
                  const SizedBox(height: 12),
                  _ruleItem('Ish haqini naqdilashtirish uchun ariza '
                      "24 soat davomida ko'rib chiqiladi."),
                  const SizedBox(height: 12),
                  _ruleItem('Minimal yechish miqdori: 10 000 sum.',
                      bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _ruleItem(String text, {bool bold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8, height: 8,
          decoration: const BoxDecoration(
            color: AppColors.darkNavy,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: AppColors.darkNavy,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  height: 1.4)),
        ),
      ],
    );
  }

  String _maskPhone(String phone) {
    if (phone.length < 4) return phone;
    final last = phone.substring(phone.length - 1);
    return '**** **** **** $last';
  }
}
