import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                    'สมัครสมาชิก',
                    style: GoogleFonts.prompt(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const RegisterForm(),
                  // ------ ลบ RichText ออกเลย ------
                  // const SizedBox(height: 12),
                  // ... RichText เดิมไม่ต้องใส่
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
