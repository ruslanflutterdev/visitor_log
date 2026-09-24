import 'package:flutter/material.dart';

class AdminCoachesScreen extends StatelessWidget {
  const AdminCoachesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тренеры')),
      body: const Center(
        child: Text('Здесь будет список тренеров и одобрение'),
      ),
    );
  }
}
