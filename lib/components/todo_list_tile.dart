import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_offline/model/todo.dart';
import 'package:todo_offline/services/local_notification.dart';
import 'package:todo_offline/detail_screen.dart';

class TodoListTile extends StatelessWidget {
  final Todo todo;
  final Function(Todo) onEdit;
  final Function(String) onDelete;
  final Function(String) onComplete;

  const TodoListTile({
    super.key,
    required this.todo,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: _getPriorityColor(todo.priority),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(todo.title),
        subtitle: Text("Due in ${_getTimeLeft(todo.dateCompleted)}"),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: todo.isCompleted,
              onChanged: (value) async {
                if (value == true) {
                  LocalNotification.showSimpleNotification(
                    id: 0,
                    title: 'Todo ${todo.title} completed',
                    body: 'Todo ${todo.title} has been completed',
                    chanId: 'todo_offline',
                    payload: 'item x completed',
                  );
                }
                onComplete(todo.id);
              },
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(todo),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await LocalNotification.handleTodoDeletionNotifications(todo.id, todo.title);
                onDelete(todo.id);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(todo: todo),
            ),
          );
        },
      ),
    );
  }

  String _getTimeLeft(String dateCompleted) {
    if (dateCompleted.isEmpty) {
      return 'No date set';
    }
    try {
      final now = DateTime.now();
      final completedDate = DateFormat('yyyy-MM-dd').parse(dateCompleted);
      final difference = completedDate.difference(now).inDays;
      return difference > 7 ? '>1 week' : '$difference days';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.white;
    }
  }
}