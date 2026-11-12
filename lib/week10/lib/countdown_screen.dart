import 'dart:async';
import 'package:flutter/material.dart';
import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _currentIndex = 0; // 0 - StreamBuilder, 1 - Listen with manual cancel

  // Версия А: поле для StreamBuilder
  late final Stream<int> _stream = countdown(10);

  // Версия Б: ручная подписка
  int _left = 10;
  late final StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    // Инициализация ручной подписки для версии Б
    _sub = countdown(10).listen((i) {
      if (mounted) {
        setState(() => _left = i);
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel(); // Обязательно отменяем во избежание утечки памяти!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('StreamBuilder')),
              ButtonSegment(value: 1, label: Text('Manual Listen')),
            ],
            selected: {_currentIndex},
            onSelectionChanged: (val) => setState(() => _currentIndex = val.first),
          ),
        ),
      ),
      body: Center(
        child: _currentIndex == 0
            ? StreamBuilder<int>(
          stream: _stream,
          builder: (context, snapshot) {
            final value = snapshot.data ?? 10;
            return Text(
              '$value',
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
            );
          },
        )
            : Text(
          '$_left',
          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}