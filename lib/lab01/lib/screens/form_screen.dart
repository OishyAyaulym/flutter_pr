import 'package:flutter/material.dart';
import '../models/item.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, this.item});
  final Item? item;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _limitCtrl;

  late EventCategory _category;
  late DateTime _when;
  late bool _mode;
  late bool _favourite;

  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final source = widget.item ?? Item.empty();
    _titleCtrl = TextEditingController(text: source.title);
    _descCtrl = TextEditingController(text: source.description ?? '');
    _limitCtrl = TextEditingController(text: source.limit.toString());

    _category = source.category;
    _when = source.when;
    _mode = source.mode;
    _favourite = source.favourite;

    for (var ctrl in [_titleCtrl, _descCtrl, _limitCtrl]) {
      ctrl.addListener(() => setState(() => _dirty = true));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final result = Item(
      title: _titleCtrl.text.trim(),
      category: _category,
      when: _when,
      limit: int.parse(_limitCtrl.text.trim()),
      attendees: widget.item?.attendees ?? const [],
      mode: _mode,
      description: _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
      favourite: _favourite,
    );

    Navigator.pop(context, result);
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (time == null || !mounted) return;

    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Discard changes?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep editing')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Discard')),
            ],
          ),
        );
        if (!mounted) return;
        if (discard == true) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.item == null ? 'New Event' : 'Edit Event'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  maxLength: 60,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Title (3-60 chars)'),
                  validator: (v) {
                    if (v == null || v.length < 3 || v.length > 60) {
                      return 'Must be between 3 and 60 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<EventCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: EventCategory.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _category = val;
                        _dirty = true;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _limitCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Limit (1-500)'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1 || n > 500) {
                      return 'Enter a number 1-500';
                    }
                    if (widget.item != null && n < widget.item!.count) {
                      return 'Cannot be below current attendee count';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Online Mode'),
                  value: _mode,
                  onChanged: (val) {
                    setState(() {
                      _mode = val;
                      _dirty = true;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: _mode ? 'Location Link (must contain ://)' : 'Description (optional)',
                  ),
                  validator: (v) {
                    if (_mode && (v == null || !v.contains('://'))) {
                      return 'Online mode requires a valid link with ://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Date & Time'),
                  subtitle: Text(_when.toString()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateTime,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}