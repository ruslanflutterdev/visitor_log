import 'package:flutter/material.dart';
import '../../core/widgets/custom_app_bar.dart';


class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Мои группы'),
      body: const Center(child: Text('Здесь будет список групп')),
    );
  }
}
