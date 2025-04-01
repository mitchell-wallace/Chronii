import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';
import '../services/timer_service.dart';
import '../services/navigation_service.dart';
import '../utils/priority_utils.dart';
import '../widgets/base/base_empty_state.dart';
import '../widgets/todo/todo_form.dart';
import '../widgets/todo/todo_card.dart';
import '../widgets/todo/todo_summary.dart';

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
  
  // Selected todo IDs
  final Set<String> _selectedTodoIds = {};
  
  // Filter & Sort states
  String? _selectedTagFilter;
  TodoPriority? _selectedPriorityFilter;
  bool _showCompletedTasks = true;
  
  // Sort options
  TodoSortOption _sortOption = TodoSortOption.creationDate;
  bool _sortAscending = false;

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
  
  Future<void> _addDetailedTodo(
    String title, {
    String? description,
    DateTime? dueDate,
    TodoPriority priority = TodoPriority.medium,
    List<String>? tags,
  }) async {
    if (title.trim().isEmpty) return;
    
    // Add using the service
    await _todoService.addTodo(
      title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      tags: tags,
    );
    
    setState(() {}); // Refresh UI
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
  
  // Toggle todo selection
  void _toggleTodoSelection(String todoId) {
    setState(() {
      if (_selectedTodoIds.contains(todoId)) {
        _selectedTodoIds.remove(todoId);
      } else {
        _selectedTodoIds.add(todoId);
      }
    });
  }
  
  // Deselect all todos
  void _deselectAllTodos() {
    print("Deselecting all todos");
    setState(() {
      _selectedTodoIds.clear();
    });
  }
  
  // Delete all selected todos
  Future<void> _deleteSelectedTodos() async {
    // Show confirmation dialog
    final shouldDelete = await _showDeleteConfirmationDialog();
    if (shouldDelete != true) return;
    
    // Delete all selected todos
    for (final todoId in _selectedTodoIds.toList()) {
      await _todoService.deleteTodo(todoId);
    }
    
    setState(() {
      _selectedTodoIds.clear();
    });
  }
  
  // Show confirmation dialog before deleting multiple todos
  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Tasks'),
        content: Text(
          'Are you sure you want to delete ${_selectedTodoIds.length} '
          '${_selectedTodoIds.length == 1 ? 'task' : 'tasks'}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  // Update a todo
  Future<void> _updateTodo(Todo updatedTodo) async {
    await _todoService.updateTodo(updatedTodo);
    setState(() {}); // Refresh UI
  }
  
  // Filter and sort todos
  List<Todo> _getFilteredAndSortedTodos() {
    // Create a mutable copy of the todos list
    List<Todo> filteredTodos = List<Todo>.from(_todoService.todos);
    
    // Apply completed filter
    if (!_showCompletedTasks) {
      filteredTodos = filteredTodos.where((todo) => !todo.isCompleted).toList();
    }
    
    // Apply tag filter
    if (_selectedTagFilter != null) {
      filteredTodos = filteredTodos.where((todo) => 
        todo.tags.contains(_selectedTagFilter)).toList();
    }
    
    // Apply priority filter
    if (_selectedPriorityFilter != null) {
      filteredTodos = filteredTodos.where((todo) => 
        todo.priority == _selectedPriorityFilter).toList();
    }
    
    // Apply sorting
    switch (_sortOption) {
      case TodoSortOption.creationDate:
        filteredTodos.sort((a, b) => _sortAscending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case TodoSortOption.dueDate:
        filteredTodos.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return _sortAscending ? 1 : -1;
          if (b.dueDate == null) return _sortAscending ? -1 : 1;
          return _sortAscending
              ? a.dueDate!.compareTo(b.dueDate!)
              : b.dueDate!.compareTo(a.dueDate!);
        });
        break;
      case TodoSortOption.priority:
        filteredTodos.sort((a, b) => _sortAscending
            ? a.priority.index.compareTo(b.priority.index)
            : b.priority.index.compareTo(a.priority.index));
        break;
      case TodoSortOption.alphabetical:
        filteredTodos.sort((a, b) => _sortAscending
            ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
            : b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case TodoSortOption.completed:
        filteredTodos.sort((a, b) => _sortAscending
            ? (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0)
            : (a.isCompleted ? 0 : 1).compareTo(b.isCompleted ? 0 : 1));
        break;
    }
    
    return filteredTodos;
  }
  
  void _showFilterSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Filter & Sort',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Show/hide completed tasks
                  SwitchListTile(
                    title: const Text('Show completed tasks'),
                    value: _showCompletedTasks,
                    onChanged: (value) {
                      setSheetState(() {
                        _showCompletedTasks = value;
                      });
                      setState(() {});
                    },
                  ),
                  
                  const Divider(),
                  
                  // Sort options
                  ListTile(
                    title: const Text('Sort by'),
                    trailing: DropdownButton<TodoSortOption>(
                      value: _sortOption,
                      onChanged: (newValue) {
                        if (newValue == null) return;
                        setSheetState(() {
                          _sortOption = newValue;
                        });
                        setState(() {});
                      },
                      items: TodoSortOption.values.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option.displayName),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // Sort direction
                  SwitchListTile(
                    title: Text(_sortOption == TodoSortOption.dueDate ||
                            _sortOption == TodoSortOption.creationDate
                        ? 'Sort oldest first'
                        : _sortOption == TodoSortOption.alphabetical
                            ? 'Sort A to Z'
                            : _sortOption == TodoSortOption.priority
                                ? 'Sort low to high'
                                : 'Sort completed first'),
                    value: _sortAscending,
                    onChanged: (value) {
                      setSheetState(() {
                        _sortAscending = value;
                      });
                      setState(() {});
                    },
                  ),
                  
                  const Divider(),
                  
                  // Tag filters
                  if (_todoService.allTags.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter by tag',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Include "All" option
                              FilterChip(
                                label: const Text('All'),
                                selected: _selectedTagFilter == null,
                                onSelected: (selected) {
                                  if (selected) {
                                    setSheetState(() {
                                      _selectedTagFilter = null;
                                    });
                                    setState(() {});
                                  }
                                },
                              ),
                              ..._todoService.allTags.map((tag) {
                                return FilterChip(
                                  label: Text(tag),
                                  selected: _selectedTagFilter == tag,
                                  onSelected: (selected) {
                                    setSheetState(() {
                                      _selectedTagFilter = selected ? tag : null;
                                    });
                                    setState(() {});
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(),
                  ],
                  
                  // Priority filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter by priority',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Include "All" option
                            FilterChip(
                              label: const Text('All'),
                              selected: _selectedPriorityFilter == null,
                              onSelected: (selected) {
                                if (selected) {
                                  setSheetState(() {
                                    _selectedPriorityFilter = null;
                                  });
                                  setState(() {});
                                }
                              },
                            ),
                            ...TodoPriority.values.map((priority) {
                              return FilterChip(
                                label: Text(PriorityUtils.getPriorityName(priority)),
                                selected: _selectedPriorityFilter == priority,
                                avatar: Icon(
                                  PriorityUtils.getPriorityIcon(priority),
                                  color: PriorityUtils.getPriorityColor(priority),
                                  size: 16,
                                ),
                                onSelected: (selected) {
                                  setSheetState(() {
                                    _selectedPriorityFilter = selected ? priority : null;
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Create a timer from a todo
  void _createTimerFromTodo(String todoTitle) {
    // Use singleton NavigationService
    final navigationService = NavigationService();
    navigationService.createTimerFromTodo(todoTitle);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = _getFilteredAndSortedTodos();
    final completedCount = filteredTodos.where((todo) => todo.isCompleted).length;
    final totalCount = filteredTodos.length;
    
    return Column(
      children: [
        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Add Todo Form
                TodoForm(
                  onSubmit: _addTodo,
                  onCreateDetailed: _addDetailedTodo,
                ),
                
                const SizedBox(height: 8),
                
                // Filter bar
                Row(
                  children: [
                    Text(
                      'Tasks: $completedCount/$totalCount',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterSortSheet,
                      tooltip: 'Filter & Sort',
                    ),
                  ],
                ),
                
                // Todo List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredTodos.isEmpty
                          ? const BaseEmptyState(
                              icon: Icons.check_circle_outline,
                              message: 'No tasks found',
                              subMessage: 'Try changing your filters or add a new task',
                            )
                          : ListView.builder(
                              itemCount: filteredTodos.length,
                              itemBuilder: (context, index) {
                                final todo = filteredTodos[index];
                                
                                return TodoCard(
                                  todo: todo,
                                  isSelected: _selectedTodoIds.contains(todo.id),
                                  onToggle: () => _toggleTodo(todo.id),
                                  onDelete: () => _deleteTodo(todo.id),
                                  onUpdate: _updateTodo,
                                  onSelect: () => _toggleTodoSelection(todo.id),
                                  onCreateTimer: _createTimerFromTodo,
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
        
        // Selected todos summary
        if (_selectedTodoIds.isNotEmpty)
          TodoSummary(
            selectedCount: _selectedTodoIds.length,
            selectedTodos: filteredTodos.where((todo) => _selectedTodoIds.contains(todo.id)).toList(),
            onDeselectAll: _deselectAllTodos,
            onDeleteAll: _deleteSelectedTodos,
          ),
      ],
    );
  }
}

/// Sort options for todos
enum TodoSortOption {
  creationDate,
  dueDate,
  priority,
  alphabetical,
  completed,
}

/// Extension to get display names for sort options
extension TodoSortOptionExtension on TodoSortOption {
  String get displayName {
    switch (this) {
      case TodoSortOption.creationDate:
        return 'Date Created';
      case TodoSortOption.dueDate:
        return 'Due Date';
      case TodoSortOption.priority:
        return 'Priority';
      case TodoSortOption.alphabetical:
        return 'Alphabetical';
      case TodoSortOption.completed:
        return 'Completion Status';
    }
  }
}
