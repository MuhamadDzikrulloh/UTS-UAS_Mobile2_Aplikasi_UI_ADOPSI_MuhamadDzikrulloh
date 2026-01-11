import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pet_provider.dart';
import '../providers/auth_provider.dart';
import '../models/pet_model.dart';
import 'detail.dart';
import 'admin_dashboard.dart';
import 'chat_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectedCategory = 0;
  late final PageController _pageController;
  double _currentPage = 0.0;

  final categories = [
    {'label': 'Dog', 'image': 'assets/images/Dog.png'},
    {'label': 'Cat', 'image': 'assets/images/images3.png'},
    {'label': 'Rabbit', 'image': 'assets/images/rabbit.png'},
  ];

  final cardColors = [
    Colors.green.shade100,
    Colors.orange.shade200,
    Colors.yellow.shade200,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.72, initialPage: 1);
    _currentPage = _pageController.initialPage.toDouble();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? _currentPage;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final petsAsyncValue = ref.watch(petsProvider);

    if (auth.role == 'admin') {
      return const AdminDashboard();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: petsAsyncValue.when(
          data: (pets) => _buildContent(context, pets),
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF7A21),
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat data',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(petsProvider.notifier).refresh();
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Pet> pets) {
    final auth = ref.watch(authProvider);
    final selectedLabel = categories[selectedCategory]['label']!;
    final displayPets = _filterByCategory(pets, selectedLabel);
    
    return Stack(
          children: [
            Positioned(
              top: 14,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning!',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey.shade600)),
                      Text(auth.email ?? 'User',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.08),
                                blurRadius: 6)
                          ],
                        ),
                        child: const Icon(Icons.notifications_none,
                            color: Colors.black87),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.08),
                                blurRadius: 6)
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout, color: Colors.black87),
                          tooltip: 'Logout',
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            await ref.read(authProvider.notifier).logout();
                            if (!mounted) return;
                            navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.03),
                        blurRadius: 8)
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search pets',
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade500, fontSize: 15),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.02),
                              blurRadius: 4)
                        ],
                      ),
                      child: const Icon(Icons.tune, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 78,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedCategory = index);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF7A21)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, isSelected ? 0.06 : 0.02),
                                blurRadius: isSelected ? 8 : 6)
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade200,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  categories[index]['image']!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              categories[index]['label']!,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Positioned(
              top: 240,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 360,
                child: pets.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada data pet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : PageView.builder(
                  controller: _pageController,
                  itemCount: displayPets.length,
                  padEnds: false,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final pet = displayPets[index];
                    final delta = (_currentPage - index);
                    final scale = (1 - delta.abs() * 0.15).clamp(0.78, 1.0);
                    final rotation = delta * 0.06;

                    return Transform.translate(
                      offset: Offset(delta * 30, 0),
                      child: Transform.rotate(
                        angle: rotation,
                        child: Center(
                          child: Transform.scale(
                            scale: scale,
                            child: _animalCard(
                              pet: pet,
                              color: cardColors[index % cardColors.length],
                              size: const Size(280, 320),
                              isFront: (index - _currentPage).abs() < 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Positioned(
              left: 24,
              right: 24,
              bottom: 18,
              child: Container(
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.12),
                        blurRadius: 12)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navItem(icon: Icons.home, active: true, onTap: () {}),
                    _navItem(
                      icon: Icons.chat_bubble_outline,
                      active: false,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        );
                      },
                    ),
                    _navItem(
                      icon: Icons.favorite_border,
                      active: false,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        );
                      },
                    ),
                    _navItem(
                      icon: Icons.person_outline,
                      active: false,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
  }

  List<Pet> _filterByCategory(List<Pet> pets, String category) {
    if (category.isEmpty) return pets;
    final c = category.toLowerCase();
    return pets.where((p) {
      final b = (p.breed ?? '').toLowerCase();
      if (c == 'dog') {
        return b.contains('dog') ||
            b.contains('husky') ||
            b.contains('retriever') ||
            b.contains('beagle') ||
            b.contains('poodle') ||
            b.contains('bulldog');
      } else if (c == 'cat') {
        return b.contains('cat') ||
            b.contains('tabby') ||
            b.contains('persian') ||
            b.contains('siam') ||
            b.contains('ragdoll');
      } else if (c == 'rabbit') {
        return b.contains('rabbit') || b.contains('bunny') || b.contains('lop');
      }
      return true;
    }).toList();
  }

  Widget _animalCard({
    required Pet pet,
    required Color color,
    required Size size,
    required bool isFront,
  }) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, isFront ? 0.18 : 0.08),
              blurRadius: isFront ? 18 : 12,
              offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: pet.imageUrl.startsWith('http')
                  ? Image.network(
                      pet.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFFFF7A21),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.pets,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      pet.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.pets,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Positioned(
              bottom: 50,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pet.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.pets, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          pet.breed,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.cake, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${pet.age} tahun',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isFront)
              Positioned(
                bottom: 14,
                right: 14,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PetDetailPage(
                        image: pet.imageUrl,
                        name: pet.name,
                        age: pet.age.toString(),
                        weight: '${pet.age * 3}',
                        petId: pet.id,
                      ),
                    ));
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.08), blurRadius: 6, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.black87),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required bool active, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF7A21) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
