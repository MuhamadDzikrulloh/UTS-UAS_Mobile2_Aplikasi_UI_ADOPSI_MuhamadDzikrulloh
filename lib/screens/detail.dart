import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_provider.dart';

class PetDetailPage extends ConsumerStatefulWidget {
  final String image;
  final String name;
  final String age;
  final String weight;
  final String about;
  final int? petId;

  const PetDetailPage({
    super.key,
    this.image = 'https://i.imgur.com/7Qp5xFQ.png',
    this.name = 'Charlie',
    this.age = '2',
    this.weight = '4.5',
    this.about =
        'Charlie is fully vaccinated, friendly, and very playful. He loves people and learns commands quickly.',
    this.petId,
  });

  @override
  ConsumerState<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends ConsumerState<PetDetailPage> {
  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = widget.petId != null && favorites.contains(widget.petId!);

    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
              size: 28,
            ),
            onPressed: () {
              if (widget.petId != null) {
                ref.read(favoritesProvider.notifier).toggle(widget.petId!);
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // IMAGE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: widget.image.startsWith('assets/')
                ? Image.asset(widget.image, height: 230, fit: BoxFit.contain)
                : Image.network(widget.image, height: 230, fit: BoxFit.contain),
          ),

          const SizedBox(height: 10),

          // WHITE CONTAINER
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // AGE + WEIGHT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildInfoCard(
                          icon: Icons.pets,
                          label: "Age",
                          value: widget.age,
                          unit: "Years",
                        ),
                        buildInfoCard(
                          icon: Icons.monitor_weight,
                          label: "Weight",
                          value: widget.weight,
                          unit: "Kg",
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      widget.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "About",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      widget.about,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),

                    const SizedBox(height: 30),

                    // BOTTOM BUTTON
                    GestureDetector(
                      onTap: () async {
                        if (widget.petId != null) {
                          try {
                            await ref.read(petsProvider.notifier).adoptPet(widget.petId!);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Adopsi berhasil')), 
                            );
                            Navigator.of(context).pop();
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal adopsi: $e')),
                            );
                          }
                        }
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text(
                            "Adoption",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

  // CARD WIDGET
  Widget buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(158, 158, 158, 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

