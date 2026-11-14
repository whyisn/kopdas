import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String userName = '';
  String flash = '';
  String _regName = '';

  AuthProvider({String initialUserName = ''}) : userName = initialUserName;

  /// Mengembalikan pesan error, atau null jika sukses.
  String? register(String name, String email, String pass) {
    if (name.trim().isEmpty) return 'Isi nama panggilanmu.';
    if (email.trim().isEmpty) return 'Isi email atau nomor HP.';
    if (pass.length < 6) return 'Kata sandi minimal 6 karakter.';
    _regName = name.trim();
    flash = 'Akun dibuat. Silakan masuk.';
    notifyListeners();
    return null;
  }

  String? signIn(String email, String pass) {
    if (email.trim().isEmpty) return 'Isi email atau nomor HP.';
    if (pass.length < 6) return 'Kata sandi minimal 6 karakter.';
    var raw = _regName.isNotEmpty
        ? _regName
        : email.split('@').first.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (raw.isEmpty) raw = 'Teman';
    userName = raw[0].toUpperCase() + raw.substring(1);
    flash = '';
    notifyListeners();
    return null;
  }
}
