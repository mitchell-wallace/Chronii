import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> with SingleTickerProviderStateMixin {
  final List<Todo> _todos = [];
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Add default tasks
    _todos.addAll([
      Todo(
        id: '1',
        title: 'Learn Flutter basics',
        isCompleted: true,
      ),
      Todo(
        id: '2',
        title: 'Build a simple todo app',
        isCompleted: false,
      ),
      Todo(
        id: '3',
        title: 'Deploy to mobile and web',
        isCompleted: false,
      ),
    ]);
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addTodo(String title) {
    if (title.trim().isEmpty) return;
    
    setState(() {
      _todos.add(Todo(
        id: DateTime.now().toString(),
        title: title,
      ));
      _textController.clear();
    });
    
    // Animate and scroll to the bottom
    _animationController.reset();
    _animationController.forward();
  }

  void _toggleTodo(String id) {
    setState(() {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header
          Text(
            'My Tasks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Add Todo Input Field
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Add a new task',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (value) => _addTodo(value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addTodo(_textController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Todo List
          Expanded(
            child: _todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet! Add one.',
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: todo.isCompleted 
                              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Dismissible(
                          key: Key(todo.id),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16.0),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteTodo(todo.id),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Checkbox(
                              value: todo.isCompleted,
                              onChanged: (_) => _toggleTodo(todo.id),
                              activeColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: todo.isCompleted 
                                    ? FontWeight.normal 
                                    : FontWeight.w500,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.isCompleted
                                    ? theme.colorScheme.onSurface.withOpacity(0.6)
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTodo(todo.id),
                              tooltip: 'Delete Task',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 