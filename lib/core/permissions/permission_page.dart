import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool _notifGranted = false;
  bool _locationGranted = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAll();
  }

  Future<void> _checkAll() async {
    setState(() => _loading = true);
    await Future.wait([_checkNotification(), _checkLocation()]);
    setState(() => _loading = false);
    _proceedIfReady();
  }

  Future<void> _checkNotification() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    setState(() => _notifGranted = granted);
  }

  Future<void> _checkLocation() async {
    final status = await Geolocator.checkPermission();
    setState(() => _locationGranted =
        status == LocationPermission.always || status == LocationPermission.whileInUse);
  }

  void _proceedIfReady() {
    if (_notifGranted && _locationGranted) {
      context.go('/login');
    }
  }

  Future<void> _requestNotification() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    setState(() => _notifGranted = granted);
    _proceedIfReady();
  }

  Future<void> _requestLocation() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      await _checkLocation();
      _proceedIfReady();
      return;
    }
    status = await Geolocator.requestPermission();
    setState(() => _locationGranted =
        status == LocationPermission.always || status == LocationPermission.whileInUse);
    _proceedIfReady();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4C400),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Color(0xFF0E1A33),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ruxsatlar kerak',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0E1A33),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ilovani to\'liq ishlatish uchun quyidagi ruxsatlarga ruxsat bering',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9EA6B3),
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    _PermissionTile(
                      icon: Icons.notifications_outlined,
                      activeIcon: Icons.notifications,
                      title: 'Bildirishnomalar',
                      subtitle: 'Yangi zakazlar va takliflar haqida xabar oling',
                      granted: _notifGranted,
                      onTap: _notifGranted ? null : _requestNotification,
                    ),
                    const SizedBox(height: 16),
                    _PermissionTile(
                      icon: Icons.location_on_outlined,
                      activeIcon: Icons.location_on,
                      title: 'Joylashuv',
                      subtitle: 'Yaqin dillerlarni topish uchun joylashuvingiz kerak',
                      granted: _locationGranted,
                      onTap: _locationGranted ? null : _requestLocation,
                    ),
                    const Spacer(flex: 2),
                    if (!_notifGranted || !_locationGranted)
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Hozircha o\'tkazib yuborish',
                          style: TextStyle(color: Color(0xFF9EA6B3), fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: granted ? const Color(0xFFF0FFF4) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: granted ? const Color(0xFF34C759) : const Color(0xFFE3E6EC),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: granted
                  ? const Color(0xFF34C759).withValues(alpha: 0.12)
                  : const Color(0xFFF4C400).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              granted ? activeIcon : icon,
              color: granted ? const Color(0xFF34C759) : const Color(0xFFF4C400),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0E1A33),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9EA6B3),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (granted)
            const Icon(Icons.check_circle, color: Color(0xFF34C759), size: 28)
          else
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0E1A33),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onTap,
              child: const Text(
                'Yoqish',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}
