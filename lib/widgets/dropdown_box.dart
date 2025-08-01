import 'package:flutter/material.dart';

class DropdownMenuBox extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const DropdownMenuBox({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blueGrey.shade50, // พื้นหลังช่อง dropdown
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      style: const TextStyle(color: Colors.black), // ตัวอักษรสีดำ
      dropdownColor: Colors.white, // พื้นหลังของ list ที่ dropdown ลงมา
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
      items: options
          .map((o) => DropdownMenuItem(
        value: o,
        child: Text(o, style: const TextStyle(color: Colors.black)), // ตัวเลือก dropdown สีดำ
      ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
