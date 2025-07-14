import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _senha = '';
  String _confirmarSenha = '';
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _erro;
  String _nome = '';

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_senha != _confirmarSenha) {
      setState(() {
        _erro = 'As senhas não coincidem.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      await Provider.of<AuthService>(
        context,
        listen: false,
      ).registrar(_email, _senha, nome: _nome);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false, arguments: {'tab': 2});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(FontAwesomeIcons.circleCheck, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Conta criada com sucesso!')),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      String mensagemErro = 'Falha no cadastro: ${e.toString()}';
      if (e is Exception && e.toString().contains('password-does-not-meet-requirements')) {
        mensagemErro = 'A senha deve ter pelo menos 8 caracteres, uma letra maiúscula, um número e um caractere especial.';
      } else if (e is Exception && e.toString().contains('email-already-in-use')) {
        mensagemErro = 'Este e-mail já está cadastrado. Faça login ou use outro e-mail.';
      }
      setState(() {
        _erro = mensagemErro;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Cadastro'),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo e título
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF780000).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FontAwesomeIcons.userPlus,
                      size: 64,
                      color: const Color(0xFF780000),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Criar conta',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preencha os dados para se cadastrar',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // formulario
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // nome
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            prefixIcon: Icon(FontAwesomeIcons.user),
                            hintText: 'Digite seu nome',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu nome';
                            }
                            return null;
                          },
                          onChanged: (v) => _nome = v,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        // email
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(FontAwesomeIcons.solidEnvelope),
                            hintText: 'Digite seu e-mail',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          onChanged: (v) => _email = v,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        // senha
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(FontAwesomeIcons.lock),
                            hintText: 'Digite sua senha',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                    ? FontAwesomeIcons.eye 
                                    : FontAwesomeIcons.eyeSlash,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: Validators.senha,
                          onChanged: (v) => _senha = v,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        // confirmar senha
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Confirmar Senha',
                            prefixIcon: const Icon(FontAwesomeIcons.lock),
                            hintText: 'Confirme sua senha',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword 
                                    ? FontAwesomeIcons.eye 
                                    : FontAwesomeIcons.eyeSlash,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirme sua senha';
                            }
                            if (value != _senha) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                          onChanged: (v) => _confirmarSenha = v,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _registrar(),
                        ),
                        const SizedBox(height: 24),
                        if (_erro != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.circleExclamation,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _erro!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // cadastro
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            icon: const Icon(FontAwesomeIcons.userPlus),
                            onPressed: _loading ? null : _registrar,
                            label: _loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Cadastrar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Já tem uma conta? ',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(FontAwesomeIcons.rightToBracket, size: 16),
                              onPressed: _loading
                                  ? null
                                  : () {
                                      Navigator.pushReplacementNamed(context, '/login');
                                    },
                              label: const Text('Entrar'),
                            ),
                          ],
                        ),
                      ],
                    ),
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
