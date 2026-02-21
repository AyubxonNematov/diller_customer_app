import 'package:flutter/material.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil sozlash')),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Ism, viloyat/tuman — bu yerda sozlanadi'),
          ],
        ),
      ),
    );
  }
}
