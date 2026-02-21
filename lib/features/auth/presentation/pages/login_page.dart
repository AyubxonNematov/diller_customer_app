import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/features/auth/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
            return _VerifyCodeView(phone: state.phone);
          }
          return _PhoneView();
        },
      ),
    );
  }
}

class _PhoneView extends StatefulWidget {
  @override
  State<_PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<_PhoneView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Telefon raqamingizni kiriting',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+998 90 123 45 67'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              context
                  .read<AuthBloc>()
                  .add(AuthSendCode(_controller.text.trim()));
            },
            child: const Text('Kod yuborish'),
          ),
        ],
      ),
    );
  }
}

class _VerifyCodeView extends StatefulWidget {
  const _VerifyCodeView({required this.phone});
  final String phone;

  @override
  State<_VerifyCodeView> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<_VerifyCodeView> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${widget.phone} ga yuborilgan kodni kiriting',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '0000'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Ism (ixtiyoriy)'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthVerify(
                    phone: widget.phone,
                    code: _codeController.text.trim(),
                    name: _nameController.text.trim().isEmpty
                        ? null
                        : _nameController.text.trim(),
                  ));
            },
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }
}
