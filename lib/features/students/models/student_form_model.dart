import 'package:flutter/material.dart';

class StudentFormModel {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController middleName = TextEditingController();
  final TextEditingController phone = TextEditingController();
  DateTime? birthDate;

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    middleName.dispose();
    phone.dispose();
  }
}
