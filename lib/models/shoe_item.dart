class ShoeItem {
  String name;
  double price;
  double size;
  int quantity;
  String category;
  DateTime lastUpdated;

  ShoeItem({
    required this.name,
    required this.price,
    required this.size,
    required this.quantity,
    required this.category,
    required this.lastUpdated,
  });

  // Convert a ShoeItem instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'size': size,
      'quantity': quantity,
      'category': category,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Create a ShoeItem instance from a JSON map
  factory ShoeItem.fromJson(Map<String, dynamic> json) {
    return ShoeItem(
      name: json['name'],
      price: json['price'].toDouble(),
      size: json['size'].toDouble(),
      quantity: json['quantity'],
      category: json['category'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
