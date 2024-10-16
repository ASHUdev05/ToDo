import 'package:flutter/material.dart';
import 'package:todo_offline/model/todo.dart';
import 'package:todo_offline/services/todo_db.dart';
import 'package:todo_offline/components/todo_list.dart';
import 'package:todo_offline/navbarControllers/add_todo_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ToDos for Today!"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight - 80,
            child: TodoList(
              todos: todos,
              onEdit: (todo) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTodoScreen(
                      onAddTodo: (updatedTodo) {
                        editTodo(updatedTodo);
                      },
                      todo: todo,
                    ),
                  ),
                );
              },
              onDelete: deleteTodo,
              onComplete: completeTodo,
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
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}