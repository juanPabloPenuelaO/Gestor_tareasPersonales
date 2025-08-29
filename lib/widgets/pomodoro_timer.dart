import 'package:flutter/material.dart';
import 'dart:async';

class PomodoroTimer extends StatefulWidget {
  final Function(int) onSessionComplete;
  final int workMinutes;
  final int breakMinutes;
  final int longBreakMinutes;

  const PomodoroTimer({
    super.key,
    required this.onSessionComplete,
    this.workMinutes = 25,
    this.breakMinutes = 5,
    this.longBreakMinutes = 15,
  });

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isWorkTime = true;
  int _completedSessions = 0;
  int _totalSessions = 0;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _remainingSeconds = _isWorkTime ? widget.workMinutes * 60 : widget.breakMinutes * 60;
    setState(() {});
  }

  void _startTimer() {
    if (_timer != null) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _onSessionComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _resetTimer();
    });
  }

  void _onSessionComplete() {
    if (_isWorkTime) {
      _completedSessions++;
      _totalSessions++;
      
      // Notificar que se completó una sesión de trabajo
      widget.onSessionComplete(widget.workMinutes);
      
      // Cambiar a tiempo de descanso
      _isWorkTime = false;
      _resetTimer();
      
      // Mostrar notificación
      _showSessionCompleteDialog('¡Sesión de trabajo completada!', 
          'Tómate un descanso de ${widget.breakMinutes} minutos.');
    } else {
      // Cambiar de vuelta a tiempo de trabajo
      _isWorkTime = true;
      _resetTimer();
      
      _showSessionCompleteDialog('¡Descanso completado!', 
          'Comienza tu próxima sesión de trabajo de ${widget.workMinutes} minutos.');
    }
  }

  void _showSessionCompleteDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _isWorkTime ? Icons.work : Icons.coffee,
              color: _isWorkTime ? Colors.blue : Colors.green,
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startTimer(); // Iniciar automáticamente la siguiente sesión
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isWorkTime 
              ? [Colors.blue.shade100, Colors.blue.shade200]
              : [Colors.green.shade100, Colors.green.shade200],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isWorkTime ? Colors.blue.shade300 : Colors.green.shade300,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header del temporizador
          Row(
            children: [
              Icon(
                _isWorkTime ? Icons.work : Icons.coffee,
                color: _isWorkTime ? Colors.blue : Colors.green,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                _isWorkTime ? 'Tiempo de Trabajo' : 'Tiempo de Descanso',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isWorkTime ? Colors.blue.shade800 : Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Timer circular
          Container(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Círculo de progreso
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _getProgressValue(),
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isWorkTime ? Colors.blue : Colors.green,
                    ),
                  ),
                ),
                // Tiempo restante
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _isWorkTime ? Colors.blue.shade800 : Colors.green.shade800,
                      ),
                    ),
                    Text(
                      _isWorkTime ? 'minutos' : 'descanso',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isWorkTime ? Colors.blue.shade600 : Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Controles del temporizador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón de inicio/pausa
              ElevatedButton.icon(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(_isRunning ? 'Pausar' : 'Iniciar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isWorkTime ? Colors.blue : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              
              // Botón de detener
              ElevatedButton.icon(
                onPressed: _stopTimer,
                icon: const Icon(Icons.stop),
                label: const Text('Detener'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Información de sesiones
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$_completedSessions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Sesiones\nCompletadas', textAlign: TextAlign.center),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$_totalSessions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Total\nSesiones', textAlign: TextAlign.center),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getProgressValue() {
    int totalSeconds = _isWorkTime ? widget.workMinutes * 60 : widget.breakMinutes * 60;
    return (totalSeconds - _remainingSeconds) / totalSeconds;
  }
} 