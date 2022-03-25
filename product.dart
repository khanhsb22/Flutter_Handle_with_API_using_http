class Product {
  int id;
  String title;
  num price;
  String description;
  String category;
  String image; // imageURL

  // required keyword is used in return Product() method bellow
  Product({required this.id, required this.title, required this.price, required this.description,
    required this.category, required this.image});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      description: json['description'],
      category: json['category'],
      image: json['image']
    );
  }


}