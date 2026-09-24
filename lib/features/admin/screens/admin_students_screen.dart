import 'package:flutter/material.dart';

class AdminStudentsScreen extends StatelessWidget {
  const AdminStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Студенты')),
      body: const Center(child: Text('Здесь будет список студентов')),
    );
  }
}
