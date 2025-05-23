import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String?> uploadFileToTransferSh(File file) async {
  final fileName = file.path.split('/').last;
  final url = Uri.parse('https://transfer.sh/$fileName');

  final request = http.MultipartRequest('PUT', url);
  request.files.add(await http.MultipartFile.fromPath('file', file.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    return responseBody.trim(); // enlace público
  } else {
    print('Error subiendo archivo: ${response.statusCode}');
    return null;
  }
}

Future<File> savePdfTempFile(Uint8List bytes, String fileName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file;
}
