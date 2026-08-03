import '../core/utils/parsing.dart';

class Outlet {
  final int id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? contact;
  final String? email;
  final List<String> tags;
  final List<Product> products;

  Outlet({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.contact,
    this.email,
    this.tags = const [],
    this.products = const [],
  });

  factory Outlet.fromJson(Map<String, dynamic> json) => Outlet(
        id: asInt(json['id']),
        name: json['name'] ?? '',
        description: json['description'],
        latitude: asDouble(json['latitude']),
        longitude: asDouble(json['longitude']),
        contact: json['contact'],
        email: json['email'],
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((t) => t['name'].toString())
            .toList(),
        products: (json['products'] as List<dynamic>? ?? [])
            .map((p) => Product.fromJson(p))
            .toList(),
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
  final List<String> tags;
  final Outlet? outlet;

  Product({
    required this.id,
    required this.outletId,
    required this.name,
    this.description,
    required this.price,
    this.imagePath,
    required this.status,
    this.tags = const [],
    this.outlet,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: asInt(json['id']),
        outletId: asInt(json['outlet_id']),
        name: json['name'] ?? '',
        description: json['description'],
        price: asDouble(json['price']),
        imagePath: json['image_path'],
        status: json['status'] ?? 'pending',
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((t) => t['name'].toString())
            .toList(),
        // Guard against infinite recursion: outlet's own nested 'products'
        // (if present) is dropped here since we never need product->outlet->products.
        outlet: json['outlet'] != null
            ? Outlet.fromJson({...json['outlet'] as Map<String, dynamic>, 'products': []})
            : null,
      );
}
