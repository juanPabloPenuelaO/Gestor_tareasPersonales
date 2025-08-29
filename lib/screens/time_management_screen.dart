import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/pomodoro_timer.dart';
import '../widgets/productivity_analysis.dart';

class TimeManagementScreen extends StatefulWidget {
  final List<Task> tasks;

  const TimeManagementScreen({
    super.key,
    required this.tasks,
  });

  @override
  State<TimeManagementScreen> createState() => _TimeManagementScreenState();
}

class _TimeManagementScreenState extends State<TimeManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPomodoroSessionComplete(int minutes) {
    // Aquí podrías integrar con una tarea específica si es necesario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Sesión Pomodoro completada! ${minutes} minutos de trabajo.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Tiempo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pomodoro y Análisis de Productividad',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.blue.shade800,
                  unselectedLabelColor: Colors.white,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.timer),
                      text: 'Pomodoro',
                    ),
                    Tab(
                      icon: Icon(Icons.analytics),
                      text: 'Análisis',
                    ),
                  ],
                ),
              ),

              // Contenido de los tabs
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab Pomodoro
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'Temporizador Pomodoro',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Técnica de gestión del tiempo que alterna períodos de trabajo enfocado con descansos cortos. (25min de trabajo x 5min de descanso)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            PomodoroTimer(
                              onSessionComplete: _onPomodoroSessionComplete,
                              workMinutes: 25,
                              breakMinutes: 5,
                              longBreakMinutes: 15,
                            ),
                          ],
                        ),
                      ),

                      // Tab Análisis
                      ProductivityAnalysis(tasks: widget.tasks),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 