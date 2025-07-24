import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final int index;
  final Map<String, String> student;
  final VoidCallback onTap;
  final Widget trailing;

  const StudentCard({
    super.key,
    required this.index,
    required this.student,
    required this.onTap,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: const Color(0xFFE0F7FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFB2EBF2),
          child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
        ),
        title: Text(student['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('รหัส: ${student['id']}  |  ห้อง: ${student['room']}'),
        trailing: GestureDetector(
          onTap: onTap,
          child: trailing,
        ),
      ),
    );
  }
}
