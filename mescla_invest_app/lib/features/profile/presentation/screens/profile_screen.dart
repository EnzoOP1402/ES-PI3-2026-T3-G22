import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<UserModel?> getCurrentUserData() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!doc.exists || doc.data() == null) return null;

  return UserModel.fromMap({
    ...doc.data()!,
    'uid': doc.id,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await getCurrentUserData();

    if (!mounted) return;

    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  String get nome => _userData?.fullName ?? 'Usuário';
  String get email => _userData?.email ?? 'usuario@gmail.com';
  String get cpf => _userData?.cpf ?? '000.000.000-00';
  String get phone => _userData?.phone ?? '(00) 00000-0000';
  String get inicial => nome.isNotEmpty ? nome[0].toUpperCase() : '?';

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F3D99),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Conta',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),

                      Center(
                        child: CircleAvatar(
                          radius: 62,
                          backgroundColor: const Color(0xFF8A8A8A),
                          child: Text(
                            inicial,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Center(
                        child: SizedBox(
                          width: 240,
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: () => _showMessage('Alterar foto de perfil'),
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              size: 20,
                              color: Color(0xFF3F3D99),
                            ),
                            label: Text(
                              'Alterar foto de perfil',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: const Color(0xFF3F3D99),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF4F4F4),
                              side: const BorderSide(color: Color(0xFF3F3D99)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                      const Divider(color: Color(0xFFC9C9C9), thickness: 1),

                      const SizedBox(height: 10),
                      _InfoItem(label: 'Nome:', value: nome),
                      const SizedBox(height: 12),
                      _InfoItem(label: 'E-mail:', value: email),
                      const SizedBox(height: 12),
                      _InfoItem(label: 'CPF:', value: cpf),
                      const SizedBox(height: 12),
                      _InfoItem(label: 'Telefone:', value: phone),

                      const SizedBox(height: 18),
                      const Divider(color: Color(0xFFC9C9C9), thickness: 1),

                      const SizedBox(height: 30),

                      Center(
                        child: _ActionButton(
                          icon: Icons.history,
                          label: 'Histórico de compras',
                          onTap: () => _showMessage('Histórico de compras'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: _ActionButton(
                          icon: Icons.logout_outlined,
                          label: 'Sair da conta',
                          onTap: () => _showMessage('Saindo da conta...'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const AppBottomNavigation(
        selectedIndex: 4,
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: const Color(0xFF3F3D99),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 24,
          color: const Color(0xFF3F3D99),
        ),
        label: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: const Color(0xFF3F3D99),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF4F4F4),
          side: const BorderSide(
            color: Color(0xFF3F3D99),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}