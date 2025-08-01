import 'dart:convert';

enum TaskStatus { pendiente, enProceso, finalizado, detenido }
enum TaskCategory { trabajo, personal, musica, universidad }

class Task {
  String title;
  String description;
  TaskStatus status;
  bool isPriority;
  DateTime? startDate;
  DateTime? dueDate;
  TaskCategory category;

  Task({
    required this.title,
    required this.description,
    this.status = TaskStatus.pendiente,
    this.isPriority = false,
    this.startDate,
    this.dueDate,
    this.category = TaskCategory.personal,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status.index,
      'priority': isPriority,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'category': category.index,
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
      category: map['category'] != null ? TaskCategory.values[map['category']] : TaskCategory.personal,
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}