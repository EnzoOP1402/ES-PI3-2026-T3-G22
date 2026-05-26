import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mescla_invest_app/features/profile/presentation/screens/camera_screen.dart';

Future<UserModel?> getCurrentUserData() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!doc.exists || doc.data() == null) return null;

  return UserModel.fromMap({...doc.data()!, 'uid': doc.id});
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userData;
  bool _isLoading = true;
  bool _isUpdatingPhoto = false;

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

  Future<void> _alterarFotoPerfil() async {
    if (_isUpdatingPhoto) return;

    setState(() {
      _isUpdatingPhoto = true;
    });

    try {
      final imageUrl = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const CameraScreen()),
      );

      if (imageUrl == null || imageUrl.isEmpty) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoUrl': imageUrl,
      }, SetOptions(merge: true));

      await _loadUserData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil atualizada com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar foto: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isUpdatingPhoto = false;
      });
    }
  }

  String get nome => _userData?.fullName ?? 'Usuário';
  String get email => _userData?.email ?? 'usuario@gmail.com';
  String get cpf => _userData?.cpf ?? '000.000.000-00';
  String get phone => _userData?.phone ?? '(00) 00000-0000';
  String get inicial => nome.isNotEmpty ? nome[0].toUpperCase() : '?';

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final String photoUrl = _userData?.photoUrl ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      appBar: CustomAppBar(
        title: 'Conta',
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl.isEmpty
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: SizedBox(
                          width: 240,
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: _isUpdatingPhoto
                                ? null
                                : _alterarFotoPerfil,
                            icon: _isUpdatingPhoto
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF3F3D99),
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 20,
                                    color: Color(0xFF3F3D99),
                                  ),
                            label: Text(
                              _isUpdatingPhoto
                                  ? 'Atualizando...'
                                  : 'Alterar foto de perfil',
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
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
                        child: ActionButton(
                          icon: Icons.history,
                          label: 'Histórico de compras',
                          onTap: () => _showMessage('Histórico de compras'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ActionButton(
                          icon: Icons.logout_outlined,
                          label: 'Sair da conta',
                          onTap: AuthRepository.instance.logout
                          )
                          )
                      ]
                    ),
                  ),
                ),
              ),
      );
}}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

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

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  ActionButton({
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
        icon: Icon(icon, size: 24, color: const Color(0xFF3F3D99)),
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
          side: const BorderSide(color: Color(0xFF3F3D99)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
