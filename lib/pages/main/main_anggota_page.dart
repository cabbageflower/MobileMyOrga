import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../home/home_anggota_page.dart';
import '../kegiatan/kegiatan_anggota_page.dart';
import '../absensi/absensi_page.dart';
import '../profil/profil_page.dart';

class MainAnggotaPage extends StatefulWidget {
  const MainAnggotaPage({super.key});

  @override
  State<MainAnggotaPage> createState() => _MainAnggotaPageState();
}

class _MainAnggotaPageState extends State<MainAnggotaPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeAnggotaPage(),
    const KegiatanAnggotaPage(),
    const AbsensiPage(),
    const ProfilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: brandPrimary,
        unselectedItemColor: brandSecondary,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Figtree',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Figtree',
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Kegiatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
