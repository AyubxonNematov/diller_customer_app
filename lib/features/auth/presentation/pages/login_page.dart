import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/core/firebase/firebase_notifications.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_auth/smart_auth.dart';

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
            FirebaseNotificationsService.sendFcmTokenIfAuthenticated();
            context.go('/profile');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AuthNeedsRegistration) {
            return _RegisterView(
              tempToken: state.tempToken,
              phone: state.phone,
            );
          }
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
  const _LogoWidget({this.size = 80});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/diller_logo.png',
      width: size * 2.2,
      fit: BoxFit.contain,
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
                          '998${_controller.text.replaceAll(' ', '')}';
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
  final _smartAuth = SmartAuth.instance;
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool get _allFilled => _controllers.every((c) => c.text.length == 1);
  String get _code => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _setupFocusNodes();
    for (final c in _controllers) {
      c.addListener(() => setState(() {}));
    }
    _listenForSms();
  }

  void _setupFocusNodes() {
    for (int i = 0; i < 4; i++) {
      final index = i;
      _focusNodes[index].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _controllers[index - 1].clear();
          _focusNodes[index - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  Future<void> _listenForSms() async {
    final res = await _smartAuth.getSmsWithUserConsentApi();
    if (!mounted) return;
    if (res.hasData && res.requireData.code != null) {
      _fillCode(res.requireData.code!);
    }
  }

  void _fillCode(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return;
    for (int i = 0; i < 4; i++) {
      _controllers[i].text = digits[i];
    }
    setState(() {});
    if (_allFilled && mounted) {
      context.read<AuthBloc>().add(AuthVerify(
            phone: widget.phone,
            code: _code,
          ));
    }
  }

  void _clearAll() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  void _onBoxChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _smartAuth.removeUserConsentApiListener();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
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
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tasdiqlash',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+${widget.phone} RAQAMIGA KOD YUBORILDI',
                    style: const TextStyle(
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (i) => _buildBox(i)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _clearAll,
                  child: Container(
                    width: 52,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.backspace_outlined,
                      color: AppColors.grayText,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _allFilled
                  ? () {
                      context.read<AuthBloc>().add(AuthVerify(
                            phone: widget.phone,
                            code: _code,
                          ));
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor:
                    _allFilled ? AppColors.darkNavy : AppColors.graySubtle,
              ),
              child: const Text('TASDIQLASH'),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.read<AuthBloc>().add(AuthLogout()),
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

  Widget _buildBox(int index) {
    return SizedBox(
      width: 52,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.darkNavy,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          hintText: '·',
          hintStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.graySubtle,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (v) => _onBoxChanged(index, v),
      ),
    );
  }
}

// ─── Screen 4: Registration ───

class _RegisterView extends StatefulWidget {
  const _RegisterView({required this.tempToken, required this.phone});
  final String tempToken;
  final String phone;

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _addressController = TextEditingController();
  final _nameFocus = FocusNode();
  final _surnameFocus = FocusNode();
  final _addressFocus = FocusNode();

  bool get _canSubmit => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _surnameFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthBloc>().add(AuthRegister(
          tempToken: widget.tempToken,
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim().isEmpty
              ? null
              : _surnameController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Center(child: _LogoWidget(size: 70)),
            const SizedBox(height: 32),
            const Text(
              'Ro\'yxatdan o\'tish',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+${widget.phone} RAQAMI UCHUN',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.grayText,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 28),
            _buildLabel('ISM *'),
            const SizedBox(height: 8),
            _buildField(
              controller: _nameController,
              focusNode: _nameFocus,
              hint: 'Ali',
              nextFocus: _surnameFocus,
            ),
            const SizedBox(height: 16),
            _buildLabel('FAMILIYA'),
            const SizedBox(height: 8),
            _buildField(
              controller: _surnameController,
              focusNode: _surnameFocus,
              hint: 'Karimov',
              nextFocus: _addressFocus,
            ),
            const SizedBox(height: 16),
            _buildLabel('MANZIL'),
            const SizedBox(height: 8),
            _buildField(
              controller: _addressController,
              focusNode: _addressFocus,
              hint: 'Toshkent, Chilonzor tumani...',
              maxLines: 2,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _canSubmit ? _submit() : null,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _canSubmit ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor:
                    _canSubmit ? AppColors.darkNavy : AppColors.graySubtle,
              ),
              child: const Text('SAQLASH VA KIRISH'),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => context.read<AuthBloc>().add(AuthLogout()),
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
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.grayText,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    FocusNode? nextFocus,
    int maxLines = 1,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        textInputAction: textInputAction,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.darkNavy,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.graySubtle,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onSubmitted: onSubmitted ??
            (_) {
              if (nextFocus != null) nextFocus.requestFocus();
            },
      ),
    );
  }
}
