import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_exception.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KBTU Users API'),
      ),
      body: Consumer<UsersModel>(
        builder: (context, model, child) {
          if (model.loading && model.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (model.error != null && model.items.isEmpty) {
            return _buildErrorView(context, model.error!, model.load);
          }

          return RefreshIndicator(
            onRefresh: model.load,
            child: ListView.separated(
              itemCount: model.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = model.items[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text('${user.email} • ${user.address.city}'),
                  trailing: Text('ID: ${user.id}'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(user.name),
                        content: Text(
                          'Username: ${user.username}\n'
                              'Phone: ${user.phoneDigits}\n'
                              'Website: ${user.website ?? "none"}\n'
                              'Company: ${user.company.name}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUserModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ApiException error, Future<void> Function() onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: switch (error) {
          NoConnectionException() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No internet connection. Check your network.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
          NotFoundException() => const Text('Resource not found (404).'),
          UnauthorizedException() => const Text('Unauthorized access (401).'),
          ServerException(:final status) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Server error: $status', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
          BadResponseException(:final detail) => Text('Bad response from server: ${detail ?? ""}'),
        },
      ),
    );
  }

  void _showCreateUserModal(BuildContext context) {
    final model = context.read<UsersModel>();
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add New User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: model.isSubmitting
                  ? null
                  : () async {
                final success = await model.createUser(
                  name: nameController.text,
                  username: usernameController.text,
                  email: emailController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'User created successfully!' : 'Failed to create user.'),
                    ),
                  );
                }
              },
              child: model.isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}