// lib/widgets/register_form.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../list.dart';
import '../login.dart'; // <- อย่าลืม import login

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  // ---- เพิ่มตัวแปรนี้สำหรับโชว์/ซ่อนรหัสผ่าน ----
  bool _obscurePassword = true;

  Future<void> _register() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });
    final error = await AuthService.register(
      _emailController.text,
      _passwordController.text,
    );
    if (error == null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ListScreen()),
      );
    } else {
      setState(() {
        _error = error;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.10),
              labelText: 'อีเมล',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.email, color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ---- ช่องรหัสผ่านที่มีปุ่มโชว์/ซ่อน ----
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.10),
              labelText: 'รหัสผ่าน',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.lock, color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              // เพิ่มปุ่มไอคอนตา
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 22),
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('สมัครสมาชิก',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          // ==== ย้าย RichText (เข้าสู่ระบบ) มาไว้ที่นี่ ====
          RichText(
            text: TextSpan(
              text: 'มีบัญชีอยู่แล้ว? ',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              children: [
                TextSpan(
                  text: 'เข้าสู่ระบบ',
                  style: const TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pop(context); // หรือจะ pushReplacement LoginPage ก็ได้
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
