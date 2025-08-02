import 'dart:io';
import 'package:http/http.dart' as http;

class BgApiService {
  // เปลี่ยนเป็น IP ของเครื่องที่รัน FastAPI จริง!
  static const String apiUrl = 'http://192.168.1.89:8000/crop-bg';

  static Future<http.Response?> uploadAndProcess(File imageFile) async {
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final streamed = await request.send();
    if (streamed.statusCode == 200) {
      final resp = await http.Response.fromStream(streamed);
      return resp;
    } else {
      return null;
    }
  }
}
