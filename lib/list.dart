import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:excel/excel.dart' as excel;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'login.dart';
import 'widgets/dropdown_box.dart';
import 'widgets/student_card.dart';
import 'services/theme_notifier.dart';
import 'settings_page.dart';

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
  final ImagePicker _picker = ImagePicker();
  Map<String, File> studentImages = {};

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

  Future<void> _openCamera(String studentId) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      setState(() {
        studentImages[studentId] = image;
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ถ่ายภาพสำเร็จ')),
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่ได้ถ่ายภาพ')),
      );
    }
  }

  Future<void> _downloadAllImages() async {
    final status = await _requestStoragePermission();
    if (!status) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่ได้รับสิทธิ์เข้าถึง Storage')),
      );
      return;
    }

    final dir = Directory('/storage/emulated/0/DCIM/EasyCrop');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    for (var entry in studentImages.entries) {
      final fileName = '${entry.key}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = p.join(dir.path, fileName);
      await entry.value.copy(newPath);
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ดาวน์โหลด ${studentImages.length} รูปเสร็จสิ้น')),
    );
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.request().isGranted) return true;
      if (await Permission.manageExternalStorage.request().isGranted) return true;
      if (await Permission.storage.request().isGranted) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    final levelOptions = ['ระดับชั้น', ...{...students.map((s) => extractLevel(s['room']!))}..remove('อื่นๆ')];
    final yearOptions = ['ชั้นปี', ...{
      ...students.where((s) => level == 'ระดับชั้น' || extractLevel(s['room']!) == level).map((s) => extractYear(s['room']!))
    }..remove('อื่นๆ')];
    final roomChoices = ['ห้อง', ...{
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
      drawer: buildDrawer(isDarkMode, textColor),
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFF263238),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('รายการนักเรียน', style: TextStyle(color: Colors.white)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          buildFilterBar(isDarkMode, textColor, levelOptions, yearOptions, roomChoices),
          Expanded(child: buildStudentList(filtered, isDarkMode)),
          buildDownloadButton(),
        ],
      ),
    );
  }

  Widget buildDrawer(bool isDarkMode, Color textColor) {
    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : const Color(0xFF29A8F3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(radius: 32, backgroundImage: AssetImage('assets/mylogo.png')),
                SizedBox(height: 10),
                Text('เมนูหลัก', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF29A8F3)),
            title: Text('หน้าหลัก', style: TextStyle(color: textColor)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF29A8F3)),
            title: Text('ตั้งค่า', style: TextStyle(color: textColor)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF29A8F3)),
            title: Text('ออกจากระบบ', style: TextStyle(color: textColor)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget buildFilterBar(bool isDarkMode, Color textColor, List<String> levelOptions, List<String> yearOptions, List<String> roomChoices) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: DropdownMenuBox(value: level, options: levelOptions, onChanged: (v) => setState(() { level = v; year = 'ชั้นปี'; room = 'ห้อง'; }))),
              const SizedBox(width: 8),
              Expanded(child: DropdownMenuBox(value: year, options: yearOptions, onChanged: (v) => setState(() { year = v; room = 'ห้อง'; }))),
              const SizedBox(width: 8),
              Expanded(child: DropdownMenuBox(value: room, options: roomChoices, onChanged: (v) => setState(() => room = v))),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'ค้นหา...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : Colors.grey.shade200,
            ),
            style: TextStyle(color: textColor),
            onChanged: (v) => setState(() => query = v),
          ),
        ],
      ),
    );
  }

  Widget buildStudentList(List<Map<String, String>> filtered, bool isDarkMode) {
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final s = filtered[index];
        final id = s['id']!;
        return StudentCard(
          index: index,
          student: s,
          onTap: () => _openCamera(id),
          trailing: studentImages[id] != null
              ? Image.file(studentImages[id]!, width: 28, height: 28, fit: BoxFit.cover)
              : Image.asset('assets/galleryicon.png', width: 28, height: 28),
          image: studentImages[id],
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  Widget buildDownloadButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Center(
        child: SizedBox(
          width: 330,
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF29A8F3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 2,
            ),
            onPressed: studentImages.isEmpty ? null : _downloadAllImages,
            icon: const Icon(Icons.arrow_downward, color: Colors.white, size: 28),
            label: Text('ดาวน์โหลด (${studentImages.length})',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 21, letterSpacing: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
