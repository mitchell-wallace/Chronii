import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';
import '../widgets/base/base_input_form.dart';
import '../widgets/base/base_item_card.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> with SingleTickerProviderStateMixin {
  // Use our new Todo service for persistence
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
    
    // Add default tasks only if we don't have any todos yet
    if (_todoService.totalCount == 0) {
      await _todoService.addTodo('Learn Flutter basics');
      await _todoService.addTodo('Build a simple todo app');
      await _todoService.addTodo('Deploy to mobile and web');
      
      // Mark the first task as completed
      final firstTodo = _todoService.todos.first;
      await _todoService.toggleTodoCompletion(firstTodo.id);
    }
    
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
    final theme = Theme.of(context);
    final todos = _todoService.todos;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Todo Input Form - using our new base component
          BaseInputForm(
            hintText: 'Add a new task',
            buttonText: 'Add',
            autoFocus: false,
            showBorder: false,
            onSubmit: _addTodo,
          ),
          
          const SizedBox(height: 16),
          
          // Todo List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : todos.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          
                          // Using our new base component for the todo item
                          return BaseItemCard(
                            itemKey: Key(todo.id),
                            title: todo.title,
                            subtitle: todo.description,
                            isCompleted: todo.isCompleted,
                            onDelete: () => _deleteTodo(todo.id),
                            onTap: () => _toggleTodo(todo.id), // Tap to toggle completion
                            leading: Checkbox(
                              value: todo.isCompleted,
                              onChanged: (_) => _toggleTodo(todo.id),
                              activeColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTodo(todo.id),
                                tooltip: 'Delete Task',
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
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
    );
  }
} 