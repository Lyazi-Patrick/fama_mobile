class Outlet {
  final int id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? contact;

  Outlet({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.contact,
  });

  factory Outlet.fromJson(Map<String, dynamic> json) => Outlet(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'],
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        contact: json['contact'],
      );
}

class Product {
  final int id;
  final int outletId;
  final String name;
  final String? description;
  final double price;
  final String? imagePath;
  final String status;

  Product({
    required this.id,
    required this.outletId,
    required this.name,
    this.description,
    required this.price,
    this.imagePath,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        outletId: json['outlet_id'],
        name: json['name'] ?? '',
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        imagePath: json['image_path'],
        status: json['status'] ?? 'pending',
      );
}
