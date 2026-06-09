import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../login_page.dart';

class ProfilAnggotaPage extends StatelessWidget {
  const ProfilAnggotaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAccountHeader(),
              const SizedBox(height: 32),
              
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
    );
  }

  Widget _buildAccountHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: brandSecondary.withOpacity(0.2), width: 3),
              ),
              child: const CircleAvatar(
                radius: 46,
                backgroundColor: brandLight,
                child: Icon(Icons.person, size: 46, color: brandPrimary),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: brandPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Siti Rahma',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: brandDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'NIM: 0987654321 • Angkatan 2024',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontSize: 14,
            color: brandSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: brandPrimary.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.business, size: 14, color: brandPrimary),
                  SizedBox(width: 6),
                  Text(
                    'BEM Universitas',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: brandPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: brandSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: brandSecondary.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.business_center_outlined, size: 14, color: brandSecondary),
                  SizedBox(width: 6),
                  Text(
                    'Divisi Acara',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: brandSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceSection() {
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Persentase',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 14,
                      color: brandSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '92%',
                    style: TextStyle(
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
                    _buildStatItem('23', 'Hadir', const Color(0xFF059669)),
                    const SizedBox(height: 16),
                    _buildStatItem('0', 'Sakit', const Color(0xFF3B82F6)), // Blue
                  ],
                ),
              ),
              Container(width: 1, height: 80, color: brandSecondary.withOpacity(0.2)),
              Expanded(
                child: Column(
                  children: [
                    _buildStatItem('2', 'Izin', const Color(0xFFD97706)), // Orange
                    const SizedBox(height: 16),
                    _buildStatItem('0', 'Alpa', const Color(0xFFDC2626)), // Red
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
            onTap: () {},
          ),
          Divider(height: 1, color: brandSecondary.withOpacity(0.1), indent: 56),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () {},
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
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
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
