import 'package:flutter/material.dart';
import 'api/fake_api.dart';
import 'widgets/views.dart';

class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key});

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  late final FakeApi _api;
  late final Future<List<Student>> _future;
  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _api = FakeApi();
    _future = _api.fetchStudents();
  }

  void _retry() {
    setState(() {
      _future = _api.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students (FutureBuilder)'),
        actions: [
          Switch(
            value: _compact,
            onChanged: (val) => setState(() => _compact = val),
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(onRetry: _retry);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final list = snapshot.data ?? const [];
          if (list.isEmpty) {
            return const EmptyView();
          }
          return StudentList(students: list, compact: _compact);
        },
      ),
    );
  }
}