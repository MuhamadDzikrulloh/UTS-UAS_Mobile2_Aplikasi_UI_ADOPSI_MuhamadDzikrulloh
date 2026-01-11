import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pet_provider.dart';
import '../providers/auth_provider.dart';
import '../models/pet_model.dart';
import 'admin_pet_form.dart';
import 'admin_chat_list_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final petsAsyncValue = ref.watch(petsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7A21),
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                auth.email ?? 'Admin',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Chat',
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminChatListScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await ref.read(authProvider.notifier).logout();
              if (!mounted) return;
              navigator.pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminPetForm(),
            ),
          );
        },
        backgroundColor: const Color(0xFFFF7A21),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: petsAsyncValue.when(
        data: (pets) => _buildPetsList(context, pets),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF7A21)),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(petsProvider.notifier).refresh();
                  },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A21),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetsList(BuildContext context, List<Pet> pets) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total Hewan: ${pets.length}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pets.length,
              itemBuilder: (ctx, idx) => _buildPetCard(context, pets[idx]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, Pet pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade300,
              ),
              child: pet.imageUrl.isNotEmpty
                  ? Image.network(
                      pet.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.pets, color: Colors.grey),
                    )
                  : const Icon(Icons.pets, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${pet.breed} • ${pet.age} tahun',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: pet.status == 'available'
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      pet.status == 'available' ? 'Available' : 'Adopted',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: pet.status == 'available'
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdminPetForm(pet: pet),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    _showDeleteDialog(context, pet);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hapus Hewan?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${pet.name}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(petsProvider.notifier).deletePet(pet.id);
                if (!mounted) return;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${pet.name} berhasil dihapus',
                          style: GoogleFonts.poppins()),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e',
                          style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Hapus', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
