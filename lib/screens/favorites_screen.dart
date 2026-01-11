import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pet_provider.dart';
import '../models/pet_model.dart';
import 'detail.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsProvider);
    final favIds = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Favorit'),
        backgroundColor: const Color(0xFFFF7A21),
        foregroundColor: Colors.white,
      ),
      body: petsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A21))),
        error: (e, st) => Center(child: Text('Gagal memuat: $e')),
        data: (pets) {
          final favPets = pets.where((p) => favIds.contains(p.id)).toList();
          if (favPets.isEmpty) {
            return Center(
              child: Text(
                'Belum ada favorit',
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favPets.length,
            itemBuilder: (ctx, i) => _favoriteCard(context, favPets[i]),
          );
        },
      ),
    );
  }

  Widget _favoriteCard(BuildContext context, Pet pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: pet.imageUrl.startsWith('http')
              ? Image.network(pet.imageUrl, width: 56, height: 56, fit: BoxFit.cover)
              : Image.asset(pet.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
        ),
        title: Text(pet.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text('${pet.breed} • ${pet.age} tahun', style: GoogleFonts.poppins(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PetDetailPage(
              image: pet.imageUrl,
              name: pet.name,
              age: pet.age.toString(),
              weight: '${pet.age * 3}',
              petId: pet.id,
              about: pet.description,
            ),
          ));
        },
      ),
    );
  }
}
