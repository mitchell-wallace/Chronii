import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';
import '../widgets/base/base_empty_state.dart';
import '../widgets/todo/todo_form.dart';
import '../widgets/todo/todo_card.dart';

/// Screen for displaying and managing todo items
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with SingleTickerProviderStateMixin {
  // Use our Todo service for persistence
  final TodoService _todoService = TodoService();
  late AnimationController _animationController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Initialize the todo service and load saved todos
    _initTodoService();
  }

  Future<void> _initTodoService() async {
    setState(() {
      _isLoading = true;
    });
    
    await _todoService.init();
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _addTodo(String title) async {
    if (title.trim().isEmpty) return;
    
    // Add using the service
    await _todoService.addTodo(title);
    
    setState(() {}); // Refresh UI
    
    // Animate and scroll to the bottom
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _toggleTodo(String id) async {
    // Toggle using the service
    await _todoService.toggleTodoCompletion(id);
    setState(() {}); // Refresh UI
  }

  Future<void> _deleteTodo(String id) async {
    // Delete using the service
    await _todoService.deleteTodo(id);
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    final todos = _todoService.todos;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Todo Form
          TodoForm(
            onSubmit: _addTodo,
          ),
          
          const SizedBox(height: 16),
          
          // Todo List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : todos.isEmpty
                    ? const BaseEmptyState(
                        icon: Icons.check_circle_outline,
                        message: 'No tasks yet',
                        subMessage: 'Add one to get started',
                      )
                    : ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          
                          return TodoCard(
                            todo: todo,
                            onToggle: () => _toggleTodo(todo.id),
                            onDelete: () => _deleteTodo(todo.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
