import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 180, 120, 37)
        ),
      ),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key, required this.title, required this.message});

  final String title;
  final Text message;

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Todo> _todos = <Todo>[];
  final TextEditingController _textFieldController = TextEditingController();

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a todo'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Type your task'),
            autofocus: true,
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addTodoItem(String name) {
    setState(() {
      DateTime now = DateTime.now();
      _todos.add(Todo(id: now, name: name, completed: false));
    });
    _textFieldController.clear();
  }

  void _deleteTodo(Todo todo) {
    setState(() {
      _todos.removeWhere((item) => item.id == todo.id);
    });
  }

  void _handleTodoChange(Todo todo) {
    setState(() {
      todo.completed = !todo.completed;
    });
  }

  void _updateTodo(Todo todo, String newName) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index].name = newName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _todos.isEmpty
      ? Center(child: Text('No todo exists. Please create one and track your work', style: TextStyle(fontSize: 18)))
      : ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _todos.map((Todo todo) {
          return TodoItem(
            todo: todo,
            onTodoChanged: _handleTodoChange,
            removeTodo: _deleteTodo,
            updateTodo: _updateTodo,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(),
        tooltip: 'Agregar una tarea',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Todo {
  Todo({required this.id, required this.name, required this.completed});
  DateTime id;
  String name;
  bool completed;
}

class TodoItem extends StatelessWidget {
  TodoItem({
    required this.todo,
    required this.onTodoChanged,
    required this.removeTodo,
    required this.updateTodo,
  }) : super(key: ObjectKey(todo));

  final void Function(Todo todo) onTodoChanged;
  final Todo todo;
  final void Function(Todo todo) removeTodo;
  final void Function(Todo todo, String newName) updateTodo;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTodoChanged(todo);
      },
      leading: Checkbox(
        checkColor: const Color.fromARGB(255, 0, 0, 0),
        activeColor: const Color.fromARGB(255, 85, 84, 84),
        value: todo.completed,
        onChanged: (value) {
          onTodoChanged(todo);
        },
      ),
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(todo.name, style: _getTextStyle(todo.completed)),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              final controller = TextEditingController(text: todo.name);
              final result = await showDialog<String?>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Edit todo'),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Edit task'),
                    onSubmitted: (value) {
                      Navigator.of(context).pop(value);
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(controller.text),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (result != null && result.trim().isNotEmpty) {
                updateTodo(todo, result.trim());
              }
            },
          ),
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.delete, color: Colors.red),
            alignment: Alignment.centerRight,
            onPressed: () { removeTodo(todo); },
          ),
        ],
      ),
    );
  }
}
