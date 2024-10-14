class Todo {
  final String id;
  final String title;
  final String description;
  final String dateCompleted;
  late int priority;
  late bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.dateCompleted,
    required this.priority,
    required this.isCompleted,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateCompleted': dateCompleted,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Todo{id: $id, title: $title, description: $description, dateCompleted: $dateCompleted, priority: $priority, isCompleted: $isCompleted,}';
  }
}
