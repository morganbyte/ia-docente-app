import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_theme.dart'; 
import 'package:flutter_application_1/config/app_colors.dart'; 

class TemarioFormat extends StatefulWidget {
  final Map<String, dynamic> temarioData;

  const TemarioFormat({super.key, required this.temarioData});

  @override
  State<TemarioFormat> createState() => _TemarioFormat();
}

class _TemarioFormat extends State<TemarioFormat> {
  int _periodoActivo = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.temarioData.isEmpty ||
        widget.temarioData['periodos'] == null ||
        (widget.temarioData['periodos'] as List).isEmpty) {
      return const Center(child: Text("No hay datos de temario para mostrar."));
    }

    final String titulo = widget.temarioData['titulo'] ?? "Temario";
    final String descripcionGeneral =
        widget.temarioData['descripcion_general'] ?? "";
    final List<dynamic> periodos = widget.temarioData['periodos'];
    final Map<String, dynamic> periodoSeleccionado = periodos[_periodoActivo];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.background.withOpacity(0.95),
            AppColors.background.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(titulo, descripcionGeneral),
      const SizedBox(height: 24),
      _buildPeriodoButtons(periodos),
      const SizedBox(height: 28),
      _buildPeriodoSeleccionadoContent(periodoSeleccionado),
    ],
  ),
),

    );
  }

Widget _buildHeader(String titulo, String descripcionGeneral) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.book_outlined, color: AppColors.primary, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titulo,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        descripcionGeneral,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textDark.withOpacity(0.8),
              height: 1.4,
            ),
      ),
    ],
  );
}


  Widget _buildPeriodoButtons(List<dynamic> periodos) {
  return Wrap(
    alignment: WrapAlignment.start,
    spacing: 12.0,
    runSpacing: 12.0,
    children: List.generate(periodos.length, (index) {
      final bool isActive = _periodoActivo == index;
      return GestureDetector(
        onTap: () {
          setState(() {
            _periodoActivo = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primary),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                : [],
          ),
          child: Text(
            periodos[index]['nombre'] ?? 'Período ${index + 1}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isActive ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
    }),
  );
}


  Widget _buildPeriodoSeleccionadoContent(Map<String, dynamic> periodo) {
    final String nombrePeriodo = periodo['nombre'] ?? "Período";
    final String duracion = periodo['duracion'] ?? "N/A";
    final String descripcionPeriodo = periodo['descripcion'] ?? "";
    final List<dynamic> temasPrincipales = periodo['temas_principales'] ?? [];
    final List<dynamic> actividadesPracticas = periodo['actividades_practicas'] ?? [];
    final List<dynamic> cronograma = periodo['cronograma'] ?? [];

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nombrePeriodo,
                  style: ThemeData().textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_outlined, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      duracion,
                      style: ThemeData().textTheme.labelMedium?.copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            descripcionPeriodo,
            style: ThemeData().textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTemasPrincipales(temasPrincipales)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildActividadesPracticas(actividadesPracticas)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildTemasPrincipales(temasPrincipales),
                    const SizedBox(height: 24),
                    _buildActividadesPracticas(actividadesPracticas),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildCronograma(cronograma),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: ThemeData().textTheme.titleMedium,
      ),
    );
  }

  Widget _buildTemasPrincipales(List<dynamic> temas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Temas Principales"),
        if (temas.isEmpty)
          Text("No hay temas principales disponibles.", style: ThemeData().textTheme.bodySmall),
        ...temas.map((tema) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tema.toString(),
                    style: ThemeData().textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActividadesPracticas(List<dynamic> actividades) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Actividades Prácticas"),
        if (actividades.isEmpty)
          Text("No hay actividades prácticas disponibles.", style: ThemeData().textTheme.bodySmall),
        ...actividades.map((actividad) {
          final String tituloActividad = actividad['titulo'] ?? "Actividad";
          final String descActividad = actividad['descripcion'] ?? "";
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: AppColors.accent4.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.0),
              border: Border(left: BorderSide(color: AppColors.accent4, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tituloActividad,
                  style: ThemeData().textTheme.bodyLarge?.copyWith(color: AppColors.accent4),
                ),
                const SizedBox(height: 6),
                Text(
                  descActividad,
                  style: ThemeData().textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCronograma(List<dynamic> cronograma) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Cronograma Detallado"),
        if (cronograma.isEmpty)
          Text("No hay cronograma disponible.", style: ThemeData().textTheme.bodySmall),
        ...cronograma.map((item) {
          final String semana = item['semana'] ?? "Semana";
          final String contenido = item['contenido'] ?? "";
          final String descCronograma = item['descripcion'] ?? "";

          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.0),
              border: Border(left: BorderSide(color: AppColors.secondary, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    semana,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Text(
                  contenido,
                  style: ThemeData().textTheme.bodyLarge?.copyWith(color: AppColors.secondary),
                ),
                const SizedBox(height: 6),
                Text(
                  descCronograma,
                  style: ThemeData().textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
