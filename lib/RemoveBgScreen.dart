import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RemoveBgScreen extends StatefulWidget {
  const RemoveBgScreen({super.key});

  @override
  State<RemoveBgScreen> createState() => _RemoveBgScreenState();
}

class _RemoveBgScreenState extends State<RemoveBgScreen> {
  final ImagePicker picker = ImagePicker();
  Uint8List? imageBytes;
  bool loading = false;

  Future<void> _pickAndRemoveBg(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    setState(() {
      loading = true;
      imageBytes = null;
    });

    final bytes = await removeBgWithApi(File(picked.path));

    setState(() {
      imageBytes = bytes;
      loading = false;
    });
  }

  Future<Uint8List?> removeBgWithApi(File imageFile) async {
    const apiUrl = 'http://192.168.1.65:8000/crop-bg';


    final request = http.MultipartRequest(
      'POST',
      Uri.parse(apiUrl),
    );
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send();
    print('API Status: ${streamed.statusCode}');
    if (streamed.statusCode == 200) {
      return await streamed.stream.toBytes();
    } else {
      final respStr = await streamed.stream.bytesToString();
      print('API ErrorBody: $respStr');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตัดพื้นหลังเป็นสีฟ้า (API Local)'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (loading)
            const CircularProgressIndicator()
          else if (imageBytes != null)
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220,
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color(0xFF29A8F3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(imageBytes!, width: 220, height: 260, fit: BoxFit.cover),
                ),
              ],
            )
          else
            const Text('ยังไม่ได้เลือกรูป'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _pickAndRemoveBg(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('ถ่ายภาพ'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _pickAndRemoveBg(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('เลือกรูปจากคลัง'),
          ),
        ],
      ),
    );
  }
}
