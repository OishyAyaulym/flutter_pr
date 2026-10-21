import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.items,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Item> items;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _groupCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _groupCtrl = TextEditingController(text: widget.profile.group);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _groupCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registeredCount = widget.items
        .where((item) => item.containsName(widget.profile.name))
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 40,
          child: Icon(Icons.person, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          'You are on $registeredCount lists',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Profile Name', border: OutlineInputBorder()),
          onSubmitted: (val) {
            widget.onProfileChanged(widget.profile.copyWith(name: val));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile name saved')),
            );
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _groupCtrl,
          decoration: const InputDecoration(labelText: 'Group (e.g. IS-2426)', border: OutlineInputBorder()),
          onSubmitted: (val) {
            widget.onProfileChanged(widget.profile.copyWith(group: val));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Group saved')),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('System'),
              selected: widget.themeMode == ThemeMode.system,
              onSelected: (_) => widget.onThemeModeChanged(ThemeMode.system),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Light'),
              selected: widget.themeMode == ThemeMode.light,
              onSelected: (_) => widget.onThemeModeChanged(ThemeMode.light),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Dark'),
              selected: widget.themeMode == ThemeMode.dark,
              onSelected: (_) => widget.onThemeModeChanged(ThemeMode.dark),
            ),
          ],
        ),
      ],
    );
  }
}