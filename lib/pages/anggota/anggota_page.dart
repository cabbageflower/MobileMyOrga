import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/api_service.dart';

class AnggotaPage extends StatefulWidget {
  const AnggotaPage({super.key});

  @override
  State<AnggotaPage> createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  bool _isLoading = true;
  String _errorMsg = '';
  List<dynamic> _anggotaList = [];
  String _selectedDivision = 'Semua Divisi';

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    final result = await ApiService.getMembers();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _anggotaList = result['data'];
      } else {
        _errorMsg = result['message'] ?? 'Gagal memuat anggota';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Daftar Anggota',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: brandDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: brandPrimary));
    }

    if (_errorMsg.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMsg, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMembers,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_anggotaList.isEmpty) {
      return const Center(
        child: Text('Belum ada anggota dalam organisasi ini.', style: TextStyle(color: brandSecondary)),
      );
    }

    List<String> divisions = ['Semua Divisi'];
    for (var a in _anggotaList) {
      String div = a['division'] ?? '-';
      if (!divisions.contains(div)) {
        divisions.add(div);
      }
    }

    // Ensure selected division is in the list (e.g. if list changes)
    if (!divisions.contains(_selectedDivision)) {
      _selectedDivision = 'Semua Divisi';
    }

    List<dynamic> filteredList = _anggotaList.where((a) {
      if (_selectedDivision == 'Semua Divisi') return true;
      return (a['division'] ?? '-') == _selectedDivision;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: brandSecondary.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDivision,
                isExpanded: true,
                icon: const Icon(Icons.filter_list, color: brandPrimary),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDivision = newValue;
                    });
                  }
                },
                items: divisions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        color: brandDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchMembers,
            color: brandPrimary,
            child: filteredList.isEmpty 
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: const Center(child: Text('Tidak ada anggota di divisi ini.', style: TextStyle(color: brandSecondary))),
                      )
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildAnggotaCard(filteredList[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnggotaCard(dynamic anggota) {
    final int attendance = anggota['attendance'] ?? 0;
    Color badgeColor;
    
    if (attendance >= 80) {
      badgeColor = const Color(0xFF059669); // Green
    } else if (attendance >= 60) {
      badgeColor = const Color(0xFFD97706); // Orange
    } else {
      badgeColor = const Color(0xFFDC2626); // Red
    }

    String? photoPath = anggota['profile_photo'];

    return GestureDetector(
      onTap: () => _showAnggotaDetail(anggota, badgeColor),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brandSecondary.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: brandDark.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: brandPrimary.withOpacity(0.1),
              child: photoPath != null
                  ? ClipOval(
                      child: Image.network(
                        '${ApiService.baseUrl.replaceAll('/api', '')}$photoPath',
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: brandPrimary),
                      ),
                    )
                  : const Icon(Icons.person, color: brandPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anggota['full_name'] ?? 'Tanpa Nama',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: brandDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    anggota['division'] ?? '-',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      color: brandSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeColor.withOpacity(0.2)),
              ),
              child: Text(
                '$attendance%',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnggotaDetail(dynamic anggota, Color badgeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AnggotaDetailSheet(
          memberId: anggota['id'],
          basicInfo: anggota,
          badgeColor: badgeColor,
        );
      },
    );
  }
}

class _AnggotaDetailSheet extends StatefulWidget {
  final int memberId;
  final dynamic basicInfo;
  final Color badgeColor;

  const _AnggotaDetailSheet({
    required this.memberId,
    required this.basicInfo,
    required this.badgeColor,
  });

  @override
  State<_AnggotaDetailSheet> createState() => _AnggotaDetailSheetState();
}

class _AnggotaDetailSheetState extends State<_AnggotaDetailSheet> {
  bool _isLoading = true;
  String _errorMsg = '';
  Map<String, dynamic>? _details;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final result = await ApiService.getMemberDetails(widget.memberId);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _details = result['data'];
      } else {
        _errorMsg = result['message'] ?? 'Gagal memuat detail';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final anggota = widget.basicInfo;
    String? photoPath = anggota['profile_photo'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: brandSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 40,
              backgroundColor: brandPrimary.withOpacity(0.1),
              child: photoPath != null
                  ? ClipOval(
                      child: Image.network(
                        '${ApiService.baseUrl.replaceAll('/api', '')}$photoPath',
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: brandPrimary, size: 40),
                      ),
                    )
                  : const Icon(Icons.person, color: brandPrimary, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              anggota['full_name'] ?? 'Tanpa Nama',
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: brandDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              anggota['division'] ?? '-',
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 14,
                color: brandSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(child: CircularProgressIndicator(color: brandPrimary)),
      );
    }

    if (_errorMsg.isNotEmpty || _details == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(_errorMsg.isNotEmpty ? _errorMsg : 'Gagal memuat', style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final stats = _details!['attendance_stats'];
    final history = _details!['attendance_history'] as List<dynamic>;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attendance Summary in Sheet
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: brandSecondary.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Kehadiran',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: brandDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stats['percentage']}%',
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        const Text(
          'Riwayat Terbaru',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: brandDark,
          ),
        ),
        const SizedBox(height: 12),
        
        if (history.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('Belum ada riwayat kegiatan.', style: TextStyle(color: brandSecondary))),
          )
        else
          ...history.take(3).map((item) {
            Color color;
            String status = item['status'];
            if (status == 'Hadir') color = const Color(0xFF059669);
            else if (status == 'Izin' || status == 'Sakit') color = const Color(0xFFD97706);
            else color = const Color(0xFFDC2626); // Alpa
            
            // Format date basic (yyyy-mm-dd -> just simple string)
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildHistoryItem(status, item['title'], item['date'], color),
            );
          }),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHistoryItem(String status, String kegiatan, String tanggal, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brandSecondary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kegiatan,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: brandDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tanggal.substring(0, 10), // Take just the date part if it's timestamp
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 11,
                    color: brandSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'Figtree',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
