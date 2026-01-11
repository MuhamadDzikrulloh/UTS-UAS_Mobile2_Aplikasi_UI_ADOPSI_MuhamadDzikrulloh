import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/pet_provider.dart';
import '../models/pet_model.dart';
import '../services/pet_service.dart';

class AdminPetForm extends ConsumerStatefulWidget {
  final Pet? pet;

  const AdminPetForm({super.key, this.pet});

  @override
  ConsumerState<AdminPetForm> createState() => _AdminPetFormState();
}

class _AdminPetFormState extends ConsumerState<AdminPetForm> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _imageUrlCtrl;
  bool _isLoading = false;
  bool _useUpload = false;
  XFile? _pickedImage;
  String _category = 'Dog';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.pet?.name ?? '');
    _ageCtrl = TextEditingController(text: widget.pet?.age.toString() ?? '');
    _descCtrl = TextEditingController(text: widget.pet?.description ?? '');
    _imageUrlCtrl = TextEditingController(text: widget.pet?.imageUrl ?? '');
    final existingBreed = widget.pet?.breed;
    if (existingBreed != null && ['Dog', 'Cat', 'Rabbit'].contains(existingBreed)) {
      _category = existingBreed;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_nameCtrl.text.isEmpty ||
      _category.isEmpty ||
      _ageCtrl.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nama, breed, dan usia wajib diisi',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _imageUrlCtrl.text.trim();
      if (_useUpload && _pickedImage != null) {
        final service = PetService();
        finalImageUrl = await service.uploadImage(_pickedImage!.path);
      }
      final age = int.tryParse(_ageCtrl.text) ?? 0;
      final pet = Pet(
        id: widget.pet?.id ?? 0,
        name: _nameCtrl.text.trim(),
        breed: _category,
        age: age,
        description: _descCtrl.text.trim(),
        imageUrl: finalImageUrl,
        status: widget.pet?.status ?? 'available',
      );

      if (widget.pet == null) {
        await ref.read(petsProvider.notifier).createPet(pet);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pet.name} berhasil ditambahkan',
                  style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await ref.read(petsProvider.notifier).updatePet(widget.pet!.id, pet);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pet.name} berhasil diperbarui',
                  style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7A21),
        elevation: 0,
        title: Text(
          widget.pet == null ? 'Tambah Hewan' : 'Edit Hewan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Nama Hewan', _nameCtrl, 'Contoh: Luna'),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildTextField('Usia (tahun)', _ageCtrl, 'Contoh: 3',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField('Deskripsi', _descCtrl, 'Deskripsi hewan',
                  maxLines: 4),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Upload Gambar',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                value: _useUpload,
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFFF7A21);
                  }
                  return null;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFFF7A21).withValues(alpha: 0.4);
                  }
                  return null;
                }),
                onChanged: (v) {
                  setState(() => _useUpload = v);
                },
              ),
              const SizedBox(height: 8),
              if (_useUpload) ...[
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                              if (img != null) {
                                setState(() => _pickedImage = img);
                              }
                            },
                      icon: const Icon(Icons.image),
                      label: Text('Pilih Gambar', style: GoogleFonts.poppins()),
                    ),
                    const SizedBox(width: 12),
                    if (_pickedImage != null)
                      Expanded(
                        child: Row(
                          children: [
                            Image.file(
                              File(_pickedImage!.path),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Siap diupload saat submit',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ] else ...[
              _buildTextField(
                'URL Gambar',
                _imageUrlCtrl,
                'https://example.com/image.jpg',
              ),
              ],
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A21),
                  disabledBackgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.pet == null ? 'Tambah' : 'Perbarui',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: 1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFFFF7A21), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    const categories = ['Dog', 'Cat', 'Rabbit'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _category,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFFF7A21), width: 2),
            ),
          ),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins())))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _category = v);
          },
        ),
      ],
    );
  }
}
