import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/auth/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPhoneInput = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/notifications');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AuthCodeSent) {
            return _OtpVerifyView(phone: state.phone);
          }
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkNavy),
            );
          }
          if (_showPhoneInput) {
            return _PhoneInputView(
              onBack: () => setState(() => _showPhoneInput = false),
            );
          }
          return _WelcomeView(
            onLogin: () => setState(() => _showPhoneInput = true),
          );
        },
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget({this.size = 80, this.onDark = false});
  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'DILLER',
              style: TextStyle(
                fontSize: size * 0.28,
                fontWeight: FontWeight.w900,
                color: onDark ? Colors.white : AppColors.darkNavy,
                letterSpacing: 0.5,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: size * 0.07,
                height: size * 0.07,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Text(
              'MARKET',
              style: TextStyle(
                fontSize: size * 0.28,
                fontWeight: FontWeight.w900,
                color: onDark ? Colors.white : AppColors.darkNavy,
                letterSpacing: 0.5,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'PROFESSIONAL HARIDOR PLATFORMASI',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: onDark ? Colors.white54 : AppColors.grayText,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─── Screen 1: Welcome ───

class _WelcomeView extends StatelessWidget {
  const _WelcomeView({required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 3),
            const _LogoWidget(size: 90),
            const Spacer(flex: 3),
            FilledButton(
              onPressed: onLogin,
              child: const Text('KIRISH'),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onLogin,
              child: const Text("RO'YXATDAN O'TISH"),
            ),
            const SizedBox(height: 24),
            Text(
              'TEST RAQAM: 99 888 77 66',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grayText.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Screen 2: Phone Input ───

class _PhoneInputView extends StatefulWidget {
  const _PhoneInputView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_PhoneInputView> createState() => _PhoneInputViewState();
}

class _PhoneInputViewState extends State<_PhoneInputView> {
  final _controller = TextEditingController();
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final filled = _controller.text.replaceAll(' ', '').length >= 9;
      if (filled != _hasInput) setState(() => _hasInput = filled);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),
            const _LogoWidget(size: 80),
            const Spacer(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tizimga kirish',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'TELEFON RAQAMINGIZNI KIRITING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grayText,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text(
                    '+998',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.grayText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w500,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                        _PhoneFormatter(),
                      ],
                      decoration: const InputDecoration(
                        hintText: '00 000 00 00',
                        hintStyle: TextStyle(
                          color: AppColors.graySubtle,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _hasInput
                  ? () {
                      final phone =
                          '+998${_controller.text.replaceAll(' ', '')}';
                      context.read<AuthBloc>().add(AuthSendCode(phone));
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor:
                    _hasInput ? AppColors.darkNavy : AppColors.graySubtle,
              ),
              child: const Text('DAVOM ETISH'),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: widget.onBack,
              child: const Text(
                'ORQAGA',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grayText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 9; i++) {
      if (i == 2 || i == 5 || i == 7) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ─── Screen 3: OTP Verification ───

class _OtpVerifyView extends StatefulWidget {
  const _OtpVerifyView({required this.phone});
  final String phone;

  @override
  State<_OtpVerifyView> createState() => _OtpVerifyViewState();
}

class _OtpVerifyViewState extends State<_OtpVerifyView> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool get _allFilled =>
      _controllers.every((c) => c.text.length == 1);

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 32),
            const _LogoWidget(size: 70, onDark: true),
            const SizedBox(height: 28),
            const Text(
              'Tasdiqlash',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.phone} RAQAMIGA KOD YUBORILDI',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                letterSpacing: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.gold,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (i) {
                            return SizedBox(
                              width: 48,
                              child: TextField(
                                controller: _controllers[i],
                                focusNode: _focusNodes[i],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkNavy,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.graySubtle,
                                  ),
                                ),
                                onChanged: (v) => _onChanged(i, v),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _allFilled
                              ? () {
                                  context.read<AuthBloc>().add(AuthVerify(
                                        phone: widget.phone,
                                        code: _code,
                                      ));
                                }
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: _allFilled
                                ? AppColors.gold
                                : AppColors.goldLight,
                            foregroundColor: _allFilled
                                ? AppColors.darkNavy
                                : AppColors.grayText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'TASDIQLASH',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
