import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'time_management_screen.dart'; // Added import for TimeManagementScreen

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Task> _tasks = [];
  TaskCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks = tasksJson.map((t) => Task.fromJson(t)).toList();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void _addTask(String title, String description, bool isPriority, TaskCategory category, {DateTime? startDate, DateTime? dueDate, int estimatedMinutes = 0}) {
    setState(() {
      _tasks.add(Task(
        title: title,
        description: description,
        isPriority: isPriority,
        category: category,
        startDate: startDate,
        dueDate: dueDate,
        estimatedMinutes: estimatedMinutes,
      ));

      _tasks.sort((a, b) {
        if (a.isPriority && !b.isPriority) return -1;
        if (!a.isPriority && b.isPriority) return 1;
        return 0;
      });
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _updateTaskStatus(int index) {
    setState(() {
      final current = _tasks[index].status;
      _tasks[index].status =
          TaskStatus.values[(current.index + 1) % TaskStatus.values.length];
    });
    _saveTasks();
  }

  String _categoryToString(TaskCategory category) {
    switch (category) {
      case TaskCategory.trabajo:
        return 'Trabajo';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.musica:
        return 'Música';
      case TaskCategory.universidad:
        return 'Universidad';
    }
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.trabajo:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.green;
      case TaskCategory.musica:
        return Colors.purple;
      case TaskCategory.universidad:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.trabajo:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.musica:
        return Icons.music_note;
      case TaskCategory.universidad:
        return Icons.school;
    }
  }

  List<Task> _getFilteredTasks() {
    if (_selectedCategory == null) {
      return _tasks;
    }
    return _tasks.where((task) => task.category == _selectedCategory).toList();
  }

  void _editTask(int index) {
    final task = _tasks[index];
    String editedTitle = task.title;
    String editedDesc = task.description;
    bool isPriority = task.isPriority;
    DateTime? startDate = task.startDate;
    DateTime? dueDate = task.dueDate;
    TaskCategory selectedCategory = task.category;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  const Text('Editar Tarea', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: TextEditingController(text: editedTitle),
                        onChanged: (value) => editedTitle = value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: TextEditingController(text: editedDesc),
                        onChanged: (value) => editedDesc = value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo.shade200),
                      ),
                      child: ListTile(
                        leading: Icon(_getCategoryIcon(selectedCategory), color: _getCategoryColor(selectedCategory)),
                        title: Text('Categoría: ${_categoryToString(selectedCategory)}'),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Seleccionar Categoría'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: TaskCategory.values.map((category) {
                                  return ListTile(
                                    leading: Icon(_getCategoryIcon(category), color: _getCategoryColor(category)),
                                    title: Text(_categoryToString(category)),
                                    onTap: () {
                                      setState(() => selectedCategory = category);
                                      Navigator.pop(context);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: CheckboxListTile(
                        title: const Text("¿Es prioritaria?", style: TextStyle(fontWeight: FontWeight.w500)),
                        value: isPriority,
                        activeColor: Colors.orange,
                        onChanged: (val) {
                          setState(() {
                            isPriority = val ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.green),
                        title: Text(
                          startDate == null
                              ? 'Seleccionar fecha de inicio'
                              : 'Inicio: ${startDate!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => startDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.event, color: Colors.purple),
                        title: Text(
                          dueDate == null
                              ? 'Seleccionar fecha estimada de finalización'
                              : 'Finaliza: ${dueDate!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => dueDate = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.orangeAccent],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (editedTitle.isNotEmpty) {
                        // Actualizar la tarea
                        this.setState(() {
                          _tasks[index].title = editedTitle;
                          _tasks[index].description = editedDesc;
                          _tasks[index].isPriority = isPriority;
                          _tasks[index].startDate = startDate;
                          _tasks[index].dueDate = dueDate;
                          _tasks[index].category = selectedCategory;
                          
                          // Reordenar las tareas (prioritarias primero)
                          _tasks.sort((a, b) {
                            if (a.isPriority && !b.isPriority) return -1;
                            if (!a.isPriority && b.isPriority) return 1;
                            return 0;
                          });
                        });
                        
                        // Guardar las tareas
                        _saveTasks();
                        
                        // Cerrar el diálogo
                        Navigator.of(ctx).pop();
                      } else {
                        // Si no hay título, solo cerrar el diálogo
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog() {
    String newTitle = '';
    String newDesc = '';
    bool isPriority = false;
    DateTime? startDate;
    DateTime? dueDate;
    TaskCategory selectedCategory = TaskCategory.personal;
    int estimatedMinutes = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_task, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  const Text('Nueva Tarea', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                        onChanged: (value) => newTitle = value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                        onChanged: (value) => newDesc = value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo.shade200),
                      ),
                      child: ListTile(
                        leading: Icon(_getCategoryIcon(selectedCategory), color: _getCategoryColor(selectedCategory)),
                        title: Text('Categoría: ${_categoryToString(selectedCategory)}'),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Seleccionar Categoría'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: TaskCategory.values.map((category) {
                                  return ListTile(
                                    leading: Icon(_getCategoryIcon(category), color: _getCategoryColor(category)),
                                    title: Text(_categoryToString(category)),
                                    onTap: () {
                                      setState(() => selectedCategory = category);
                                      Navigator.pop(context);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: CheckboxListTile(
                        title: const Text("¿Es prioritaria?", style: TextStyle(fontWeight: FontWeight.w500)),
                        value: isPriority,
                        activeColor: Colors.orange,
                        onChanged: (val) {
                          setState(() {
                            isPriority = val ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.green),
                        title: Text(
                          startDate == null
                              ? 'Seleccionar fecha de inicio'
                              : 'Inicio: ${startDate!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => startDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.event, color: Colors.purple),
                        title: Text(
                          dueDate == null
                              ? 'Seleccionar fecha estimada de finalización'
                              : 'Finaliza: ${dueDate!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => dueDate = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Agregar', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (newTitle.isNotEmpty) {
                        // Crear la nueva tarea
                        final newTask = Task(
                          title: newTitle,
                          description: newDesc,
                          isPriority: isPriority,
                          category: selectedCategory,
                          startDate: startDate,
                          dueDate: dueDate,
                          estimatedMinutes: estimatedMinutes,
                        );
                        
                        // Cerrar el diálogo primero
                        Navigator.of(ctx).pop();
                        
                        // Luego actualizar el estado principal usando el contexto correcto
                        this.setState(() {
                          _tasks.add(newTask);
                          
                          // Ordenar las tareas (prioritarias primero)
                          _tasks.sort((a, b) {
                            if (a.isPriority && !b.isPriority) return -1;
                            if (!a.isPriority && b.isPriority) return 1;
                            return 0;
                          });
                        });
                        
                        // Guardar las tareas
                        _saveTasks();

                        // Animar al final de la lista después de un breve delay
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            // Esperar un poco para que la UI se actualice
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            });
                          }
                        });
                      } else {
                        // Si no hay título, solo cerrar el diálogo
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pendiente:
        return Colors.orange.shade50;
      case TaskStatus.enProceso:
        return Colors.blue.shade50;
      case TaskStatus.finalizado:
        return Colors.green.shade50;
      case TaskStatus.detenido:
        return Colors.red.shade50;
    }
  }

  Color _getStatusBorderColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pendiente:
        return Colors.orange.shade300;
      case TaskStatus.enProceso:
        return Colors.blue.shade300;
      case TaskStatus.finalizado:
        return Colors.green.shade300;
      case TaskStatus.detenido:
        return Colors.red.shade300;
    }
  }

  String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.pendiente:
        return 'Pendiente';
      case TaskStatus.enProceso:
        return 'En Proceso';
      case TaskStatus.finalizado:
        return 'Finalizado';
      case TaskStatus.detenido:
        return 'Detenido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();
    final activeTasks = filteredTasks.where((t) => t.status != TaskStatus.finalizado).toList();
    final finishedTasks = filteredTasks.where((t) => t.status == TaskStatus.finalizado).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Título de la aplicación
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.task_alt,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Gestión de tareas personales',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Filtro de categorías
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Filtrar por:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Botón "Todas"
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _selectedCategory == null 
                                          ? Colors.white 
                                          : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Todas',
                                      style: TextStyle(
                                        color: _selectedCategory == null 
                                            ? Colors.blue.shade800 
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Botones de categorías
                                ...TaskCategory.values.map((category) {
                                  final isSelected = _selectedCategory == category;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = isSelected ? null : category;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? Colors.white 
                                              : Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getCategoryIcon(category),
                                              color: isSelected 
                                                  ? _getCategoryColor(category)
                                                  : Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _categoryToString(category),
                                              style: TextStyle(
                                                color: isSelected 
                                                    ? _getCategoryColor(category)
                                                    : Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              // Contenido principal
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          if (activeTasks.isNotEmpty) ...[
                            _buildSectionHeader('Tareas Activas', Icons.play_circle, Colors.blue),
                            _buildTaskList(activeTasks),
                          ],
                          if (finishedTasks.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildSectionHeader('Tareas Finalizadas', Icons.check_circle, Colors.green),
                            _buildTaskList(finishedTasks),
                          ],
                          if (filteredTasks.isEmpty) ...[
                            const SizedBox(height: 50),
                            _buildEmptyState(),
                          ],
                          const SizedBox(height: 100), // Espacio para el FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
             floatingActionButton: Row(
         mainAxisAlignment: MainAxisAlignment.end,
         children: [
           // Botón de tiempo
           Container(
             margin: const EdgeInsets.only(right: 16),
             decoration: BoxDecoration(
               gradient: const LinearGradient(
                 colors: [Colors.orange, Colors.orangeAccent],
               ),
               borderRadius: BorderRadius.circular(16),
               boxShadow: [
                 BoxShadow(
                   color: Colors.orange.withOpacity(0.3),
                   blurRadius: 8,
                   offset: const Offset(0, 4),
                 ),
               ],
             ),
             child: FloatingActionButton(
               onPressed: () async {
                 await Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (_) => TimeManagementScreen(tasks: _tasks),
                   ),
                 );
                 setState(() {}); // Refrescar al volver
               },
               backgroundColor: Colors.transparent,
               elevation: 0,
               child: const Icon(Icons.timer, color: Colors.white, size: 24),
             ),
           ),
           // Botón de agregar
           Container(
             decoration: BoxDecoration(
               gradient: const LinearGradient(
                 colors: [Colors.blue, Colors.blueAccent],
               ),
               borderRadius: BorderRadius.circular(16),
               boxShadow: [
                 BoxShadow(
                   color: Colors.blue.withOpacity(0.3),
                   blurRadius: 8,
                   offset: const Offset(0, 4),
                 ),
               ],
             ),
             child: FloatingActionButton(
               onPressed: _showAddTaskDialog,
               backgroundColor: Colors.transparent,
               elevation: 0,
               child: const Icon(Icons.add, color: Colors.white, size: 28),
             ),
           ),
         ],
       ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.task_alt,
            size: 80,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _selectedCategory == null 
              ? 'No hay tareas aún'
              : 'No hay tareas en la categoría "${_categoryToString(_selectedCategory!)}"',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedCategory == null
              ? 'Toca el botón + para agregar tu primera tarea'
              : 'Toca el botón + para agregar una nueva tarea',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Card(
              elevation: 4,
              shadowColor: _getStatusBorderColor(task.status).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _getStatusBorderColor(task.status),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor(task.status),
                      _getStatusColor(task.status).withOpacity(0.5),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (task.isPriority)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade400),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.whatshot, color: Colors.red, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Prioritaria',
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.description,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Chip de categoría
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(task.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getCategoryColor(task.category).withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getCategoryIcon(task.category), color: _getCategoryColor(task.category), size: 14),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _categoryToString(task.category),
                                    style: TextStyle(
                                      color: _getCategoryColor(task.category),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (task.startDate != null)
                            _buildDateChip(
                              'Inicio',
                              task.startDate!,
                              Icons.calendar_today,
                              Colors.green,
                            ),
                          if (task.dueDate != null)
                            _buildDateChip(
                              'Finaliza',
                              task.dueDate!,
                              Icons.event,
                              Colors.purple,
                            ),
                          // NUEVO: Chip de estimación
                          if (task.estimatedMinutes > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.teal.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer, color: Colors.teal, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Estimado: ${task.estimatedMinutes} min',
                                    style: const TextStyle(
                                      color: Colors.teal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // NUEVO: Chip de tiempo real dedicado
                          if (task.actualMinutes > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timelapse, color: Colors.blue, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Real: ${task.actualMinutes} min',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // NUEVO: Chip de eficiencia
                          if (task.status == TaskStatus.finalizado && task.estimatedMinutes > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (task.completedOnTime ? Colors.green.shade50 : Colors.orange.shade50),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: (task.completedOnTime ? Colors.green.shade200 : Colors.orange.shade200)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    task.completedOnTime ? Icons.check_circle : Icons.warning,
                                    color: task.completedOnTime ? Colors.green : Colors.orange,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Eficiencia: ${task.efficiency.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: task.completedOnTime ? Colors.green : Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusBorderColor(task.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _getStatusBorderColor(task.status)),
                            ),
                            child: Text(
                              _statusToString(task.status),
                              style: TextStyle(
                                color: _getStatusBorderColor(task.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Botón de edición
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editTask(_tasks.indexOf(task)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Botón de cambio de estado
                          if (task.status != TaskStatus.finalizado)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: PopupMenuButton<TaskStatus>(
                                onSelected: (newStatus) {
                                  setState(() {
                                    task.status = newStatus;
                                  });
                                  _saveTasks();
                                },
                                itemBuilder: (context) {
                                  final current = task.status;
                                  final options = <TaskStatus>[];

                                  if (current == TaskStatus.pendiente) {
                                    options.add(TaskStatus.enProceso);
                                  } else if (current == TaskStatus.enProceso) {
                                    options.addAll([TaskStatus.finalizado, TaskStatus.detenido]);
                                  } else if (current == TaskStatus.detenido) {
                                    options.add(TaskStatus.enProceso);
                                  }

                                  return options.map((status) {
                                    return PopupMenuItem(
                                      value: status,
                                      child: Text(_statusToString(status)),
                                    );
                                  }).toList();
                                },
                                icon: const Icon(Icons.sync, color: Colors.blue),
                              ),
                            ),
                          const SizedBox(width: 8),
                          // Botón de eliminar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.warning, color: Colors.red),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text('Confirmar'),
                                      ],
                                    ),
                                    content: const Text("¿Deseas eliminar esta tarea?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancelar"),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Colors.red, Colors.redAccent],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _tasks.remove(task);
                                            });
                                            _saveTasks();
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateChip(String label, DateTime date, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$label: ${date.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
