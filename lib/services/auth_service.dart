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
      switch (e.code) {
        case 'invalid-email':
          return 'รูปแบบอีเมลไม่ถูกต้อง';
        case 'user-not-found':
          return 'ไม่พบบัญชีผู้ใช้นี้ในระบบ';
        case 'wrong-password':
          return 'รหัสผ่านไม่ถูกต้อง';
        case 'user-disabled':
          return 'บัญชีนี้ถูกปิดใช้งาน';
        case 'too-many-requests':
          return 'มีการพยายามเข้าสู่ระบบผิดบ่อยเกินไป กรุณาลองใหม่ภายหลัง';
        case 'invalid-credential':
          return 'ข้อมูลบัญชีผู้ใช้ไม่ถูกต้อง';
        default:
          return 'เข้าสู่ระบบไม่สำเร็จ';
      }
    } catch (e) {
      return 'เกิดข้อผิดพลาด ไม่สามารถเข้าสู่ระบบได้';
    }
  }

  static Future<String?> register(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // สำเร็จ
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'รูปแบบอีเมลไม่ถูกต้อง';
        case 'email-already-in-use':
          return 'อีเมลนี้ถูกใช้สมัครบัญชีไปแล้ว';
        case 'weak-password':
          return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
        case 'operation-not-allowed':
          return 'ไม่สามารถสมัครสมาชิกได้ในขณะนี้';
        default:
          return 'สมัครสมาชิกไม่สำเร็จ';
      }
    } catch (e) {
      return 'เกิดข้อผิดพลาด ไม่สามารถสมัครสมาชิกได้';
    }
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
