class Pet {
  final int id;
  final String name;
  final String breed;
  final int age;
  final String description;
  final String imageUrl;
  final String status;
  final DateTime? createdAt;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.description,
    required this.imageUrl,
      this.status = 'available',
    this.createdAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    return Pet(
      id: toInt(json['id']),
      name: json['name'] as String,
      breed: json['breed'] as String,
      age: toInt(json['age']),
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
        status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'breed': breed,
      'age': age,
      'description': description,
      'image_url': imageUrl,
      'status': status,
    };
  }

  Pet copyWith({
    int? id,
    String? name,
    String? breed,
    int? age,
    String? description,
    String? imageUrl,
      String? status,
    DateTime? createdAt,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
        status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Pet(id: $id, name: $name, breed: $breed, age: $age)';
  }
}
