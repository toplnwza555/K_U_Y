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
    });

    final bytes = await removeBackground(File(picked.path));

    setState(() {
      imageBytes = bytes;
      loading = false;
    });
  }

  Future<Uint8List?> removeBackground(File imageFile) async {
    const apiKey = 'hrvgKj5WmN37z5gGLWnkvjj';
    // <-- ใส่ API key ของคุณจาก remove.bg

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    )
      ..headers['X-Api-Key'] = apiKey
      ..files.add(await http.MultipartFile.fromPath('image_file', imageFile.path))
      ..fields['size'] = 'auto';

    final response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      print('Remove.bg error: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตัดพื้นหลังเป็นสีฟ้า'),
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
                    color: const Color(0xFF3399FF), // พื้นหลังฟ้า
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
