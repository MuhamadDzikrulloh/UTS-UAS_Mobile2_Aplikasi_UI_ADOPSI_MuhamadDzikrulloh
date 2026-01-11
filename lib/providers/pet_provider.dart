import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../services/pet_service.dart';

final petServiceProvider = Provider<PetService>((ref) {
  return PetService();
});

class PetsNotifier extends AsyncNotifier<List<Pet>> {
  @override
  Future<List<Pet>> build() async {
    return await _fetchPets();
  }

  Future<List<Pet>> _fetchPets() async {
    final service = ref.read(petServiceProvider);
    return await service.getAllPets();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPets());
  }

  Future<void> filterByBreed(String breed) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(petServiceProvider);
      return await service.getPetsByBreed(breed);
    });
  }

  Future<void> searchPets(String query) async {
    if (query.isEmpty) {
      await refresh();
      return;
    }
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(petServiceProvider);
      return await service.searchPets(query);
    });
  }

  Future<void> createPet(Pet pet) async {
    final service = ref.read(petServiceProvider);
    await service.createPet(pet);
    await refresh();
  }

  Future<void> updatePet(int id, Pet pet) async {
    final service = ref.read(petServiceProvider);
    await service.updatePet(id, pet);
    await refresh();
  }

  Future<void> deletePet(int id) async {
    final service = ref.read(petServiceProvider);
    await service.deletePet(id);
    await refresh();
  }

  Future<void> adoptPet(int id) async {
    final service = ref.read(petServiceProvider);
    await service.adoptPet(id);
    await refresh();
  }
}

final petsProvider = AsyncNotifierProvider<PetsNotifier, List<Pet>>(() {
  return PetsNotifier();
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
