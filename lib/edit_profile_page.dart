import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _usernameController.text = user?.displayName ?? '';
  }

  Future<void> _updateUsername() async {
    try {
      await user?.updateDisplayName(_usernameController.text.trim());
      await user?.reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกชื่อผู้ใช้สำเร็จ')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขข้อมูลส่วนตัว')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: 'ชื่อผู้ใช้ (Username)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateUsername,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,  // ปรับสีพื้นหลังเป็นฟ้า
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'บันทึกการเปลี่ยนแปลง',
                style: TextStyle(color: Colors.white),  // ปรับสีตัวอักษรให้เป็นสีขาว
              ),
            ),
          ],
        ),
      ),
    );
  }
}
