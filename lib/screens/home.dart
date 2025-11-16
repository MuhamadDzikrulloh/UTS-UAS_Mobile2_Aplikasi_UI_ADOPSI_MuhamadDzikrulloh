import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;
  late final PageController _pageController;
  double _currentPage = 0.0;

  // kategori pakai assets (use existing assets/images/ files)
  final categories = [
    {'label': 'Dog', 'image': 'assets/images/Dog.png'},
    {'label': 'Cat', 'image': 'assets/images/images3.png'},
    {'label': 'Rabbit', 'image': 'assets/images/rabbit.png'},
  ];

  // gambar kartu pakai assets
  final cardColors = [
    Colors.green.shade100,
    Colors.orange.shade200,
    Colors.yellow.shade200,
  ];

  final cardImages = [
    'assets/images/images2.png',
    'assets/images/images3.png',
    'assets/images/images4.png',
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Stack(
          children: [
            // HEADER
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
                      Text('Muhamad Dzikrulloh',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Spacer(),
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
                ],
              ),
            ),

            // SEARCH BAR
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
                        'Search',
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

            // KATEGORI
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

            // CARD CAROUSEL
            Positioned(
              top: 240,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 360,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: cardImages.length,
                  padEnds: false,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final delta = (_currentPage - index);
                    final scale = (1 - delta.abs() * 0.15).clamp(0.78, 1.0);
                    final rotation = delta * 0.06; // subtle rotation

                    return Transform.translate(
                      offset: Offset(delta * 30, 0),
                      child: Transform.rotate(
                        angle: rotation,
                        child: Center(
                          child: Transform.scale(
                            scale: scale,
                            child: _animalCard(
                              imageUrl: cardImages[index],
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

            // BOTTOM NAV
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
                    _navItem(icon: Icons.home, active: true),
                    _navItem(icon: Icons.chat_bubble_outline, active: false),
                    _navItem(icon: Icons.favorite_border, active: false),
                    _navItem(icon: Icons.person_outline, active: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animalCard({
    required String imageUrl,
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
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
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
                        image: imageUrl,
                        name: 'Charlie',
                        age: '2',
                        weight: '4.5',
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

  Widget _navItem({required IconData icon, required bool active}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFF7A21) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
