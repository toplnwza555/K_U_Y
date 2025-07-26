import 'package:flutter/material.dart';
import 'dart:io';

class StudentCard extends StatelessWidget {
  final int index;
  final Map<String, String> student;
  final VoidCallback onTap;
  final Widget trailing;
  final File? image;
  final bool isDarkMode;  // เพิ่มตัวแปรสำหรับตรวจสอบโหมดมืด

  const StudentCard({
    super.key,
    required this.index,
    required this.student,
    required this.onTap,
    required this.trailing,
    required this.image,
    required this.isDarkMode,  // รับค่าการตั้งค่าโหมดมืด
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : const Color(0xFFE1F5FE), // สีดำในโหมดมืด และฟ้าอ่อนในโหมดปกติ
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
              backgroundImage: image != null ? FileImage(image!) : null,
              child: image == null
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
            color: isDarkMode ? Colors.white : Colors.black,  // สีตัวอักษรให้ตรงกับโหมด
          ),
        ),
        subtitle: Text(
          'รหัส: ${student['id']}, ห้อง: ${student['room']}',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,  // สีตัวอักษรให้ตรงกับโหมด
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
            child: image == null
                ? const Icon(Icons.photo_camera, color: Colors.white)
                : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(image!, width: 28, height: 28, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
