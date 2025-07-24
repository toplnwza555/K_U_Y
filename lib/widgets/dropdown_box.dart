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
        fillColor: Colors.blueGrey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
