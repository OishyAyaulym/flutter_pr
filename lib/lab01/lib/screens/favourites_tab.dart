import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/profile.dart';
import '../utils/format.dart';
import '../utils/routes.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.items,
    required this.profile,
    required this.onItemsChanged,
    required this.onSwitchTab,
  });

  final List<Item> items;
  final Profile profile;
  final ValueChanged<List<Item>> onItemsChanged;
  final ValueChanged<int> onSwitchTab;

  @override
  Widget build(BuildContext context) {
    final favs = items.where((e) => e.favourite).toList();

    if (favs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No favourites added yet.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: favs.length,
      itemBuilder: (_, i) {
        final item = favs[i];
        return Card(
          child: ListTile(
            leading: Icon(item.category.icon),
            title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(AppFormat.date(item.when)),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                final updated = item.copyWith(favourite: false);
                final list = List<Item>.from(items);
                final idx = list.indexWhere((e) => e.title == item.title);
                if (idx != -1) {
                  list[idx] = updated;
                  onItemsChanged(list);
                }
              },
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.detail,
                arguments: {
                  'item': item,
                  'onItemChanged': (updated) {
                    final idx = items.indexWhere((e) => e.title == item.title);
                    if (idx != -1) {
                      final list = List<Item>.from(items);
                      list[idx] = updated;
                      onItemsChanged(list);
                    }
                  },
                  'onDeleted': () {
                    final list = List<Item>.from(items);
                    list.removeWhere((e) => e.title == item.title);
                    onItemsChanged(list);
                  },
                  'onSwitchTab': onSwitchTab,
                },
              );
            },
          ),
        );
      },
    );
  }
}