import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/login_form.dart';

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
<<<<<<< HEAD
                  const LoginForm(), // มีลิงก์สมัครสมาชิกในกล่องฟอร์มแล้ว
=======
                  const LoginForm(),
>>>>>>> 69a2162d7d24f9100f23a6af3b36bb4fcd9a367a
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
