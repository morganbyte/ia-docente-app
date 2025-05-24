import 'package:flutter/material.dart';
// Para iconos similares a Lucide, podrías considerar el paquete `lucide_icons`
// import 'package:lucide_icons/lucide_icons.dart';

class TemarioFlutterWidget extends StatefulWidget {
  final Map<String, dynamic> temarioData;

  const TemarioFlutterWidget({super.key, required this.temarioData});

  @override
  State<TemarioFlutterWidget> createState() => _TemarioFlutterWidgetState();
}

class _TemarioFlutterWidgetState extends State<TemarioFlutterWidget> {
  int _periodoActivo = 0;

  // Colores inspirados en tu ejemplo de React (puedes personalizarlos)
  static const Color primaryColor = Color(0xFF3B82F6); // Azul principal
  static const Color lightBlueBg = Color(0xFFEFF6FF); // Fondo azul claro para items
  static const Color lightGreenBg = Color(0xFFF0FDF4); // Fondo verde claro
  static const Color greenAccent = Color(0xFF10B981); // Acento verde
  static const Color lightPurpleBg = Color(0xFFFAF5FF); // Fondo morado claro
  static const Color purpleAccent = Color(0xFF8B5CF6); // Acento morado

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
            Colors.blue.shade50,
            Colors.indigo.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(titulo, descripcionGeneral),
            const SizedBox(height: 24),

            // Botones de Períodos
            _buildPeriodoButtons(periodos),
            const SizedBox(height: 24),

            // Contenido del Período Seleccionado
            _buildPeriodoSeleccionadoContent(periodoSeleccionado),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String titulo, String descripcionGeneral) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, color: primaryColor, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          descripcionGeneral,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodoButtons(List<dynamic> periodos) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12.0,
      runSpacing: 12.0,
      children: List.generate(periodos.length, (index) {
        final bool isActive = _periodoActivo == index;
        return ElevatedButton(
          onPressed: () {
            setState(() {
              _periodoActivo = index;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? primaryColor : Colors.white,
            foregroundColor: isActive ? Colors.white : Colors.grey.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            elevation: isActive ? 6.0 : 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return isActive ? Colors.white.withOpacity(0.1) : primaryColor.withOpacity(0.1);
                }
                return null; // Defer to the widget's default.
              },
            ),
          ),
          child: Text(periodos[index]['nombre'] ?? 'Período ${index + 1}'),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y descripción del período
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_outlined, color: primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nombrePeriodo,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: lightBlueBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_outlined, size: 16, color: Colors.blue.shade800),
                    const SizedBox(width: 4),
                    Text(
                      duracion,
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            descripcionPeriodo,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Layout para Temas y Actividades (adaptable)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) { // Umbral para cambiar a dos columnas
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

          // Cronograma
          _buildCronograma(cronograma),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
        ),
      ),
      // Para replicar el borde inferior, se puede usar un Container o Divider,
      // pero por simplicidad lo dejo así. Un Divider es más sencillo:
      // child: Column(
      //  crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Text(...),
      //     Divider(color: borderColor, thickness: 2, endIndent: MediaQuery.of(context).size.width * 0.7,)
      //   ],
      // )
    );
  }


  Widget _buildTemasPrincipales(List<dynamic> temas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Temas Principales", primaryColor),
        if (temas.isEmpty)
          const Text("No hay temas principales disponibles.", style: TextStyle(color: Colors.grey)),
        ...temas.map((tema) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: lightBlueBg,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, color: primaryColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tema.toString(),
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
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
        _buildSectionTitle("Actividades Prácticas", greenAccent),
         if (actividades.isEmpty)
          const Text("No hay actividades prácticas disponibles.", style: TextStyle(color: Colors.grey)),
        ...actividades.map((actividad) {
          final String tituloActividad = actividad['titulo'] ?? "Actividad";
          final String descActividad = actividad['descripcion'] ?? "";
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: lightGreenBg,
              borderRadius: BorderRadius.circular(8.0),
              border: Border(left: BorderSide(color: greenAccent, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tituloActividad,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade800),
                ),
                const SizedBox(height: 6),
                Text(
                  descActividad,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
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
        _buildSectionTitle("Cronograma Detallado", purpleAccent),
        if (cronograma.isEmpty)
          const Text("No hay cronograma disponible.", style: TextStyle(color: Colors.grey)),
        ...cronograma.map((item) {
          final String semana = item['semana'] ?? "Semana";
          final String contenido = item['contenido'] ?? "";
          final String descCronograma = item['descripcion'] ?? "";

          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: lightPurpleBg,
              borderRadius: BorderRadius.circular(8.0),
              border: Border(left: BorderSide(color: purpleAccent, width: 4)),
            ),
            child: Column( // Cambiado a Column para mejor disposición en móvil
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: purpleAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    semana,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Text(
                  contenido,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.purple.shade800),
                ),
                const SizedBox(height: 6),
                Text(
                  descCronograma,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}