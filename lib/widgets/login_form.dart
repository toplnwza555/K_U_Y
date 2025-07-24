import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../list.dart';
<<<<<<< HEAD
import '../register_page.dart'; // เพิ่มตรงนี้
=======
>>>>>>> 69a2162d7d24f9100f23a6af3b36bb4fcd9a367a
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
<<<<<<< HEAD
          const SizedBox(height: 24),

          // เพิ่มปุ่มสมัครสมาชิก
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(text: 'ยังไม่มีบัญชี? '),
                  TextSpan(
                    text: 'สมัครสมาชิก',
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
=======
>>>>>>> 69a2162d7d24f9100f23a6af3b36bb4fcd9a367a
        ],
      ),
    );
  }
}
