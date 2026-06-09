import 'dart:math';
import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../login_page.dart';
import '../../services/api_service.dart';
import 'pengaturan_akun_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool _isLoading = true;
  String _errorMsg = '';
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    final result = await ApiService.getMe();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _user = result['data'];
      } else {
        _errorMsg = result['message'] ?? 'Terjadi kesalahan';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundLight,
        body: Center(child: CircularProgressIndicator(color: brandPrimary)),
      );
    }

    if (_errorMsg.isNotEmpty || _user == null) {
      return Scaffold(
        backgroundColor: backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMsg, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchProfile,
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProfile,
          color: brandPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAccountHeader(),
              const SizedBox(height: 32),
              
              const Text(
                'Organisasi',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: brandDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildOrganizationSection(),
              
              const SizedBox(height: 32),
              
              if (_user!['attendance_stats'] != null) ...[
                const Text(
                  'Riwayat Kehadiran',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: brandDark,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAttendanceSection(),
                const SizedBox(height: 32),
              ],

              const Text(
                'Lainnya',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: brandDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsMenu(context),
              
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Versi 1.0.0',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 12,
                    color: brandSecondary.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildAccountHeader() {
    String name = _user!['full_name'] ?? 'Nama Pengguna';
    String nim = _user!['nim'] ?? '-';
    String role = _user!['role'] ?? 'anggota';
    String roleDisplay = role.substring(0, 1).toUpperCase() + role.substring(1);
    
    // Check for profile photo
    String? photoPath = _user!['profile_photo'];
    Widget avatarChild;
    if (photoPath != null && photoPath.isNotEmpty) {
      avatarChild = ClipOval(
        child: Image.network(
          '${ApiService.baseUrl.replaceAll('/api', '')}/storage/$photoPath',
          fit: BoxFit.cover,
          width: 92,
          height: 92,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 46, color: brandPrimary),
        ),
      );
    } else {
      avatarChild = const Icon(Icons.person, size: 46, color: brandPrimary);
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: brandSecondary.withOpacity(0.2), width: 3),
          ),
          child: CircleAvatar(
            radius: 46,
            backgroundColor: brandLight,
            child: avatarChild,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Figtree',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: brandDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'NIM: $nim',
          style: const TextStyle(
            fontFamily: 'Figtree',
            fontSize: 14,
            color: brandSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: brandPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: brandPrimary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, size: 14, color: brandPrimary),
              const SizedBox(width: 6),
              Text(
                roleDisplay,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: brandPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationSection() {
    final orgMember = _user!['organization_member'];
    final org = orgMember != null ? orgMember['organization'] : null;
    
    if (org == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: brandSecondary.withOpacity(0.12)),
        ),
        child: const Center(
          child: Text('Belum bergabung dengan organisasi manapun.', style: TextStyle(color: brandSecondary)),
        ),
      );
    }

    String orgName = org['name'] ?? 'Organisasi';
    String orgInitial = orgName.substring(0, min(3, orgName.length)).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brandSecondary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: brandDark.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: brandDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    orgInitial,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgName,
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: brandDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      org['university'] ?? '-',
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 13,
                        color: brandSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection() {
    final stats = _user!['attendance_stats'];
    if (stats == null) return const SizedBox();

    int pct = stats['percentage'] ?? 0;
    int hadir = stats['hadir'] ?? 0;
    int izin = stats['izin'] ?? 0;
    int sakit = stats['sakit'] ?? 0;
    int alpa = stats['alpa'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brandSecondary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: brandDark.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Persentase',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 14,
                      color: brandSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF059669), // Green
                    ),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF059669), width: 6),
                ),
                child: Center(
                  child: Icon(Icons.check, color: const Color(0xFF059669).withOpacity(0.5), size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildStatItem('$hadir', 'Hadir', const Color(0xFF059669)),
                    const SizedBox(height: 16),
                    _buildStatItem('$sakit', 'Sakit', const Color(0xFF3B82F6)), // Blue
                  ],
                ),
              ),
              Container(width: 1, height: 80, color: brandSecondary.withOpacity(0.2)),
              Expanded(
                child: Column(
                  children: [
                    _buildStatItem('$izin', 'Izin', const Color(0xFFD97706)), // Orange
                    const SizedBox(height: 16),
                    _buildStatItem('$alpa', 'Alpa', const Color(0xFFDC2626)), // Red
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          '$value $label',
          style: const TextStyle(
            fontFamily: 'Figtree',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: brandDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brandSecondary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: brandDark.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan Akun',
            onTap: () async {
              bool? updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PengaturanAkunPage(user: _user!)),
              );
              if (updated == true) {
                _fetchProfile();
              }
            },
          ),
          Divider(height: 1, color: brandSecondary.withOpacity(0.1), indent: 56),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Keluar',
            titleColor: const Color(0xFFDC2626),
            iconColor: const Color(0xFFDC2626),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? brandSecondary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? brandSecondary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Figtree',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: titleColor ?? brandDark,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: brandSecondary, size: 20),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(
            fontFamily: 'Figtree',
            color: brandSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Figtree',
                color: brandSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
