import 'package:flutter/material.dart';

class NotificationsScreenWeb extends StatelessWidget {
  const NotificationsScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Notifications Screen - Coming Soon'),
      ),
    );
  }
}

