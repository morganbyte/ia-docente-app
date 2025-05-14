const Map<String, String> templatePrompts = {
  'examen': '''
Genera un examen de baloncesto. La plantilla debe incluir los siguientes campos:

1. tituloExamen: El título del examen.
2. numeroPreguntas: El número total de preguntas en el examen.
3. preguntas: Una lista de preguntas con las siguientes características:
   - numeroPregunta: Un número que identifica la pregunta.
   - pregunta: El texto de la pregunta.
   - opciones: Las opciones de respuesta (si es de opción múltiple).
   - respuestaCorrecta: La respuesta correcta.
''',

  'taller': '''
Genera una plantilla educativa para un taller de baloncesto. La plantilla debe tener los siguientes campos:

1. nombreTaller: El nombre del taller.
2. tipoTaller: El tipo de taller (por ejemplo, práctico, teórico).
3. descripcionTaller: Una breve descripción del taller.
4. equipoNecesario: Lista de materiales necesarios, incluyendo una descripción de cada uno.
5. objetivoTaller: El objetivo del taller.
6. actividadesTaller: Una lista de actividades con los siguientes campos:
   - numeroActividad: Un número que identifica la actividad.
   - tituloActividad: El título de la actividad.
   - descripcionActividad: Descripción de la actividad.
   - duracionActividad: Duración de la actividad en minutos.
''',

  'planEstudio': '''
Genera un plan de estudio para un curso de baloncesto. Los campos deben ser:

1. tituloCurso: El nombre del curso.
2. numeroLecciones: El número total de lecciones.
3. lecciones: Una lista de lecciones con los siguientes campos:
   - numeroLeccion: Un número que identifica la lección.
   - tituloLeccion: El título de la lección.
   - objetivoLeccion: El objetivo de la lección.
   - duracionLeccion: La duración de la lección en minutos.
''',

  'quiz': '''
Genera un quiz de baloncesto. La plantilla debe incluir los siguientes campos:

1. tituloQuiz: El nombre del quiz.
2. numeroPreguntas: El número de preguntas.
3. preguntas: Una lista de preguntas con los siguientes campos:
   - numeroPregunta: Un número que identifica la pregunta.
   - pregunta: El texto de la pregunta.
   - opciones: Las opciones de respuesta.
   - respuestaCorrecta: La respuesta correcta.
''',
};
