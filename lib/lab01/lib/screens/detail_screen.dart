import 'dart:async';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/profile.dart';
import '../utils/format.dart';
import '../utils/routes.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.item,
    required this.profile,
    required this.onItemChanged,
    this.onDeleted,
    required this.onSwitchTab,
  });

  final Item item;
  final Profile profile;
  final ValueChanged<Item> onItemChanged;
  final VoidCallback? onDeleted;
  final ValueChanged<int> onSwitchTab;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handlePrimaryAction() async {
    if (widget.profile.name.isEmpty) {
      final currentContext = context;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: const Text('Please set your profile name first.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              widget.onSwitchTab(2);
              Navigator.pop(currentContext);
            },
          ),
        ),
      );
      return;
    }

    final isAlreadyJoined = widget.item.containsName(widget.profile.name);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAlreadyJoined ? 'Cancel Registration?' : 'Confirm Registration'),
        content: Text(isAlreadyJoined
            ? 'Do you want to leave this event?'
            : 'Do you want to register for ${widget.item.title}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      final list = List<String>.from(widget.item.attendees);
      if (isAlreadyJoined) {
        list.remove(widget.profile.name);
      } else {
        list.add(widget.profile.name);
      }
      widget.onItemChanged(widget.item.copyWith(attendees: list));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isJoined = item.containsName(widget.profile.name);
    final canAct = !item.isFull || isJoined;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton<String>(
              onSelected: (val) async {
                if (val == 'edit') {
                  final edited = await Navigator.pushNamed<Item>(
                    context,
                    Routes.form,
                    arguments: item,
                  );
                  if (!mounted) return;
                  if (edited != null) {
                    widget.onItemChanged(edited);
                  }
                } else if (val == 'delete') {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete Item'),
                      content: const Text('Are you sure you want to delete this event?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (!mounted) return;
                  if (ok == true) {
                    widget.onDeleted?.call();
                    Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'About'),
              Tab(text: 'Attendees (${item.count})'),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Theme.of(context).colorScheme.primaryContainer),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Icon(item.category.icon, size: 40),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Chip(label: Text(item.category.label)),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Text(
                      switch (item.countdown) {
                        Upcoming(:final duration) => 'Starts in ${duration.inHours}h',
                        Started() => 'Event has started!',
                        Ended() => 'Event finished',
                      },
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text('Date: ${AppFormat.date(item.when)}'),
                        Text('Places taken: ${item.places.taken} / ${item.limit} (Free: ${item.places.free})'),
                        if (item.description != null) ...[
                          const SizedBox(height: 12),
                          Text(item.description!),
                        ],
                      ],
                    ),
                  ),
                  ListView.builder(
                    itemCount: item.attendees.length,
                    itemBuilder: (_, i) {
                      final name = item.attendees[i];
                      final isYou = name == widget.profile.name;
                      return ListTile(
                        title: Text(isYou ? 'You ($name)' : name),
                        leading: const Icon(Icons.person),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: canAct ? _handlePrimaryAction : null,
            child: Text(isJoined ? 'Cancel Registration' : 'Register'),
          ),
        ),
      ),
    );
  }
}