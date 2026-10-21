import 'package:flutter/material.dart';
import 'models/item.dart';
import 'models/profile.dart';
import 'models/seed.dart';
import 'utils/routes.dart';
import 'screens/shell.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Profile _profile = initialProfile;
  List<Item> _items = getInitialSeedItems();

  void _resetData() {
    setState(() {
      _profile = initialProfile;
      _items = getInitialSeedItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 1 App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      initialRoute: Routes.shell,
      routes: {
        Routes.shell: (_) => ShellScreen(
          items: _items,
          profile: _profile,
          themeMode: _themeMode,
          onItemsChanged: (newItems) => setState(() => _items = newItems),
          onProfileChanged: (p) => setState(() => _profile = p),
          onThemeModeChanged: (m) => setState(() => _themeMode = m),
          onResetData: _resetData,
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.detail) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null) {
            return MaterialPageRoute<void>(
              builder: (_) => DetailScreen(
                item: args['item'] as Item,
                profile: _profile,
                onItemChanged: args['onItemChanged'] as ValueChanged<Item>,
                onDeleted: args['onDeleted'] as VoidCallback?,
                onSwitchTab: args['onSwitchTab'] as ValueChanged<int>,
              ),
            );
          }
        }
        if (settings.name == Routes.form) {
          final item = settings.arguments as Item?;
          return MaterialPageRoute<Item?>(
            builder: (_) => FormScreen(item: item),
          );
        }
        return null;
      },
      onUnknownRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Not found')),
        ),
      ),
    );
  }
}