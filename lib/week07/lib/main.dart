import 'package:flutter/material.dart';
import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    ),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();

  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthController]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _birth = picked;
      _birthController.text =
      '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created')),
      );
      setState(() {
        _done = true;
      });
    }
  }

  void _reset() {
    _name.clear();
    _email.clear();
    _password.clear();
    _confirm.clear();
    _birthController.clear();

    setState(() {
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: _done
          ? Center(
        child: SummaryCard(
          name: _name.text,
          email: _email.text,
          group: _group ?? '',
          birthDate: _birthController.text,
          onReset: _reset,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                validator: (v) {
                  final val = (v ?? '').trim();
                  if (val.length < 2) return 'Name is too short';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Email Field
              TextFormField(
                controller: _email,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@kbtu.kz',
                ),
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  final val = (v ?? '').trim();
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Email looks wrong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Password Field
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  helperText: 'At least 8 characters',
                ),
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  final val = v ?? '';
                  if (val.length < 8) return 'Password is too short';
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${_password.text.length} of 8',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),

              // Confirm Password Field
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
                textInputAction: TextInputAction.done,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onFieldSubmitted: (_) => _agreed ? _submit() : null,
                validator: (v) {
                  if (v != _password.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _group,
                decoration: const InputDecoration(labelText: 'Group'),
                items: [
                  for (final g in groups)
                    DropdownMenuItem(value: g, child: Text(g)),
                ],
                onChanged: (g) => setState(() => _group = g),
                validator: (g) =>
                g == null ? 'Choose a group' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _birthController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of birth',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _selectDate,
                validator: (_) =>
                _birth == null ? 'Select date of birth' : null,
              ),
              const SizedBox(height: 12),

              CheckboxListTile(
                value: _agreed,
                title: const Text('I agree to the rules'),
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _agreed = v ?? false),
              ),
              const SizedBox(height: 24),

              // Submit Button
              FilledButton(
                onPressed: _agreed ? _submit : null,
                child: const Text('Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}