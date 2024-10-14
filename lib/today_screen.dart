import 'package:flutter/material.dart';
import 'package:todo_offline/detail_screen.dart';
import 'package:todo_offline/model/todo.dart';
import 'package:todo_offline/navbarControllers/analytics_screen.dart';
import 'package:todo_offline/model/todo_db.dart';

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
                return ListTile(
                  title: Text(todos[index].title),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(todo: todos[index]),
                      ),
                    );
                  },
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
                  builder: (context) => AnalyticsScreen(
                        onAddTodo: addTodo,
                      )));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
