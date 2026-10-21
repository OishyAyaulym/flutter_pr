import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
    required this.onReset,
  });

  final String name;
  final String email;
  final String group;
  final String birthDate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final items = [
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Name'),
        subtitle: Text(name),
      ),
      ListTile(
        leading: const Icon(Icons.email),
        title: const Text('Email'),
        subtitle: Text(email),
      ),
      ListTile(
        leading: const Icon(Icons.group),
        title: const Text('Group'),
        subtitle: Text(group),
      ),
      ListTile(
        leading: const Icon(Icons.cake),
        title: const Text('Date of Birth'),
        subtitle: Text(birthDate),
      ),
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 600) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    children: items,
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items,
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onReset,
              child: const Text('Start over'),
            ),
          ],
        ),
      ),
    );
  }
}