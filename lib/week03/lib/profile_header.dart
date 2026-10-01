import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  final String name;
  final String university;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/ayaulym.jpg', width: 120, height: 120),
        const SizedBox(height: 16),
        Text(name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 24)),
        const SizedBox(height: 8),
        Text(university, textAlign: TextAlign.center),
      ],
    );
  }
}
