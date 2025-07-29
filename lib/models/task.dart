import 'dart:convert';

enum TaskStatus { pendiente, enProceso, finalizado, detenido }

class Task {
  String title;
  String description;
  TaskStatus status;
  bool isPriority;
  DateTime? startDate;
  DateTime? dueDate;

  Task({
    required this.title,
    required this.description,
    this.status = TaskStatus.pendiente,
    this.isPriority = false,
    this.startDate,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status.index,
      'priority': isPriority,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      description: map['description'],
      status: TaskStatus.values[map['status']],
      isPriority: map['priority'] ?? false,
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}