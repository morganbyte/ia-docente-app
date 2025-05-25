import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/ui/widgets/template/default_format.dart';
import 'package:flutter_application_1/ui/widgets/template/quiz_format.dart';
import 'package:flutter_application_1/ui/widgets/template/quiz_summary.dart';
import 'package:flutter_application_1/ui/widgets/template/taller_format.dart';
import '../widgets/template/temario_format.dart';

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
  Map<int, String> selectedAnswers = {};
  int currentQuestionIndex = 0;
  bool isQuizCompleted = false;
  String teacherObservations = '';
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  Map<int, bool> completedActivities = {};
  Map<int, String?> activityNotes = {};

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _userId;
  String?
  _tallerId; 

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
      case 'Temario':
        return 'Temarios';
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
      case 'Temario':
        return _buildTemarioFormat(responseMap);
      default:
        return _buildDefaultFormat(responseMap);
    }
  }

  Widget _buildTallerFormat(Map<String, dynamic> responseMap) {
    final actividades = responseMap['actividadesTaller'] ?? [];

    return TallerFormat(
      actividades: actividades,
      completedActivities: completedActivities,
      activityNotes: activityNotes,
      onSaveProgress: _saveProgress,
      onToggleCompletion: (int index, bool value) {},
      onNoteChanged: (int index, String value) {},
    );
  }

  Widget _buildQuizFormat(Map<String, dynamic> responseMap) {
    return QuizFormat(
      preguntas: responseMap['preguntas'],
      currentIndex: currentQuestionIndex,
      templateType: widget.templateType,
      selectedAnswers: selectedAnswers,
      onPrevious: () {
        setState(() {
          currentQuestionIndex--;
        });
      },
      onNext: () {
        if (selectedAnswers.containsKey(currentQuestionIndex)) {
          setState(() {
            if (currentQuestionIndex < responseMap['preguntas'].length - 1) {
              currentQuestionIndex++;
            } else {
              isQuizCompleted = true;
            }
          });
        }
      },
      onAnswerSelected: (opcion) {
        setState(() {
          selectedAnswers[currentQuestionIndex] = opcion;
          _updateProgress();
        });
      },
    );
  }

  Widget _buildQuizSummary(Map<String, dynamic> responseMap) {
    final preguntas = responseMap['preguntas'] ?? [];
    return QuizSummary(
      templateType: widget.templateType,
      preguntas: List<Map<String, dynamic>>.from(preguntas),
      selectedAnswers: selectedAnswers.map((k, v) => MapEntry(k, v)),
      onRetry: () {
        setState(() {
          isQuizCompleted = false;
          currentQuestionIndex = 0;
          selectedAnswers.clear();
          teacherObservations = '';
          _updateProgress();
        });
      },
    );
  }

  Widget _buildTemarioFormat(Map<String, dynamic> responseMap) {
    return TemarioFormat(temarioData: responseMap);
  }

  Widget _buildDefaultFormat(Map<String, dynamic> responseMap) {
    return DefaultFormat(data: responseMap);
  }
}
