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
        Text('Ini prototipe. Akun apa pun diterima dan tidak disimpan.',
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

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    final err = context.read<AuthProvider>().register(_name.text, _email.text, _pass.text);
    if (err != null) {
      setState(() => _err = err);
    } else {
      context.replace(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Buat akun',
      back: true,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [
        const SizedBox(height: 8),
        Text('Isi data singkat ini. Setelah itu kamu langsung masuk.', style: mut(context, 15)),
        AppField(label: 'Nama panggilan', controller: _name, hint: 'Contoh: Rani'),
        AppField(
          label: 'Email atau nomor HP',
          controller: _email,
          hint: 'rani@contoh.id',
          keyboardType: TextInputType.emailAddress,
        ),
        AppField(label: 'Kata sandi', controller: _pass, hint: 'Minimal 6 karakter', obscure: true),
        if (_err.isNotEmpty)
          Text(_err, style: body(context, size: 13, w: FontWeight.w600, color: context.pal.bad)),
        AppButton(label: 'Buat akun', onPressed: _submit),
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

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    final err = context.read<AuthProvider>().signIn(_email.text, _pass.text);
    if (err != null) {
      setState(() => _err = err);
    } else {
      context.resetTo(Routes.home);
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
            : Text('Masuk untuk mulai mencari gerobak.', style: mut(context, 15)),
        AppField(
          label: 'Email atau nomor HP',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        AppField(label: 'Kata sandi', controller: _pass, obscure: true),
        if (_err.isNotEmpty)
          Text(_err, style: body(context, size: 13, w: FontWeight.w600, color: p.bad)),
        AppButton(label: 'Masuk', onPressed: _submit),
      ]),
    );
  }
}
