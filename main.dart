import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/product.dart';
import 'package:flutter_app/product_api.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
      title: "My App",
      home: MyApp(
        products: ProductAPI().fetchProducts(),
      )));
}

/*
* GET all product steps:
* 1. Create a model class
* 2. Perform get data through product_api.dart
* 3. Dump data into view
* */

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.products}) : super(key: key);

  final Future<List<Product>> products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Product page"),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    Product value = await addNewProduct();
                    // Response id is "21"
                    print(value.id.toString() +
                        "\n" +
                        value.title.toString() +
                        "\n" +
                        value.price.toString() +
                        "\n" +
                        value.description.toString() +
                        "\n" +
                        value.image +
                        "\n" +
                        value.category);
                  },
                  child: Text(
                    "Add",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: FutureBuilder<List<Product>>(
          future: products,
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData
                ? ProductList(items: snapshot.data!)
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<Product> addNewProduct() async {
    Product value = await ProductAPI().addNewProduct("test product", 13.5,
        "lorem ipsum set", "https://i.pravatar.cc", "electronic");
    return value;
  }

}

// build ListView
class ProductList extends StatelessWidget {
  final List<Product> items;

  ProductList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
              // shrinkWrap attribute is required when adding listview to Column
              shrinkWrap: true,
              // This attribute additional for SingleChildScrollView
              physics: ScrollPhysics(parent: null),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ProductItem(items[index]);
              }),
        ],
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product item;
  Offset? _tapDownPosition;
  int id = -1;

  ProductItem(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.0),
      height: 150,
      child: Card(
        elevation: 5,
        child: GestureDetector(
          onTapDown: (TapDownDetails details) {
            _tapDownPosition = details.globalPosition;
          },
          onLongPress: () {
            final RenderBox box = context.findRenderObject() as RenderBox;
            id = this.item.id; // Get id when LongPress
            showMenu(
                context: context,
                // Get position of PopupMenu from current cursor position
                position: RelativeRect.fromLTRB(
                  _tapDownPosition!.dx,
                  _tapDownPosition!.dy,
                  box.size.width - _tapDownPosition!.dx,
                  box.size.height - _tapDownPosition!.dy,
                ),
                items: [
                  PopupMenuItem<String>(
                      value: 'update',
                      // type of value is type of PopupMenuButton and PopupMenuItem
                      child: Row(
                        children: [Icon(Icons.update), Text("Update")],
                      )),
                  PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [Icon(Icons.delete), Text("Delete")],
                      )),
                ]).then((value) async => {
                  // Set check event in PopupMenuItem
                  if (value == "update")
                    {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => _showUpdateDialog(
                              context,
                              id,
                              this.item.title,
                              this.item.price.toString(),
                              this.item.description,
                              this.item.category,
                              this.item.image))
                    }
                  else
                    {
                      deleteProduct() // Return json
                    }
                });
          },
          child: Row(
            children: [
              Image.network(
                this.item.image,
                width: 100,
                height: 100,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(this.item.title,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Price: ${this.item.price}"),
                        Text("description: ${this.item.description}"),
                        Text("category: ${this.item.category}"),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteProduct() async {
    http.Response response = await ProductAPI().deleteProduct(id);
    if (response.statusCode == 200) {
      print(response.body.toString());
    } else if (response == null) {
      print("Error: No connection internet !");
    } else {
      print("Error is not define !");
    }
  }
}

Widget _showUpdateDialog(BuildContext context, int id, String title,
    String price, String desc, String category, String image) {
  var _title = TextEditingController(text: title);
  var _price = TextEditingController(text: price);
  var _description = TextEditingController(text: desc);
  var _category = TextEditingController(text: category);
  var _image = TextEditingController(text: image);

  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    child: Container(
      height: 500,
      width: 400,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Id: $id",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _title,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Title'),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _price,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Price'),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _description,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Description'),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _category,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Category'),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _image,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Image'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () async {
                        // Update product
                        Map<String, dynamic> data = await ProductAPI().updateProduct(id.toString(), _title.text,
                            _price.text, _description.text, _image.text, _category.text);
                        print(data["title"]);
                        print(data["price"]);
                        print(data["description"]);
                        print(data["image"]);
                        print(data["category"]);
                      },
                      child: Text("Update",
                          style: TextStyle(
                              color: Colors.blueAccent, fontSize: 18.0))),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel",
                          style:
                              TextStyle(color: Colors.green, fontSize: 18.0)))
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}
