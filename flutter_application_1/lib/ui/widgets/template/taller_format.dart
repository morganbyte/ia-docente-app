import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/widgets/template/progress_section.dart';

class TallerFormat extends StatefulWidget {
  final List actividades;
  final Map<int, bool> completedActivities;
  final Map<int, String?> activityNotes;
  final VoidCallback onSaveProgress;
  final void Function(int index, bool value) onToggleCompletion;
  final void Function(int index, String value) onNoteChanged;

  const TallerFormat({
    super.key,
    required this.actividades,
    required this.completedActivities,
    required this.activityNotes,
    required this.onSaveProgress,
    required this.onToggleCompletion,
    required this.onNoteChanged,
  });

  @override
  State<TallerFormat> createState() => _TallerFormatState();
}

class _TallerFormatState extends State<TallerFormat> {
  late Map<int, bool> completedActivities;
  late Map<int, String?> activityNotes;

  @override
  void initState() {
    super.initState();
    completedActivities = Map.from(widget.completedActivities);
    activityNotes = Map.from(widget.activityNotes);
  }

  @override
  Widget build(BuildContext context) {
    final actividades = widget.actividades;
    final totalActivities = actividades.length;
    final completedCount = completedActivities.values.where((c) => c).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividades del Taller',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...actividades.asMap().entries.map((entry) {
            final index = entry.key;
            final actividad = entry.value;
            final isCompleted = completedActivities[index] ?? false;
            final hasNotes = activityNotes[index]?.isNotEmpty ?? false;
            final titulo = actividad['tituloActividad'] ?? 'Actividad \${index + 1}';
            final descripcion = actividad['descripcionActividad'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted ? const Color(0xFFD1FAE5) : const Color(0xFFE2E8F0),
                  width: isCompleted ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFFF0FDF4) : const Color(0xFFFAFAFA),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : Center(
                                  child: Text(
                                    '\${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titulo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              if (isCompleted)
                                const Text(
                                  'Completada',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (hasNotes)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0EA5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.note_add, color: Colors.white, size: 16),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          descripcion,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: TextEditingController(text: activityNotes[index] ?? ''),
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Escribe tus notas sobre esta actividad...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              activityNotes[index] = value;
                            });
                            widget.onNoteChanged(index, value);
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              completedActivities[index] = !isCompleted;
                            });
                            widget.onToggleCompletion(index, completedActivities[index]!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isCompleted ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCompleted ? 'Completada' : 'Marcar como completada',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          ProgressSection(
            totalActivities: totalActivities,
            completedCount: completedCount,
          ),
        ],
      ),
    );
  }
}