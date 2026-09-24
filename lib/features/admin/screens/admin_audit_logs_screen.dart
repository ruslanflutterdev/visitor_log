import 'package:flutter/material.dart';

class AdminAuditLogsScreen extends StatelessWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Аудит логи')),
      body: const Center(child: Text('Здесь будет список аудит логов')),
    );
  }
}
