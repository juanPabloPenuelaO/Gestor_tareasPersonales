import 'package:flutter/material.dart';
import '../models/task.dart';

class ProductivityAnalysis extends StatelessWidget {
  final List<Task> tasks;

  const ProductivityAnalysis({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task.status == TaskStatus.finalizado).toList();
    final inProgressTasks = tasks.where((task) => task.status == TaskStatus.enProceso).toList();
    final pendingTasks = tasks.where((task) => task.status == TaskStatus.pendiente).toList();

    // Estadísticas semanales
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weeklyCompletedTasks = completedTasks.where((task) {
      return task.actualEndTime != null && 
             task.actualEndTime!.isAfter(weekStart) && 
             task.actualEndTime!.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    // Estadísticas mensuales
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    final monthlyCompletedTasks = completedTasks.where((task) {
      return task.actualEndTime != null && 
             task.actualEndTime!.isAfter(monthStart) && 
             task.actualEndTime!.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    // Calcular eficiencia promedio
    final tasksWithTimeEstimate = completedTasks.where((task) => task.estimatedMinutes > 0).toList();
    final averageEfficiency = tasksWithTimeEstimate.isEmpty 
        ? 0.0 
        : tasksWithTimeEstimate.map((task) => task.efficiency).reduce((a, b) => a + b) / tasksWithTimeEstimate.length;

    // Calcular tiempo total dedicado
    final totalTimeSpent = tasks.fold<int>(0, (sum, task) => sum + task.totalTimeSpent);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.indigo],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                Icon(Icons.analytics, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  'Análisis de Productividad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Resumen general
          _buildSummaryCard(
            'Resumen General',
            [
              _buildStatItem('Tareas Completadas', '${completedTasks.length}', Icons.check_circle, Colors.green),
              _buildStatItem('En Proceso', '${inProgressTasks.length}', Icons.pending, Colors.blue),
              _buildStatItem('Pendientes', '${pendingTasks.length}', Icons.schedule, Colors.orange),
              _buildStatItem('Tiempo Total', '${_formatTime(totalTimeSpent)}', Icons.timer, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),

          // Análisis semanal
          _buildAnalysisCard(
            'Análisis Semanal',
            '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}',
            [
              _buildStatItem('Tareas Completadas', '${weeklyCompletedTasks.length}', Icons.check_circle, Colors.green),
              _buildStatItem('Tiempo Dedicado', '${_formatTime(_calculateTotalTime(weeklyCompletedTasks))}', Icons.timer, Colors.blue),
              _buildStatItem('Eficiencia Promedio', '${averageEfficiency.toStringAsFixed(1)}%', Icons.trending_up, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),

          // Análisis mensual
          _buildAnalysisCard(
            'Análisis Mensual',
            '${monthStart.month}/${monthStart.year}',
            [
              _buildStatItem('Tareas Completadas', '${monthlyCompletedTasks.length}', Icons.check_circle, Colors.green),
              _buildStatItem('Tiempo Dedicado', '${_formatTime(_calculateTotalTime(monthlyCompletedTasks))}', Icons.timer, Colors.blue),
              _buildStatItem('Eficiencia Promedio', '${averageEfficiency.toStringAsFixed(1)}%', Icons.trending_up, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico de eficiencia por categoría
          _buildCategoryEfficiencyCard(completedTasks),
          const SizedBox(height: 16),

          // Lista de tareas más eficientes
          _buildTopTasksCard(completedTasks),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<Widget> stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: stats,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String period, List<Widget> stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: stats,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryEfficiencyCard(List<Task> completedTasks) {
    final categoryStats = <TaskCategory, List<Task>>{};
    
    for (final task in completedTasks) {
      categoryStats.putIfAbsent(task.category, () => []).add(task);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Eficiencia por Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categoryStats.entries.map((entry) {
              final category = entry.key;
              final tasks = entry.value;
              final avgEfficiency = tasks.where((t) => t.estimatedMinutes > 0)
                  .map((t) => t.efficiency)
                  .fold(0.0, (sum, eff) => sum + eff) / tasks.length;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(category), color: _getCategoryColor(category)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_categoryToString(category)),
                    ),
                    Text(
                      '${avgEfficiency.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: avgEfficiency >= 100 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTasksCard(List<Task> completedTasks) {
    final efficientTasks = completedTasks
        .where((task) => task.estimatedMinutes > 0)
        .toList()
      ..sort((a, b) => b.efficiency.compareTo(a.efficiency));

    final topTasks = efficientTasks.take(5).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tareas Más Eficientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...topTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_formatTime(task.estimatedMinutes)} estimado → ${_formatTime(task.actualMinutes)} real',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: task.efficiency >= 100 ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${task.efficiency.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: task.efficiency >= 100 ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  int _calculateTotalTime(List<Task> tasks) {
    return tasks.fold<int>(0, (sum, task) => sum + task.totalTimeSpent);
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
} 