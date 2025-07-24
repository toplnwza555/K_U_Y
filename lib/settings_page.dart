import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/theme_notifier.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // ฟังก์ชันสำหรับลบบัญชีผู้ใช้ทันที
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // ลบบัญชีผู้ใช้
      await FirebaseAuth.instance.currentUser?.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บัญชีผู้ใช้ถูกลบเรียบร้อยแล้ว')),
      );
      Navigator.of(context).pop(); // กลับไปหน้าหลักหลังจากลบบัญชี
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeNotifier>().isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text('การตั้งค่า')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('บัญชีผู้ใช้', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('แก้ไขข้อมูลส่วนตัว'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('เปลี่ยนรหัสผ่าน'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.redAccent),
            title: const Text('ลบบัญชีผู้ใช้', style: TextStyle(color: Colors.redAccent)),
            onTap: () => _deleteAccount(context), // ลบบัญชีเมื่อกดปุ่ม
          ),
          const Divider(height: 32),
          const Text('การแสดงผล', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('โหมดสีเข้ม (Dark Mode)'),
            value: isDarkMode,
            onChanged: (_) => context.read<ThemeNotifier>().toggleTheme(),
          ),
        ],
      ),
    );
  }
}
