import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TemplatePreviewScreen extends StatefulWidget {
  final String jsonResponse;
  final String templateType;

  const TemplatePreviewScreen({
    super.key,
    required this.jsonResponse,
    required this.templateType,
  });

  @override
  State<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends State<TemplatePreviewScreen>
    with TickerProviderStateMixin {
  // Para el quiz interactivo
  Map<int, String> selectedAnswers = {};
  int currentQuestionIndex = 0;
  bool isQuizCompleted = false;
  String teacherObservations = '';
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Estado para taller interactivo
  Map<int, bool> completedActivities = {};
  Map<int, String?> activityNotes = {};

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _userId;
  String?
  _tallerId; // identificador único para el taller (puede ser id o nombre)

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    final Map<String, dynamic> responseMap = jsonDecode(widget.jsonResponse);
    _tallerId =
        responseMap['idTaller']?.toString() ??
        responseMap['nombreTaller']?.toString();

    _loadUserAndProgress();
    _updateProgress();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final Map<String, dynamic> responseMap = jsonDecode(widget.jsonResponse);
    final List preguntas = responseMap['preguntas'] ?? [];
    if (preguntas.isNotEmpty) {
      double progress = selectedAnswers.length / preguntas.length;
      _progressController.animateTo(progress);
    }
  }

  Future<void> _loadUserAndProgress() async {
    final user = _auth.currentUser;
    if (user == null) {
      // Usuario no autenticado, manejar según convenga
      return;
    }
    _userId = user.uid;

    if (_tallerId == null) return;

    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(_userId)
              .collection('talleresProgreso')
              .doc(_tallerId)
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        Map<String, dynamic>? actividadesCompletadasData =
            data['actividadesCompletadas']?.cast<String, dynamic>();
        Map<String, dynamic>? notasData =
            data['notasActividades']?.cast<String, dynamic>();

        setState(() {
          completedActivities =
              actividadesCompletadasData?.map(
                (key, value) => MapEntry(int.parse(key), value as bool),
              ) ??
              {};
          activityNotes =
              notasData?.map(
                (key, value) => MapEntry(int.parse(key), value as String),
              ) ??
              {};
        });
      }
    } catch (e) {
      print('Error al cargar progreso taller: $e');
    }
  }

  Future<void> _saveProgress() async {
    if (_userId.isEmpty || _tallerId == null) return;

    final actividadesCompletadasMap = completedActivities.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final notasMap = activityNotes.map(
      (key, value) => MapEntry(key.toString(), value ?? ''),
    );

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('talleresProgreso')
          .doc(_tallerId)
          .set({
            'actividadesCompletadas': actividadesCompletadasMap,
            'notasActividades': notasMap,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      print('Error al guardar progreso taller: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> responseMap = jsonDecode(widget.jsonResponse);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(),
      body: SafeArea(child: _buildContent(responseMap)),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: Text(
        _getAppBarTitle(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1E293B),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_ios, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      bottom:
          (widget.templateType == 'Quizzes' ||
                  widget.templateType == 'Exámenes')
              ? _buildProgressIndicator()
              : null,
    );
  }

  PreferredSize _buildProgressIndicator() {
    final Map<String, dynamic> responseMap = jsonDecode(widget.jsonResponse);
    final List preguntas = responseMap['preguntas'] ?? [];

    return PreferredSize(
      preferredSize: const Size.fromHeight(24),
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${selectedAnswers.length}/${preguntas.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          widget.templateType == 'Quizzes'
                              ? const Color(0xFF059669)
                              : const Color(0xFF0EA5E9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.grey.shade200,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            colors:
                                widget.templateType == 'Quizzes'
                                    ? [
                                      const Color(0xFF10B981),
                                      const Color(0xFF059669),
                                    ]
                                    : [
                                      const Color(0xFF0EA5E9),
                                      const Color(0xFF0284C7),
                                    ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (widget.templateType) {
      case 'Quizzes':
        return 'Quiz Educativo';
      case 'Talleres':
        return 'Taller';
      case 'Plan de Estudio':
        return 'Plan de Estudios';
      case 'Exámenes':
        return 'Examen';
      default:
        return 'Plantilla';
    }
  }

  Widget _buildContent(Map<String, dynamic> responseMap) {
    if ((widget.templateType == 'Quizzes' ||
            widget.templateType == 'Exámenes') &&
        isQuizCompleted) {
      return _buildQuizSummary(responseMap);
    }

    switch (widget.templateType) {
      case 'Quizzes':
      case 'Exámenes':
        return _buildQuizFormat(responseMap);
      case 'Talleres':
        return _buildTallerFormat(responseMap);
      case 'Plan de Estudio':
        return _buildPlanEstudioFormat(responseMap);
      default:
        return _buildDefaultFormat(responseMap);
    }
  }

  Widget _buildTallerFormat(Map<String, dynamic> responseMap) {
    final List actividades = responseMap['actividadesTaller'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header institucional minimalista
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'INSTPECAM',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'I.E. Técnico Industrial Pedro Castro Monsalvo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Taller Interactivo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Información básica del taller
          _buildModernSectionCard(
            'Nombre del Taller',
            responseMap['nombreTaller'] ?? 'Taller',
            const Color(0xFF8B5CF6),
          ),
          _buildModernSectionCard(
            'Estándar Básico de Competencias (E.B.C)',
            responseMap['descripcionTaller'] ?? '',
            const Color(0xFF3B82F6),
          ),
          _buildModernSectionCard(
            'Derechos Básicos de Aprendizaje (D.B.A)',
            responseMap['objetivoTaller'] ?? '',
            const Color(0xFF06B6D4),
          ),

          const SizedBox(height: 24),

          // Título de actividades interactivas
          const Text(
            'Actividades del Taller',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Lista de actividades interactivas
          ...actividades.asMap().entries.map((entry) {
            final index = entry.key;
            final actividad = entry.value;
            final isCompleted = completedActivities[index] ?? false;
            final hasNotes = activityNotes[index]?.isNotEmpty ?? false;

            String titulo = '';
            String descripcion = '';

            if (actividad is Map<String, dynamic>) {
              titulo = actividad['tituloActividad'] ?? 'Actividad ${index + 1}';
              descripcion = actividad['descripcionActividad'] ?? '';
            } else {
              titulo = 'Actividad ${index + 1}';
              descripcion = actividad.toString();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isCompleted
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFE2E8F0),
                  width: isCompleted ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  // Header de la actividad
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFFAFAFA),
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
                            color:
                                isCompleted
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF8B5CF6),
                          ),
                          child:
                              isCompleted
                                  ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                  : Center(
                                    child: Text(
                                      '${index + 1}',
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
                            child: const Icon(
                              Icons.note_add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Contenido de la actividad
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

                        // Campo para notas del estudiante
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.edit_note,
                                      color: Color(0xFF0284C7),
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Notas y Observaciones',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TextField(
                                  controller: TextEditingController(
                                    text: activityNotes[index] ?? '',
                                  ),
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Escribe tus notas sobre esta actividad...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF8B5CF6),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(12),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      activityNotes[index] = value;
                                    });
                                    _saveProgress();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Botón para marcar como completada
                        Container(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                completedActivities[index] = !isCompleted;
                              });
                              _saveProgress();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isCompleted
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF8B5CF6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                  isCompleted
                                      ? 'Completada'
                                      : 'Marcar como completada',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 24),

          // Sección de progreso
          _buildProgressSection(actividades.length),
        ],
      ),
    );
  }

  Widget _buildModernSectionCard(
    String title,
    String content,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content.isNotEmpty ? content : 'No especificado',
              style: TextStyle(
                fontSize: 14,
                color:
                    content.isNotEmpty
                        ? const Color(0xFF475569)
                        : Colors.grey.shade500,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(int totalActivities) {
    final completedCount =
        completedActivities.values.where((completed) => completed).length;
    final progress =
        totalActivities > 0 ? completedCount / totalActivities : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Progreso del Taller',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completedCount de $totalActivities actividades completadas',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF10B981),
                      ),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      progress == 1.0
                          ? const Color(0xFF10B981)
                          : const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizFormat(Map<String, dynamic> responseMap) {
    final List preguntas = responseMap['preguntas'] ?? [];
    if (preguntas.isEmpty) {
      return const Center(
        child: Text(
          'No hay preguntas disponibles.',
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      );
    }

    final preguntaActual = preguntas[currentQuestionIndex];
    final opciones = preguntaActual['opciones'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header institucional minimalista
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'INSTPECAM',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'I.E. Técnico Industrial Pedro Castro Monsalvo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Coordinación de Prácticas Pedagógicas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Contador de preguntas minimalista
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      widget.templateType == 'Quizzes'
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        widget.templateType == 'Quizzes'
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFDBEAFE),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${currentQuestionIndex + 1} de ${preguntas.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color:
                        widget.templateType == 'Quizzes'
                            ? const Color(0xFF059669)
                            : const Color(0xFF0284C7),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                widget.templateType == 'Quizzes' ? 'Quiz' : 'Examen',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Pregunta con diseño limpio
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Text(
              preguntaActual['pregunta'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                height: 1.6,
                letterSpacing: -0.3,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Opciones con diseño minimalista
          ...opciones.asMap().entries.map((entry) {
            final index = entry.key;
            final opcion = entry.value.toString();
            final estaSeleccionada =
                selectedAnswers[currentQuestionIndex] == opcion;
            final letra = String.fromCharCode(
              65 + int.parse(index.toString()),
            ); // A, B, C, D

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color:
                    estaSeleccionada ? const Color(0xFFFAFAFA) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      estaSeleccionada
                          ? (widget.templateType == 'Quizzes'
                              ? const Color(0xFF059669)
                              : const Color(0xFF0284C7))
                          : const Color(0xFFE2E8F0),
                  width: estaSeleccionada ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      selectedAnswers[currentQuestionIndex] = opcion;
                      _updateProgress();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                estaSeleccionada
                                    ? (widget.templateType == 'Quizzes'
                                        ? const Color(0xFF059669)
                                        : const Color(0xFF0284C7))
                                    : const Color(0xFFF1F5F9),
                            border: Border.all(
                              color:
                                  estaSeleccionada
                                      ? Colors.transparent
                                      : const Color(0xFFCBD5E1),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              letra,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    estaSeleccionada
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            opcion,
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  estaSeleccionada
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF475569),
                              fontWeight:
                                  estaSeleccionada
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 32),

          // Botones de navegación minimalistas
          Row(
            children: [
              if (currentQuestionIndex > 0)
                Expanded(
                  child: Container(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Anterior',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              if (currentQuestionIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        selectedAnswers.containsKey(currentQuestionIndex)
                            ? () {
                              if (currentQuestionIndex < preguntas.length - 1) {
                                setState(() {
                                  currentQuestionIndex++;
                                });
                              } else {
                                setState(() {
                                  isQuizCompleted = true;
                                });
                              }
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.templateType == 'Quizzes'
                              ? const Color(0xFF059669)
                              : const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      currentQuestionIndex < preguntas.length - 1
                          ? 'Siguiente'
                          : 'Finalizar',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSummary(Map<String, dynamic> responseMap) {
    final preguntas = responseMap['preguntas'] ?? [];
    int correctas = 0;
    List<Map<String, dynamic>> resultados = [];

    preguntas.asMap().forEach((index, pregunta) {
      String respuestaUsuario = selectedAnswers[index] ?? '';
      String respuestaCorrecta = pregunta['respuestaCorrecta'] ?? '';
      bool esCorrecta = respuestaUsuario == respuestaCorrecta;

      if (esCorrecta) correctas++;

      resultados.add({
        'pregunta': pregunta['pregunta'] ?? '',
        'respuestaUsuario': respuestaUsuario,
        'respuestaCorrecta': respuestaCorrecta,
        'esCorrecta': esCorrecta,
        'opciones': pregunta['opciones'] ?? [],
      });
    });

    double porcentaje = (correctas / preguntas.length) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Resumen de resultados minimalista
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        porcentaje >= 70
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF3C7),
                  ),
                  child: Icon(
                    porcentaje >= 70 ? Icons.check_circle : Icons.info,
                    size: 40,
                    color:
                        porcentaje >= 70
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${widget.templateType} Completado',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$correctas de ${preguntas.length} correctas',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        porcentaje >= 70
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${porcentaje.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color:
                          porcentaje >= 70
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Título de revisión
          const Text(
            'Revisión de Respuestas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 20),

          // Detalles de cada pregunta
          ...resultados.asMap().entries.map((entry) {
            final index = entry.key;
            final resultado = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      resultado['esCorrecta']
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFECDD3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                resultado['esCorrecta']
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFEF2F2),
                          ),
                          child: Icon(
                            resultado['esCorrecta'] ? Icons.check : Icons.close,
                            color:
                                resultado['esCorrecta']
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFDC2626),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pregunta ${index + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      resultado['pregunta'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (resultado['respuestaUsuario'].isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              resultado['esCorrecta']
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tu respuesta: ${resultado['respuestaUsuario']}',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                resultado['esCorrecta']
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFDC2626),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (!resultado['esCorrecta']) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Respuesta correcta: ${resultado['respuestaCorrecta']}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 32),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isQuizCompleted = false;
                        currentQuestionIndex = 0;
                        selectedAnswers.clear();
                        teacherObservations = '';
                        _updateProgress();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          widget.templateType == 'Quizzes'
                              ? const Color(0xFF059669)
                              : const Color(0xFF0284C7),
                      side: BorderSide(
                        color:
                            widget.templateType == 'Quizzes'
                                ? const Color(0xFF059669)
                                : const Color(0xFF0284C7),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanEstudioFormat(Map<String, dynamic> responseMap) {
    return Container(); // placeholder
  }

  Widget _buildDefaultFormat(Map<String, dynamic> responseMap) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contenido Generado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  jsonEncode(responseMap),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
