import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/profile.dart';
import '../utils/routes.dart';
import 'list_tab.dart';
import 'favourites_tab.dart';
import 'profile_tab.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.items,
    required this.profile,
    required this.themeMode,
    required this.onItemsChanged,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
    required this.onResetData,
  });

  final List<Item> items;
  final Profile profile;
  final ThemeMode themeMode;
  final ValueChanged<List<Item>> onItemsChanged;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onResetData;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  void _navigateToForm(BuildContext context) async {
    final newItem = await Navigator.pushNamed<Item>(context, Routes.form);
    if (!mounted) return;
    if (newItem != null) {
      setState(() {
        widget.onItemsChanged([newItem, ...widget.items]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ListTab(
        items: widget.items,
        profile: widget.profile,
        onItemsChanged: widget.onItemsChanged,
        onSwitchTab: (index) => setState(() => _currentIndex = index),
      ),
      FavouritesTab(
        items: widget.items,
        profile: widget.profile,
        onItemsChanged: widget.onItemsChanged,
        onSwitchTab: (index) => setState(() => _currentIndex = index),
      ),
      ProfileTab(
        profile: widget.profile,
        items: widget.items,
        themeMode: widget.themeMode,
        onProfileChanged: widget.onProfileChanged,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events Hub'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: Text(
                'Campus Hub\n${widget.profile.name.isEmpty ? "Guest" : widget.profile.name}',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context); // R32: closes drawer
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('About App'),
                    content: const Text('Lab 1 Mobile Development App. Domain: Campus Events.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset data'),
              onTap: () async {
                Navigator.pop(context);
                final navContext = context;
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Reset Data?'),
                    content: const Text('This will restore seed items and clear your profile.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );

                if (!mounted) return;

                if (confirm == true) {
                  widget.onResetData();
                  ScaffoldMessenger.of(navContext).showSnackBar(
                    const SnackBar(content: Text('Data restored to seed values.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: tabs[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favourites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}