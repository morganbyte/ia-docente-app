class ResponseCleaner {
  static String cleanJsonResponse(String text) {
    if (text.startsWith('```json')) {
      text = text.substring(7); 
    } else if (text.startsWith('```')) {
      text = text.substring(3);
    }

    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3); 
    }

    text = text.trim();

    int startIndex = text.indexOf('{');
    int endIndex = text.lastIndexOf('}') + 1;

    if (startIndex != -1 && endIndex > startIndex) {
      text = text.substring(startIndex, endIndex);
    }

    // print("RESPUESTA JSON LIMPIA:"); 
    // print(text); 

    return text;
  }
}