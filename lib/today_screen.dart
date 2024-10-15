import 'package:flutter/material.dart';
import 'package:todo_offline/detail_screen.dart';
import 'package:todo_offline/model/todo.dart';
import 'package:todo_offline/navbarControllers/add_todo_screen.dart';
import 'package:todo_offline/model/todo_db.dart';
import 'package:intl/intl.dart';
import 'package:todo_offline/services/local_notification.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen(BuildContext context, {super.key});

  @override
  State<TodayScreen> createState() {
    return _TodayScreenState();
  }
}

class _TodayScreenState extends State<TodayScreen> {
  final TodoDatabase _todoDatabase = TodoDatabase();
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final loadedTodos = await _todoDatabase.getTodos();
    setState(() {
      todos = loadedTodos;
    });
  }

  void addTodo(Todo todo) {
    setState(() {
      todos.add(todo);
    });
  }

  void editTodo(Todo todo) async {
    await _todoDatabase.updateTodo(todo);
    _loadTodos();
  }

  void deleteTodo(String id) async {
    await _todoDatabase.deleteTodo(id);
    _loadTodos();
  }

  void completeTodo(String id) async {
    await _todoDatabase.completeTodo(id);
    _loadTodos();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ToDos for Today!"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(todos[index].priority),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text(todos[index].title),
                    subtitle: Text(
                        "Due in ${_getTimeLeft(todos[index].dateCompleted)}"),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: todos[index].isCompleted,
                          onChanged: (value) async {
                            setState(() {
                              todos[index].isCompleted = value!;
                            });

                            if (value == true) {
                              LocalNotification.showSimpleNotification(
                                id: 0,
                                title: 'Todo ${todos[index].title} completed',
                                body:
                                    'Todo ${todos[index].title} has been completed',
                                chanId: 'todo_offline',
                                payload: 'item x completed',
                              );
                            }
                            int notificationId =
                                ('${todos[index].id}hourly').hashCode;
                            if (await LocalNotification.isNotificationScheduled(
                                notificationId)) {
                              LocalNotification.cancelNotification(
                                  notificationId);
                            }
                            notificationId =
                                ('${todos[index].id}daily').hashCode;
                            if (await LocalNotification.isNotificationScheduled(
                                notificationId)) {
                              LocalNotification.cancelNotification(
                                  notificationId);
                            }
                            completeTodo(todos[index].id);
                          },
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTodoScreen(
                                  onAddTodo: (updatedTodo) {
                                    editTodo(updatedTodo);
                                  },
                                  todo: todos[index],
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            int notificationId =
                                ('${todos[index].id}hourly').hashCode;
                            if (await LocalNotification.isNotificationScheduled(
                                notificationId)) {
                              LocalNotification.cancelNotification(
                                  notificationId);
                            }
                            notificationId =
                                ('${todos[index].id}daily').hashCode;
                            if (await LocalNotification.isNotificationScheduled(
                                notificationId)) {
                              LocalNotification.cancelNotification(
                                  notificationId);
                            }
                            LocalNotification.showSimpleNotification(
                              id: 0,
                              title: 'Todo ${todos[index].title} deleted',
                              body:
                                  'Todo ${todos[index].title} has been deleted',
                              chanId: 'todo_offline',
                              payload: 'item x deleted',
                            );

                            deleteTodo(todos[index].id);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(todo: todos[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddTodoScreen(
                        onAddTodo: addTodo,
                      )));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
