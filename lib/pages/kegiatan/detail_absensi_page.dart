import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/api_service.dart';

class DetailAbsensiPage extends StatefulWidget {
  final int eventId;
  final String title;

  const DetailAbsensiPage({super.key, required this.eventId, required this.title});

  @override
  State<DetailAbsensiPage> createState() => _DetailAbsensiPageState();
}

class _DetailAbsensiPageState extends State<DetailAbsensiPage> {
  bool _isLoading = true;
  String _errorMsg = '';
  List<dynamic> _attendances = [];

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

    final result = await ApiService.getEventDetails(widget.eventId);
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _attendances = result['data']['all_attendances'] ?? [];
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
        title: Text(
          'Absensi: ${widget.title}',
          style: const TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: brandDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: brandDark),
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
              : _attendances.isEmpty
                  ? const Center(child: Text('Belum ada data anggota.', style: TextStyle(color: brandSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: _attendances.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final a = _attendances[index];
                        return _buildAttendanceCard(a);
                      },
                    ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> data) {
    String status = data['status'] ?? 'Belum';
    
    Color badgeBgColor;
    Color badgeTextColor;

    switch (status) {
      case 'Hadir':
        badgeBgColor = const Color(0xFF059669).withOpacity(0.1);
        badgeTextColor = const Color(0xFF059669);
        break;
      case 'Izin':
      case 'Sakit':
        badgeBgColor = const Color(0xFFD97706).withOpacity(0.1);
        badgeTextColor = const Color(0xFFD97706);
        break;
      case 'Alpa':
        badgeBgColor = const Color(0xFFDC2626).withOpacity(0.1);
        badgeTextColor = const Color(0xFFDC2626);
        break;
      case 'Belum':
      default:
        badgeBgColor = brandSecondary.withOpacity(0.1);
        badgeTextColor = brandSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandSecondary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: brandDark.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: brandSecondary.withOpacity(0.1),
            backgroundImage: data['profile_photo'] != null 
                ? NetworkImage('${ApiService.baseUrl.replaceAll('/api', '')}${data['profile_photo']}') 
                : null,
            child: data['profile_photo'] == null
                ? const Icon(Icons.person, color: brandSecondary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['full_name'],
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: brandDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data['nim'] ?? '-',
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 13,
                    color: brandSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
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
    );
  }
}
