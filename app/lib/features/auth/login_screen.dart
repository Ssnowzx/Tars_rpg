import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/auth/auth_controller.dart';

/// Acesso ao servidor (login/registro). Sem sessão válida, o roteador
/// redireciona para cá.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nickname = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final nickname = _nickname.text.trim();
    if (email.isEmpty || password.length < 8 || (_isRegister && nickname.length < 3)) {
      _toast('Preencha e-mail, senha (mín. 8) e nickname (mín. 3 no registro).');
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = ref.read(authProvider.notifier);
      if (_isRegister) {
        await auth.register(email, password, nickname);
      } else {
        await auth.login(email, password);
      }
    } catch (e) {
      _toast(apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)),
      );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: t.surfacePage,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(t.space4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: EdgeInsets.all(t.space6),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(t.radiusCard),
                border: Border.all(color: t.borderDefault),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.public, color: FwPalette.rust600, size: 26),
                      SizedBox(width: t.space2),
                      Text('Fertways',
                          style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.w700, fontSize: 26, color: FwPalette.gray900)),
                    ],
                  ),
                  SizedBox(height: t.space1),
                  Text(_isRegister ? 'Crie sua colônia em Fertways.' : 'Entre para gerir sua colônia.',
                      style: TextStyle(fontSize: 13, color: t.textSecondary)),
                  SizedBox(height: t.space4),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: t.space3),
                  if (_isRegister) ...[
                    TextField(
                      controller: _nickname,
                      decoration: const InputDecoration(labelText: 'Nickname', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: t.space3),
                  ],
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: t.space4),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: FwPalette.rust600,
                      minimumSize: Size(0, t.controlLg),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isRegister ? 'Registrar' : 'Entrar'),
                  ),
                  SizedBox(height: t.space2),
                  TextButton(
                    onPressed: _loading ? null : () => setState(() => _isRegister = !_isRegister),
                    child: Text(_isRegister
                        ? 'Já tem conta? Entrar'
                        : 'Novo colono? Criar conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
