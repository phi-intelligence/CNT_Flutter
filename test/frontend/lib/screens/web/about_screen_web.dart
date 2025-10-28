import 'package:flutter/material.dart';

class AboutScreenWeb extends StatelessWidget {
  const AboutScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('About Screen - Coming Soon'),
      ),
    );
  }
}

