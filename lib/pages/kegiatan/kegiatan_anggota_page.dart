import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'detail_notulensi_page.dart';

class KegiatanAnggotaPage extends StatefulWidget {
  const KegiatanAnggotaPage({super.key});

  @override
  State<KegiatanAnggotaPage> createState() => _KegiatanAnggotaPageState();
}

class _KegiatanAnggotaPageState extends State<KegiatanAnggotaPage> {
  String _selectedFilter = 'Mendatang';
  bool _isLoading = true;
  String _errorMsg = '';
  List<dynamic> _kegiatanList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    String apiFilter = _selectedFilter == 'Mendatang' ? 'upcoming' : 'past';

    final result = await ApiService.getEvents(filter: apiFilter);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _kegiatanList = result['data'];
      } else {
        _errorMsg = result['message'] ?? 'Terjadi kesalahan';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Kegiatan Organisasi',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: brandDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brandPrimary))
          : _errorMsg.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMsg, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  color: brandPrimary,
                  child: _kegiatanList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(child: Text('Tidak ada kegiatan.', style: TextStyle(color: brandSecondary))),
                            )
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          itemCount: _kegiatanList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final kegiatan = _kegiatanList[index];
                            return _buildKegiatanCard(kegiatan);
                          },
                        ),
                ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildFilterChip('Mendatang'),
          const SizedBox(width: 8),
          _buildFilterChip('Selesai'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        if (_selectedFilter != label) {
          setState(() {
            _selectedFilter = label;
          });
          _fetchData();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? brandDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? brandDark : brandSecondary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Figtree',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : brandSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildKegiatanCard(Map<String, dynamic> kegiatan) {
    DateTime date = DateTime.parse(kegiatan['event_date']);
    String formattedDate = DateFormat('dd MMM yyyy').format(date);
    String timeStr = '${kegiatan['start_time'].substring(0, 5)} - ${kegiatan['end_time'] != null ? kegiatan['end_time'].substring(0, 5) : 'Selesai'}';

    String apiStatus = kegiatan['status'] ?? 'pending';
    String statusStr = 'Mendatang';
    bool isSelesai = false;
    bool isOngoing = false;
    
    if (apiStatus == 'completed') {
      statusStr = 'Selesai';
      isSelesai = true;
    } else if (apiStatus == 'ongoing') {
      statusStr = 'Sedang Berlangsung';
      isOngoing = true;
    } else {
      statusStr = 'Mendatang';
    }

    final statusAttendance = kegiatan['my_status'] ?? 'Belum';
    
    Color badgeBgColor;
    Color badgeTextColor;

    switch (statusAttendance) {
      case 'Hadir':
        badgeBgColor = const Color(0xFF059669).withOpacity(0.1);
        badgeTextColor = const Color(0xFF059669);
        break;
      case 'Izin':
        badgeBgColor = const Color(0xFFD97706).withOpacity(0.1);
        badgeTextColor = const Color(0xFFD97706);
        break;
      case 'Belum':
      default:
        badgeBgColor = brandSecondary.withOpacity(0.1);
        badgeTextColor = brandSecondary;
        break;
    }

    return GestureDetector(
      onTap: () => _showKegiatanDetail(kegiatan, formattedDate, timeStr, badgeBgColor, badgeTextColor, statusAttendance, isSelesai, isOngoing),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brandSecondary.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: brandDark.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusAttendance,
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelesai ? brandSecondary : isOngoing ? const Color(0xFF4ADE80) : brandPrimary,
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: brandSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              kegiatan['title'],
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: brandDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: brandSecondary.withOpacity(0.8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    kegiatan['location'] ?? '-',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 13,
                      color: brandSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showKegiatanDetail(Map<String, dynamic> kegiatan, String dateStr, String timeStr, Color badgeBgColor, Color badgeTextColor, String statusAttendance, bool isSelesai, bool isOngoing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelesai
                        ? brandSecondary.withOpacity(0.1)
                        : isOngoing ? const Color(0xFF4ADE80).withOpacity(0.1) : brandPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        kegiatan['title'],
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: brandDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusAttendance,
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal', dateStr),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.access_time_outlined, 'Waktu', timeStr),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.location_on_outlined, 'Lokasi', kegiatan['location'] ?? '-'),
                const SizedBox(height: 32),
                if (kegiatan['notes'] != null && kegiatan['notes'].isNotEmpty) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailNotulensiPage(
                            title: kegiatan['title'],
                            content: kegiatan['notes'][0]['content'] ?? '',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandLight,
                      foregroundColor: brandPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: brandPrimary, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'Lihat Notulensi',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: brandLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: brandPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 12,
                  color: brandSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: brandDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
