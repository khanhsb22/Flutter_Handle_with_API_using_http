import 'dart:convert';

import 'package:flutter_app/product.dart';
import 'package:http/http.dart' as http;

class ProductAPI {
  static final String URL = "https://fakestoreapi.com/";

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(URL + "products"));
    // Method GET response.statusCode == 200
    if (response.statusCode == 200) {
      return parseProducts(response.body);
    } else {
      throw Exception("Failed to load all product !");
    }
  }

  List<Product> parseProducts(String responseBody) {
    /*
    decode là giải mã chuỗi json từ response
    encode là mã hóa json đưa lên server
   */
    // Giải mã chuỗi json từ response thành một đối tượng
    // Sau đó map chuỗi json đó để chuyển nó thành một list
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Product>((json) => Product.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> updateProduct(String id, String title, String price,
      String description, String image, String category) async {

    final response = await http.put(
      Uri.parse(URL + "products" + "/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Mã hóa chuỗi json từ đối tượng Product
      body: jsonEncode(<String, String>{
        'title': title,
        'price': price,
        'description': description,
        'image': image,
        'category': category
      }),
    );

    if (response.statusCode == 200) {
      Map<String,dynamic> map = json.decode(response.body);
      return map;
    } else {
      throw Exception('Failed to update product.');
    }
  }

  Future<http.Response> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse(URL + "products" + "/$id"));
    return response;
  }

  Future<Product> addNewProduct(String title, num price, String description,
      String image, String category) async {

    final response = await http.post(
      Uri.parse(URL + "products"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Mã hóa chuỗi json từ đối tượng Product
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'price': price,
        'description': description,
        'image': image,
        'category': category
      }),
    );

    // Method POST response.statusCode == 200 or 201 depending on api
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      // Giải mã chuỗi json từ response và đưa nó vào các parameter trong model
      return Product.fromJson(jsonDecode(response.body));
      //return "Success";
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create product.');
    }
  }
}
