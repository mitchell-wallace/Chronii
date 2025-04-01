import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/todo_model.dart';
import '../../utils/priority_utils.dart';

/// Dialog for editing a todo
class TodoEditDialog extends StatefulWidget {
  /// The todo to edit
  final Todo todo;
  
  /// Callback for when the todo is updated
  final Function(Todo) onUpdate;

  const TodoEditDialog({
    super.key,
    required this.todo,
    required this.onUpdate,
  });

  @override
  State<TodoEditDialog> createState() => _TodoEditDialogState();
}

class _TodoEditDialogState extends State<TodoEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  late bool _isCompleted;
  late DateTime? _dueDate;
  late TodoPriority _priority;
  late List<String> _tags;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with current values
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description ?? '');
    _tagController = TextEditingController();
    
    // Initialize state
    _isCompleted = widget.todo.isCompleted;
    _dueDate = widget.todo.dueDate;
    _priority = widget.todo.priority;
    _tags = List<String>.from(widget.todo.tags);
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }
  
  void _saveTodo() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }
    
    // Create updated todo
    final updatedTodo = widget.todo.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      isCompleted: _isCompleted,
      dueDate: _dueDate,
      priority: _priority,
      tags: _tags,
    );
    
    // Call update callback
    widget.onUpdate(updatedTodo);
    
    // Close dialog
    Navigator.of(context).pop();
  }
  
  void _addTag() {
    final newTag = _tagController.text.trim();
    
    if (newTag.isEmpty) return;
    
    if (_tags.contains(newTag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tag "$newTag" already exists')),
      );
      return;
    }
    
    setState(() {
      _tags.add(newTag);
      _tagController.clear();
    });
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }
  
  Future<void> _selectDueDate() async {
    final initialDate = _dueDate ?? DateTime.now();
    final firstDate = DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365 * 5));
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }
  
  void _clearDueDate() {
    setState(() {
      _dueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog header
            Row(
              children: [
                // Close button
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                
                // Title
                Text(
                  'Edit Task',
                  style: theme.textTheme.headlineSmall,
                ),
                
                const Spacer(),
                
                // Save button
                TextButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Save'),
                  onPressed: _saveTodo,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      minLines: 3,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Completion status
                    SwitchListTile(
                      title: const Text('Completed'),
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      },
                    ),
                    
                    const Divider(),
                    
                    // Due date
                    ListTile(
                      title: const Text('Due Date'),
                      subtitle: _dueDate != null
                          ? Text(DateFormat('EEEE, MMMM d, yyyy').format(_dueDate!))
                          : const Text('No due date'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_dueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearDueDate,
                              tooltip: 'Clear due date',
                            ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _selectDueDate,
                            tooltip: 'Select due date',
                          ),
                        ],
                      ),
                      onTap: _selectDueDate,
                    ),
                    
                    const Divider(),
                    
                    // Priority
                    ListTile(
                      title: const Text('Priority'),
                      subtitle: Row(
                        children: [
                          Icon(
                            PriorityUtils.getPriorityIcon(_priority),
                            color: PriorityUtils.getPriorityColor(_priority),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(PriorityUtils.getPriorityName(_priority)),
                        ],
                      ),
                    ),
                    
                    // Priority selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SegmentedButton<TodoPriority>(
                        segments: [
                          ButtonSegment<TodoPriority>(
                            value: TodoPriority.low,
                            label: Text(
                              PriorityUtils.getPriorityName(TodoPriority.low),
                            ),
                            icon: Icon(
                              PriorityUtils.getPriorityIcon(TodoPriority.low),
                              color: PriorityUtils.getPriorityColor(TodoPriority.low),
                            ),
                          ),
                          ButtonSegment<TodoPriority>(
                            value: TodoPriority.medium,
                            label: Text(
                              PriorityUtils.getPriorityName(TodoPriority.medium),
                            ),
                            icon: Icon(
                              PriorityUtils.getPriorityIcon(TodoPriority.medium),
                              color: PriorityUtils.getPriorityColor(TodoPriority.medium),
                            ),
                          ),
                          ButtonSegment<TodoPriority>(
                            value: TodoPriority.high,
                            label: Text(
                              PriorityUtils.getPriorityName(TodoPriority.high),
                            ),
                            icon: Icon(
                              PriorityUtils.getPriorityIcon(TodoPriority.high),
                              color: PriorityUtils.getPriorityColor(TodoPriority.high),
                            ),
                          ),
                        ],
                        selected: {_priority},
                        onSelectionChanged: (Set<TodoPriority> selected) {
                          setState(() {
                            _priority = selected.first;
                          });
                        },
                      ),
                    ),
                    
                    const Divider(height: 32),
                    
                    // Tags
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tag input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagController,
                              decoration: const InputDecoration(
                                hintText: 'Add a tag',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addTag,
                            tooltip: 'Add tag',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tag list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                          deleteIcon: const Icon(Icons.cancel, size: 16),
                        )).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
