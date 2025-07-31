import 'package:flutter/material.dart';
import 'dart:typed_data';

class StudentCard extends StatelessWidget {
  final int index;
  final Map<String, String> student;
  final VoidCallback onTap;
  final Widget trailing;
  final Uint8List? imageBytes;
  final bool isDarkMode;

  const StudentCard({
    super.key,
    required this.index,
    required this.student,
    required this.onTap,
    required this.trailing,
    required this.imageBytes,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : const Color(0xFFE1F5FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Stack(
          alignment: Alignment.topLeft,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey[300],
              backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
              child: imageBytes == null
                  ? const Icon(Icons.person, size: 30, color: Colors.grey)
                  : null,
            ),
            Positioned(
              top: -2,
              left: -2,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.lightBlue,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          student['name'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          'รหัส: ${student['id']}, ห้อง: ${student['room']}',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        trailing: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.lightBlueAccent,
            ),
            child: imageBytes == null
                ? const Icon(Icons.photo_camera, color: Colors.white)
                : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(imageBytes!, width: 28, height: 28, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
