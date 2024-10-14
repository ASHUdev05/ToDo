class Todo {
  final String id;
  final String title;
  final String description;

  const Todo({
    required this.id,
    required this.title,
    required this.description,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Todo{id: $id, title: $title, description: $description}';
  }
}
