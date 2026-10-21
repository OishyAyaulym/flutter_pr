import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/profile.dart';
import '../utils/format.dart';
import '../utils/routes.dart';

class ListTab extends StatefulWidget {
  const ListTab({
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
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  String _searchQuery = '';
  EventCategory? _selectedCategory;
  bool _showPast = true;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      if (!_showPast && item.isPast) {
        return false;
      }
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !item.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search events',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (_) => setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: 8),
                    for (final cat in EventCategory.values) ...[
                      ChoiceChip(
                        label: Text(cat.label),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) =>
                            setState(() => _selectedCategory = selected ? cat : null),
                      ),
                      const SizedBox(width: 8),
                    ],
                    FilterChip(
                      label: const Text('Show Past'),
                      selected: _showPast,
                      onSelected: (val) => setState(() => _showPast = val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No items found matching your filters.'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () async {
                        final newItem = await Navigator.pushNamed<Item>(context, Routes.form);
                        if (!mounted) return;
                        if (newItem != null) {
                          widget.onItemsChanged([newItem, ...widget.items]);
                        }
                      },
                      child: const Text('Create Event'),
                    ),
                  ),
                ],
              ),
            ),
          )
              : LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 600) {
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildCard(filtered[i]),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _buildCard(filtered[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Item item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(
            context,
            Routes.detail,
            arguments: {
              'item': item,
              'onItemChanged': (updated) {
                final index = widget.items.indexWhere((e) => e.title == item.title);
                if (index != -1) {
                  final list = List<Item>.from(widget.items);
                  list[index] = updated;
                  widget.onItemsChanged(list);
                }
              },
              'onDeleted': () {
                final list = List<Item>.from(widget.items);
                list.removeWhere((e) => e.title == item.title);
                widget.onItemsChanged(list);
              },
              'onSwitchTab': widget.onSwitchTab,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Icon(item.category.icon),
                  ),
                  if (item.isFull)
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: Badge(label: Text('FULL')),
                    )
                  else if (item.freePlaces <= 5)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Badge(label: Text('${item.freePlaces} left')),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(AppFormat.date(item.when), style: const TextStyle(fontSize: 12)),
                    Text(item.mode ? 'Online Link' : 'Campus Venue',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(item.favourite ? Icons.favorite : Icons.favorite_border,
                    color: item.favourite ? Colors.red : null),
                onPressed: () {
                  final updated = item.copyWith(favourite: !item.favourite);
                  final list = List<Item>.from(widget.items);
                  final index = list.indexWhere((e) => e.title == item.title);
                  if (index != -1) {
                    list[index] = updated;
                    widget.onItemsChanged(list);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}