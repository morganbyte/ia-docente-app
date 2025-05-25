class PromptGenerator {
  static String generatePrompt(Map<String, dynamic> request) {
    switch (request['tipoPlantilla']) {
      case 'Exámenes':
        return '''
Genera un examen sobre el tema "${request['tema']}" de ${request['numeroPreguntas']} preguntas con una duración de ${request['duracion']} y que sea de dificultad ${request['dificultad']}.

IMPORTANTE: Responde SOLAMENTE con un cuerpo JSON válido sin ningún texto antes o después. El JSON debe comenzar con { y terminar con }. NO ENCIERRES EL JSON EN NINGÚN TIPO DE BLOQUE DE CÓDIGO NI COMILLAS TRIPLES.

1. tituloExamen: El título del examen.
2. numeroPreguntas: El número total de preguntas en el examen.
3. preguntas: Una lista de preguntas con las siguientes características:
    - numeroPregunta: Un número que identifica la pregunta.
    - pregunta: El texto de la pregunta.
    - opciones: Las opciones de respuesta (si es de opción múltiple).
    - respuestaCorrecta: La respuesta correcta.
4. duracion: Duración del examen en minutos.
5. dificultad: Dificultad del examen (fácil, media, difícil).

''';

      case 'Talleres':
        return '''
Genera una plantilla para un taller sobre ${request['tema']} con una duración de ${request['duracion']} y con ${request['numeroActividades']} actividades sencillas relacionadas al tema.

IMPORTANTE: Responde SOLAMENTE con un cuerpo JSON válido sin ningún texto antes o después. El JSON debe comenzar con { y terminar con }. NO ENCIERRES EL JSON EN NINGÚN TIPO DE BLOQUE DE CÓDIGO NI COMILLAS TRIPLES.

El JSON debe tener los siguientes campos:
1. nombreTaller: El nombre del taller.
2. descripcionTaller: Una breve descripción del taller.
3. equipoNecesario: Lista de materiales necesarios, incluyendo una descripción de cada uno.
4. objetivoTaller: El objetivo del taller.
5. actividadesTaller: Una lista con la cantidad de actividades dada con los siguientes campos:
    - numeroActividad: Un número que identifica la actividad.
    - tituloActividad: El título de la actividad.
    - descripcionActividad: Descripción de la actividad.
''';

      case 'Temario':
        return '''
Eres un experto en pedagogía y diseño curricular. Necesito que generes un **temario estructurado en formato JSON** para el siguiente tema: "${request['tema']}".
Este temario está diseñado para ser visualizado como una planificación académica escolar dividida en 4 períodos académicos.

El JSON debe tener la siguiente estructura:
{
  "titulo": "Título del temario",
  "descripcion_general": "Descripción general del curso completo",
  "periodos": [
    {
      "nombre": "Primer Período",
      "descripcion": "Descripción específica de este período",
      "duracion": "10-12 semanas",
      "temas_principales": [
        "Tema 1 del primer período",
        "Tema 2 del primer período",
        "Tema 3 del primer período"
      ],
      "actividades_practicas": [
        {
          "titulo": "Nombre de la actividad",
          "descripcion": "Breve descripción de la actividad práctica"
        }
      ],
      "cronograma": [
        {
          "semana": "Semana 1",
          "contenido": "Contenido específico a desarrollar esta semana",
          "descripcion": "Descripción detallada de las actividades semanales"
        }
      ]
    },
    {
      "nombre": "Segundo Período",
      "descripcion": "Descripción específica de este período",
      "duracion": "10-12 semanas",
      "temas_principales": [
        "Tema 1 del segundo período",
        "Tema 2 del segundo período"
      ],
      "actividades_practicas": [
        {
          "titulo": "Actividad del segundo período",
          "descripcion": "Descripción de la actividad"
        }
      ],
      "cronograma": [
        {
          "semana": "Semana 1",
          "contenido": "Contenido del segundo período",
          "descripcion": "Actividades semanales"
        }
      ]
    },
    {
      "nombre": "Tercer Período",
      "descripcion": "Descripción específica de este período",
      "duracion": "10-12 semanas",
      "temas_principales": [
        "Tema 1 del tercer período",
        "Tema 2 del tercer período"
      ],
      "actividades_practicas": [
        {
          "titulo": "Actividad del tercer período",
          "descripcion": "Descripción de la actividad"
        }
      ],
      "cronograma": [
        {
          "semana": "Semana 1",
          "contenido": "Contenido del tercer período",
          "descripcion": "Actividades semanales"
        }
      ]
    },
    {
      "nombre": "Cuarto Período",
      "descripcion": "Descripción específica de este período",
      "duracion": "10-12 semanas",
      "temas_principales": [
        "Tema 1 del cuarto período",
        "Tema 2 del cuarto período"
      ],
      "actividades_practicas": [
        {
          "titulo": "Actividad del cuarto período",
          "descripcion": "Descripción de la actividad"
        }
      ],
      "cronograma": [
        {
          "semana": "Semana 1",
          "contenido": "Contenido del cuarto período",
          "descripcion": "Actividades semanales"
        }
      ]
    }
  ]
}

**Instrucciones importantes:**
1. Cada período debe tener entre 3-6 temas principales apropiados para ese nivel de complejidad
2. Las actividades prácticas deben ser progresivas y acordes al período
3. El cronograma debe ser realista (8-12 semanas por período)
4. Los temas deben seguir una secuencia lógica de aprendizaje
5. Incluye variedad en las actividades: experimentos, proyectos, investigaciones, etc.
6. Los períodos deben complementarse entre sí para formar un curso completo

No incluyas explicaciones ni texto adicional fuera del JSON.
''';

      case 'Quizzes':
        return '''
Genera un quiz sobre el tema "${request['tema']}", de ${request['numeroPreguntas']} preguntas relacionadas. Debe tener una duración de ${request['duracion']}.

IMPORTANTE: Responde SOLAMENTE con un cuerpo JSON válido sin ningún texto antes o después. El JSON debe comenzar con { y terminar con }. NO ENCIERRES EL JSON EN NINGÚN TIPO DE BLOQUE DE CÓDIGO NI COMILLAS TRIPLES.

El JSON debe incluir los siguientes campos:
1. tituloQuiz: El nombre del quiz.
2. numeroPreguntas: El número de preguntas.
3. preguntas: Una lista con la cantidad de preguntas dada con los siguientes campos:
    - numeroPregunta: Un número que identifica la pregunta.
    - pregunta: El texto de la pregunta.
    - opciones: Las opciones de respuesta.
    - respuestaCorrecta: La respuesta correcta.
4. duracion: Duración del quiz en minutos.
''';

      default:
        return '';
    }
  }
}
