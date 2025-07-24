
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: const Color(0xFFE0F7FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFB2EBF2),
          child: Text(
            '${index + 1}',
            style: TextStyle(color: textColor),
          ),
        ),
        title: Text(
          student['name'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          'รหัส: ${student['id']}  |  ห้อง: ${student['room']}',
          style: TextStyle(color: textColor),
        ),
        trailing: GestureDetector(
          onTap: onTap,
          child: trailing,
        ),
      ),
    );
  }
}
