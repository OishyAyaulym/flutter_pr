import 'package:flutter/material.dart';

enum EventCategory {
  tech('Tech', Icons.code),
  culture('Culture', Icons.theater_comedy),
  sport('Sport', Icons.sports_basketball),
  study('Study', Icons.book),
  social('Social', Icons.people);

  const EventCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  ColorSchemeRole colorRole(ColorScheme scheme) => switch (this) {
    EventCategory.tech => ColorSchemeRole.primary,
    EventCategory.culture => ColorSchemeRole.secondary,
    EventCategory.sport => ColorSchemeRole.tertiary,
    EventCategory.study => ColorSchemeRole.error,
    EventCategory.social => ColorSchemeRole.surfaceVariant,
  };
}

enum ColorSchemeRole { primary, secondary, tertiary, error, surfaceVariant }

sealed class Countdown {
  const Countdown();
}
class Upcoming extends Countdown {
  final Duration duration;
  const Upcoming(this.duration);
}
class Started extends Countdown {
  final Duration duration;
  const Started(this.duration);
}
class Ended extends Countdown {
  const Ended();
}

class Item {
  final String title;
  final EventCategory category;
  final DateTime when;
  final int limit;
  final List<String> attendees;
  final bool mode;
  final String? description;
  final bool favourite;

  const Item({
    required this.title,
    required this.category,
    required this.when,
    required this.limit,
    required List<String> attendees,
    required this.mode,
    this.description,
    required this.favourite,
  }) : attendees = attendees;

  factory Item.empty() => Item(
    title: '',
    category: EventCategory.tech,
    when: DateTime.now().add(const Duration(days: 1)),
    limit: 20,
    attendees: const <String>[],
    mode: false,
    description: '',
    favourite: false,
  );

  Item copyWith({
    String? title,
    EventCategory? category,
    DateTime? when,
    int? limit,
    List<String>? attendees,
    bool? mode,
    String? description,
    bool? favourite,
  }) {
    return Item(
      title: title ?? this.title,
      category: category ?? this.category,
      when: when ?? this.when,
      limit: limit ?? this.limit,
      attendees: attendees ?? this.attendees,
      mode: mode ?? this.mode,
      description: description ?? this.description,
      favourite: favourite ?? this.favourite,
    );
  }

  int get count => attendees.length;
  int get freePlaces => limit - count;
  bool get isFull => count >= limit;
  bool get isPast => DateTime.now().isAfter(when);
  bool containsName(String name) => attendees.contains(name);

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Countdown get countdown {
    final diff = when.difference(DateTime.now());
    if (diff.isNegative) {
      if (diff.inHours > -3) {
        return Started(diff.abs());
      }
      return const Ended();
    }
    return Upcoming(diff);
  }
}