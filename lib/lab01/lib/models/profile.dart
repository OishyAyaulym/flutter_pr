class Profile {
  final String name;
  final String group;

  const Profile({required this.name, required this.group});

  factory Profile.empty() => const Profile(name: '', group: '');

  Profile copyWith({String? name, String? group}) => Profile(
    name: name ?? this.name,
    group: group ?? this.group,
  );
}