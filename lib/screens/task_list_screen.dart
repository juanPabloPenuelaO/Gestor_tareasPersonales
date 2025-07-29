import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Task> _tasks = [];

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

  void _addTask(String title, String description, bool isPriority) {
    setState(() {
      _tasks.add(Task(
        title: title,
        description: description,
        isPriority: isPriority,
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

  void _showAddTaskDialog() {
    String newTitle = '';
    String newDesc = '';
    bool isPriority = false;
    DateTime? startDate;
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nueva Tarea'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Título'),
                      onChanged: (value) => newTitle = value,
                    ),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                      onChanged: (value) => newDesc = value,
                    ),
                    CheckboxListTile(
                      title: const Text("¿Es prioritaria?"),
                      value: isPriority,
                      onChanged: (val) {
                        setState(() {
                          isPriority = val ?? false;
                        });
                      },
                    ),
                    ListTile(
                      title: Text(startDate == null
                          ? 'Seleccionar fecha de inicio'
                          : 'Inicio: ${startDate!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
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
                    ListTile(
                      title: Text(dueDate == null
                          ? 'Seleccionar fecha estimada de finalización'
                          : 'Finaliza: ${dueDate!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                ElevatedButton(
                  child: const Text('Agregar'),
                  onPressed: () {
                    if (newTitle.isNotEmpty) {
                      setState(() {
                        _tasks.add(Task(
                          title: newTitle,
                          description: newDesc,
                          isPriority: isPriority,
                          startDate: startDate,
                          dueDate: dueDate,
                        ));
                      });
                      _saveTasks();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });
                    }
                    Navigator.of(ctx).pop();
                  },
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
        return Colors.orange.shade300;
      case TaskStatus.enProceso:
        return Colors.blue.shade300;
      case TaskStatus.finalizado:
        return Colors.green.shade400;
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
    final activeTasks =
        _tasks.where((t) => t.status != TaskStatus.finalizado).toList();
    final finishedTasks =
        _tasks.where((t) => t.status == TaskStatus.finalizado).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas personales')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Tareas Activas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildTaskList(activeTasks),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Tareas Finalizadas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildTaskList(finishedTasks),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          color: _getStatusColor(task.status),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Row(
              children: [
                Expanded(child: Text(task.title)),
                if (task.isPriority)
                  const Icon(Icons.whatshot, color: Colors.red, size: 20),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                if (task.startDate != null)
                  Text(
                      'Inicio: ${task.startDate!.toLocal().toString().split(' ')[0]}'),
                if (task.dueDate != null)
                  Text(
                      'Finaliza: ${task.dueDate!.toLocal().toString().split(' ')[0]}'),
                Text('Estado: ${_statusToString(task.status)}'),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.status != TaskStatus.finalizado)
                  PopupMenuButton<TaskStatus>(
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
                        options.addAll(
                            [TaskStatus.finalizado, TaskStatus.detenido]);
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
                    icon: const Icon(Icons.sync),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Confirmar"),
                        content: const Text("¿Deseas eliminar esta tarea?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancelar"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _tasks.remove(task);
                              });
                              _saveTasks();
                              Navigator.pop(context);
                            },
                            child: const Text("Eliminar"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
