import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app_colors.dart';
import '../../services/api_service.dart';

class PengaturanAkunPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const PengaturanAkunPage({super.key, required this.user});

  @override
  State<PengaturanAkunPage> createState() => _PengaturanAkunPageState();
}

class _PengaturanAkunPageState extends State<PengaturanAkunPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _majorController;
  late TextEditingController _batchController;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['full_name']);
    _majorController = TextEditingController(text: widget.user['major'] ?? '');
    _batchController = TextEditingController(text: widget.user['batch_year']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _majorController.dispose();
    _batchController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {
      'full_name': _nameController.text,
      'major': _majorController.text,
      'batch_year': _batchController.text,
    };

    if (_newPasswordController.text.isNotEmpty) {
      data['old_password'] = _oldPasswordController.text;
      data['new_password'] = _newPasswordController.text;
    }

    final result = await ApiService.updateProfile(
      data,
      imagePath: _imageFile?.path,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context, true); // true indicates updated
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal memperbarui profil'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Akun',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            color: brandDark,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: brandDark),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: brandPrimary.withOpacity(0.3), width: 2),
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: _imageFile != null
                              ? Image.file(_imageFile!, fit: BoxFit.cover)
                              : (widget.user['profile_photo'] != null
                                  ? Image.network(
                                      '${ApiService.baseUrl.replaceAll('/api', '')}/storage/${widget.user['profile_photo']}',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 50, color: brandSecondary),
                                    )
                                  : const Icon(Icons.person, size: 50, color: brandSecondary)),
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
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('Informasi Dasar', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                validator: (value) => value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _majorController,
                label: 'Program Studi / Jurusan',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _batchController,
                label: 'Angkatan (Tahun Masuk)',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 32),
              const Text('Ubah Password (Opsional)', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _oldPasswordController,
                label: 'Password Lama',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _newPasswordController,
                label: 'Password Baru',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              
              const SizedBox(height: 48),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Perubahan', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: brandSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brandSecondary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brandSecondary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandPrimary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
