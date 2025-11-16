import 'package:flutter_riverpod/flutter_riverpod.dart';

class Pet {
  final int id;
  final String name;
  final String category;
  final String imageUrl;
  final String about;
  final int ageYears;
  final double weightKg;

  Pet({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.about,
    required this.ageYears,
    required this.weightKg,
  });
}

final samplePetsProvider = Provider<List<Pet>>((ref) {
  return [
    Pet(
      id: 1,
      name: 'Charlie',
      category: 'Dog',
      imageUrl: 'assets/images/pet_1.png',
      about:
          'Charlie is fully vaccinated, friendly with people and other pets. Knows basic commands and loves cuddles.',
      ageYears: 2,
      weightKg: 4.5,
    ),
    Pet(
      id: 2,
      name: 'Luna',
      category: 'Cat',
      imageUrl: 'assets/images/pet_2.png',
      about:
          'Luna is curious and playful. She enjoys window naps and feather toys.',
      ageYears: 1,
      weightKg: 3.2,
    ),
    Pet(
      id: 3,
      name: 'Bella',
      category: 'Dog',
      imageUrl: 'assets/images/pet_3.png',
      about: 'Bella is calm, house-trained, and great with kids.',
      ageYears: 3,
      weightKg: 10.0,
    ),
  ];
});

class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier() : super(<int>{});

  void toggle(int id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state}..add(id);
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>(
  (ref) => FavoritesNotifier(),
);

final selectedPetProvider = StateProvider<Pet?>((ref) => null);
