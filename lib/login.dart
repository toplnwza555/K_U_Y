import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/login_form.dart';
import 'ForgotPasswordPage.dart'; // เพิ่มการ import หน้ารีเซ็ตรหัสผ่าน

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/fantasy_bg.png', fit: BoxFit.cover),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EasyCrop',
                    style: GoogleFonts.prompt(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const LoginForm(), // ฟอร์มล็อกอิน (มีลิงก์ลืมรหัสผ่านอยู่ภายในแล้ว)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
