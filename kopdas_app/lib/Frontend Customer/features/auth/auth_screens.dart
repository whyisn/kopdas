import '../../../../services/api_client.dart';
import '../../../../services/auth_service.dart';
import '../../core/core.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 18, children: [
        const SizedBox(height: 8),
        const BrandBlock(),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: [
            Text('Sudah punya akun?', style: dsp(context, 22)),
            AppButton(label: 'Ya, saya mau masuk', onPressed: () => context.push(Routes.login)),
            AppButton(
              label: 'Tidak, buat akun baru',
              kind: BtnKind.line,
              onPressed: () => context.push(Routes.register),
            ),
          ]),
        ),
        Text('Pesan kopi berkualitas tanpa antre langsung di barista gerobak terdekat.',
            textAlign: TextAlign.center, style: mut(context, 12)),
      ]),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String _err = '';
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final username = _email.text.trim();
    final pass = _pass.text;

    if (name.isEmpty) {
      setState(() => _err = 'Isi nama panggilanmu.');
      return;
    }
    if (username.isEmpty) {
      setState(() => _err = 'Isi username atau email.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _err = 'Kata sandi minimal 6 karakter.');
      return;
    }

    setState(() {
      _loading = true;
      _err = '';
    });

    try {
      await sessionController.register(username, name, pass);
      if (mounted) {
        context.read<AuthProvider>().setUserName(name);
        context.resetTo(Routes.home);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    } catch (e) {
      if (mounted) setState(() => _err = 'Gagal membuat akun. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Buat akun',
      back: true,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
        const SizedBox(height: 8),
        Text('Isi data singkat ini untuk membuat akun baru pelanggan.', style: mut(context, 15)),
        AppField(label: 'Nama panggilan', controller: _name, hint: 'Contoh: Maya'),
        AppField(
          label: 'Username atau email',
          controller: _email,
          hint: 'maya atau maya@mail.com',
          keyboardType: TextInputType.emailAddress,
        ),
        AppField(label: 'Kata sandi', controller: _pass, hint: 'Minimal 6 karakter', obscure: true),
        if (_err.isNotEmpty)
          Text(_err, style: body(context, size: 13, w: FontWeight.w600, color: context.pal.bad)),
        AppButton(
          label: _loading ? 'Mendaftarkan…' : 'Buat akun',
          onPressed: _loading ? null : _submit,
        ),
      ]),
    );
  }
}

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});
  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String _err = '';
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _email.text.trim();
    final pass = _pass.text;

    if (username.isEmpty) {
      setState(() => _err = 'Isi username atau email.');
      return;
    }
    if (pass.isEmpty) {
      setState(() => _err = 'Isi kata sandi.');
      return;
    }

    setState(() {
      _loading = true;
      _err = '';
    });

    try {
      await sessionController.login(username, pass);
      if (mounted) {
        final loggedName = sessionController.name ?? username;
        context.read<AuthProvider>().setUserName(loggedName);
        context.resetTo(Routes.home);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    } catch (_) {
      if (mounted) setState(() => _err = 'Gagal masuk. Periksa koneksi backend.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flash = context.watch<AuthProvider>().flash;
    final p = context.pal;
    return AppScaffold(
      title: 'Masuk',
      back: true,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
        const SizedBox(height: 8),
        flash.isNotEmpty
            ? Text(flash, style: body(context, size: 13, w: FontWeight.w600, color: p.ok))
            : Text('Masuk untuk mulai memesan di gerobak terdekat.', style: mut(context, 15)),
        AppField(
          label: 'Username atau email',
          controller: _email,
          hint: 'customer',
          keyboardType: TextInputType.emailAddress,
        ),
        AppField(
          label: 'Kata sandi',
          controller: _pass,
          hint: 'kopi123',
          obscure: true,
        ),
        if (_err.isNotEmpty)
          Text(_err, style: body(context, size: 13, w: FontWeight.w600, color: p.bad)),
        AppButton(
          label: _loading ? 'Memproses…' : 'Masuk',
          onPressed: _loading ? null : _submit,
        ),
        const SizedBox(height: 8),
        Text(
          'Akun demo: customer / kopi123',
          textAlign: TextAlign.center,
          style: mut(context, 12),
        ),
      ]),
    );
  }
}
