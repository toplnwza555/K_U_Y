import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../list.dart';
import '../register_page.dart';
import '../ForgotPasswordPage.dart'; // เพิ่ม import หน้าลืมรหัสผ่าน
import 'login_input_field.dart';
import 'login_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final errorMsg = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (errorMsg == null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ListScreen()),
      );
    } else {
      setState(() {
        _error = errorMsg;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.60),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage('assets/mylogo.png'),
            ),
          ),
          const SizedBox(height: 24),
          LoginInputField(
            controller: _emailController,
            label: 'อีเมลผู้ใช้งาน',
            icon: Icons.email,
          ),
          const SizedBox(height: 16),
          LoginInputField(
            controller: _passwordController,
            label: 'รหัสผ่าน',
            icon: Icons.lock,
            obscure: true,
          ),
          const SizedBox(height: 22),
          LoginButton(
            isLoading: _isLoading,
            onPressed: _login,
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(
              _error ?? '',
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),

          // ปรับให้เป็นแถวซ้าย-ขวา
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                  );
                },
                child: const Text(
                  'ลืมรหัสผ่าน?',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'สมัครสมาชิก',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
