// list.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:excel/excel.dart' as excel;
import 'login.dart';
import 'widgets/dropdown_box.dart';
import 'widgets/student_card.dart';

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
        case 'อนุบาล':
          return 'อนุบาล${m.group(2)}';
        case 'ประถม':
          return 'ป.${m.group(2)}';
        case 'มัธยม':
          return 'ม.${m.group(2)}';
      }
    }
    return 'อื่นๆ';
  }

  String extractRoom(String room) {
    final reg = RegExp(r'(\d+/\d+)');
    final m = reg.firstMatch(room);
    return m?.group(1) ?? room;
  }

  @override
  Widget build(BuildContext context) {
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

    final filtered = students.where((s) {
      bool matchLevel = (level == 'ระดับชั้น') || (extractLevel(s['room']!) == level);
      bool matchYear = (year == 'ชั้นปี') || (extractYear(s['room']!) == year);
      bool matchRoom = (room == 'ห้อง') || (extractRoom(s['room']!) == room);
      final q = query.trim().toLowerCase();
      bool matchQuery = s['name']!.toLowerCase().contains(q) || s['id']!.contains(q) || s['room']!.toLowerCase().contains(q);
      return matchLevel && matchYear && matchRoom && matchQuery;
    }).toList();

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF29A8F3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/mylogo.png'), // ใช้โลโก้ของคุณ
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'เมนูหลัก',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF29A8F3)),
              title: const Text('หน้าหลัก'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF29A8F3)),
              title: const Text('ตั้งค่า'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Color(0xFF29A8F3)),
              title: const Text('เกี่ยวกับแอป'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF29A8F3)),
              title: const Text('ออกจากระบบ'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF263238),
        title: const Text('รายการนักเรียน', style: TextStyle(color: Colors.white)),
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
                    Expanded(child: DropdownMenuBox(value: level, options: levelOptions, onChanged: (v) => setState(() { level = v; year = 'ชั้นปี'; room = 'ห้อง'; }))),
                    const SizedBox(width: 8),
                    Expanded(child: DropdownMenuBox(value: year, options: yearOptions, onChanged: (v) => setState(() { year = v; room = 'ห้อง'; }))),
                    const SizedBox(width: 8),
                    Expanded(child: DropdownMenuBox(value: room, options: roomOptions, onChanged: (v) => setState(() => room = v))),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ค้นหา...',
                    prefixIcon: const Icon(Icons.search),
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
                return StudentCard(
                  index: index,
                  student: s,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ฟีเจอร์เลือกไฟล์ยังไม่เปิดใช้งาน')),
                    );
                  },
                  trailing: Image.asset(
                    'assets/galleryicon.png',
                    width: 28,
                    height: 28,
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
                    backgroundColor: const Color(0xFF29A8F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_downward, color: Colors.white, size: 28),
                  label: const Text(
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
