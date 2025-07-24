import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<String?> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // สำเร็จ
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'เกิดข้อผิดพลาด';
    }
  }
<<<<<<< HEAD

  static Future<String?> register(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // สำเร็จ
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'เกิดข้อผิดพลาด';
    }
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
=======
>>>>>>> 69a2162d7d24f9100f23a6af3b36bb4fcd9a367a
}
