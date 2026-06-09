import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../home/home_pengurus_page.dart';
import '../kegiatan/kegiatan_page.dart';
import '../anggota/anggota_page.dart';
import '../profil/profil_page.dart';

class MainPengurusPage extends StatefulWidget {
  const MainPengurusPage({super.key});

  @override
  State<MainPengurusPage> createState() => _MainPengurusPageState();
}

class _MainPengurusPageState extends State<MainPengurusPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePengurusPage(),
    const KegiatanPage(),
    const AnggotaPage(),
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
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Anggota',
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
