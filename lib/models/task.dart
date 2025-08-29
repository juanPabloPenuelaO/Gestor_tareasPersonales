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
  
  // Nuevas propiedades para gestión de tiempo avanzada
  int estimatedMinutes; // Estimación de tiempo en minutos
  int actualMinutes; // Tiempo real dedicado en minutos
  DateTime? actualStartTime; // Hora real de inicio
  DateTime? actualEndTime; // Hora real de finalización
  List<TimeSession> timeSessions; // Sesiones de tiempo dedicadas

  Task({
    required this.title,
    required this.description,
    this.status = TaskStatus.pendiente,
    this.isPriority = false,
    this.startDate,
    this.dueDate,
    this.category = TaskCategory.personal,
    this.estimatedMinutes = 0,
    this.actualMinutes = 0,
    this.actualStartTime,
    this.actualEndTime,
    List<TimeSession>? timeSessions,
  }) : timeSessions = timeSessions ?? [];

  // Método para agregar una sesión de tiempo
  void addTimeSession(TimeSession session) {
    timeSessions.add(session);
    actualMinutes += session.durationMinutes;
  }

  // Método para obtener el tiempo total dedicado
  int get totalTimeSpent => actualMinutes;

  // Método para verificar si se completó en tiempo estimado
  bool get completedOnTime {
    if (status != TaskStatus.finalizado || estimatedMinutes == 0) return false;
    return actualMinutes <= estimatedMinutes;
  }

  // Método para obtener la eficiencia (porcentaje de tiempo estimado vs real)
  double get efficiency {
    if (estimatedMinutes == 0) return 0.0;
    return (estimatedMinutes / actualMinutes) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status.index,
      'priority': isPriority,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'category': category.index,
      'estimatedMinutes': estimatedMinutes,
      'actualMinutes': actualMinutes,
      'actualStartTime': actualStartTime?.toIso8601String(),
      'actualEndTime': actualEndTime?.toIso8601String(),
      'timeSessions': timeSessions.map((session) => session.toMap()).toList(),
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
      estimatedMinutes: map['estimatedMinutes'] ?? 0,
      actualMinutes: map['actualMinutes'] ?? 0,
      actualStartTime: map['actualStartTime'] != null ? DateTime.parse(map['actualStartTime']) : null,
      actualEndTime: map['actualEndTime'] != null ? DateTime.parse(map['actualEndTime']) : null,
      timeSessions: map['timeSessions'] != null 
          ? List<TimeSession>.from(map['timeSessions'].map((x) => TimeSession.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}

// Clase para representar sesiones de tiempo
class TimeSession {
  DateTime startTime;
  DateTime? endTime;
  int durationMinutes;

  TimeSession({
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
  });

  // Método para finalizar la sesión
  void endSession() {
    endTime = DateTime.now();
    durationMinutes = endTime!.difference(startTime).inMinutes;
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
    };
  }

  factory TimeSession.fromMap(Map<String, dynamic> map) {
    return TimeSession(
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      durationMinutes: map['durationMinutes'] ?? 0,
    );
  }
}