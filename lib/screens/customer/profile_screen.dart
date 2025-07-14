import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData(User? user) async {
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.usuario;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header vermelho
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 8),
                  const Text('Perfil', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: user == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.user, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text('Faça login para acessar seu perfil'),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                icon: const Icon(FontAwesomeIcons.rightToBracket),
                                label: const Text('Login'),
                                onPressed: () => Navigator.pushNamed(context, '/login'),
                              ),
                            ],
                          )
                        : FutureBuilder<Map<String, dynamic>?>(
                            future: _getUserData(user),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final data = snapshot.data!;
                              final nome = data['nome'] ?? '';
                              final email = data['email'] ?? user.email ?? '';
                              final role = data['role'] ?? 'customer';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 32),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Avatar
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: AppColors.primary, width: 2),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(FontAwesomeIcons.circleUser, size: 64, color: AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nome.isNotEmpty ? nome : 'Usuário',
                                              style: Theme.of(context).textTheme.titleLarge,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(email, style: Theme.of(context).textTheme.bodyMedium),
                                          ],
                                        ),
                                      ),
                                      // Tag de papel
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: role == 'admin' ? AppColors.primary : Colors.grey[300],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              role == 'admin' ? FontAwesomeIcons.userShield : FontAwesomeIcons.user,
                                              size: 14,
                                              color: role == 'admin' ? Colors.white : Colors.black54,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              role == 'admin' ? 'Administrador' : 'Cliente',
                                              style: TextStyle(
                                                color: role == 'admin' ? Colors.white : Colors.black87,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  // Painel de controle (apenas admin)
                                  if (role == 'admin') ...[
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        icon: const Icon(FontAwesomeIcons.screwdriverWrench, color: AppColors.primary),
                                        label: const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                          child: Text('Painel de Controle', style: TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.primary, width: 2),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          backgroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/admin');
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                  // Botão sair
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(FontAwesomeIcons.arrowRightFromBracket),
                                      label: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Text('Sair', style: TextStyle(fontSize: 16)),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      onPressed: () async {
                                        await auth.logout();
                                        if (context.mounted) {
                                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 