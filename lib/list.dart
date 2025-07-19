import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart' as excel;

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String level = 'ระดับชั้น';
  String year = 'ชั้นปี';
  String room = 'ห้อง';
  String query = '';
  List<Map<String, String>> students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStudentsFromExcel();
  }

  Future<void> loadStudentsFromExcel() async {
    final data = await rootBundle.load('assets/students_by_class_fixed.xlsx');
    final bytes = data.buffer.asUint8List();
    final excelFile = excel.Excel.decodeBytes(bytes);
    final sheet = excelFile.tables[excelFile.tables.keys.first]!;

    List<Map<String, String>> loaded = [];
    for (var row in sheet.rows.skip(1)) {
      final id = row[0]?.value.toString() ?? '';
      final name = row[1]?.value.toString() ?? '';
      final room = row[2]?.value.toString() ?? '';
      if (id.isNotEmpty && name.isNotEmpty && room.isNotEmpty) {
        loaded.add({'id': id, 'name': name, 'room': room});
      }
    }
    setState(() {
      students = loaded;
      loading = false;
    });
  }

  // ------- Helper for dropdowns -------
  String extractLevel(String room) {
    if (room.contains('อนุบาล')) return 'อนุบาล';
    if (room.contains('ประถม')) return 'ประถม';
    if (room.contains('มัธยม')) return 'มัธยม';
    return 'อื่นๆ';
  }
  String extractYear(String room) {
    final reg = RegExp(r'(อนุบาล|ประถม|มัธยม)\s?(\d+)');
    final m = reg.firstMatch(room);
    if (m != null) {
      switch (m.group(1)) {
        case 'อนุบาล': return 'อนุบาล${m.group(2)}';
        case 'ประถม': return 'ป.${m.group(2)}';
        case 'มัธยม': return 'ม.${m.group(2)}';
      }
    }
    return 'อื่นๆ';
  }
  String extractRoom(String room) {
    final reg = RegExp(r'(\d+/\d+)');
    final m = reg.firstMatch(room);
    return m?.group(1) ?? room;
  }
  // ------- End Helper -------

  @override
  Widget build(BuildContext context) {
    // ตัวเลือก dropdown
    final levelOptions = ['ระดับชั้น', ...{...students.map((s) => extractLevel(s['room']!))}..remove('อื่นๆ')];
    final yearOptions = ['ชั้นปี', ...{
      ...students.where((s) => level == 'ระดับชั้น' || extractLevel(s['room']!) == level).map((s) => extractYear(s['room']!))
    }..remove('อื่นๆ')];
    final roomOptions = ['ห้อง', ...{
      ...students.where((s) =>
      (level == 'ระดับชั้น' || extractLevel(s['room']!) == level) &&
          (year == 'ชั้นปี' || extractYear(s['room']!) == year)
      ).map((s) => extractRoom(s['room']!))
    }];

    // กรองนักเรียน
    final filtered = students.where((s) {
      bool matchLevel = (level == 'ระดับชั้น') || (extractLevel(s['room']!) == level);
      bool matchYear = (year == 'ชั้นปี') || (extractYear(s['room']!) == year);
      bool matchRoom = (room == 'ห้อง') || (extractRoom(s['room']!) == room);
      final q = query.trim().toLowerCase();
      bool matchQuery = s['name']!.toLowerCase().contains(q) || s['id']!.contains(q) || s['room']!.toLowerCase().contains(q);
      return matchLevel && matchYear && matchRoom && matchQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF263238),
        title: const Text('รายการนักเรียน', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    // dropdown ระดับชั้น
                    Expanded(child: _DropdownMenuBox(
                        value: level, options: levelOptions,
                        onChanged: (v) {
                          setState(() {
                            level = v;
                            year = 'ชั้นปี';
                            room = 'ห้อง';
                          });
                        })),
                    const SizedBox(width: 8),
                    // dropdown ชั้นปี
                    Expanded(child: _DropdownMenuBox(
                        value: year, options: yearOptions,
                        onChanged: (v) {
                          setState(() {
                            year = v;
                            room = 'ห้อง';
                          });
                        })),
                    const SizedBox(width: 8),
                    // dropdown ห้อง
                    Expanded(child: _DropdownMenuBox(
                        value: room, options: roomOptions,
                        onChanged: (v) {
                          setState(() => room = v);
                        })),
                  ],
                ),
                const SizedBox(height: 8),
                // search box
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ค้นหา...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  onChanged: (v) => setState(() => query = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final s = filtered[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: const Color(0xFFE0F7FA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFB2EBF2),
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
                    ),
                    title: Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('รหัส: ${s['id']}  |  ห้อง: ${s['room']}'),
                    // ไม่มี trailing กล้อง!
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Center(
              child: SizedBox(
                width: 330,
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF29A8F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    // คุณจะใส่ฟังก์ชัน download ตรงนี้ทีหลังได้
                  },
                  icon: Icon(Icons.arrow_downward, color: Colors.white, size: 28),
                  label: Text(
                    'DOWNLOAD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- dropdown box สวย ๆ ---
class _DropdownMenuBox extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _DropdownMenuBox({required this.value, required this.options, required this.onChanged});
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
      icon: Icon(Icons.arrow_drop_down, color: Colors.black87),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}
