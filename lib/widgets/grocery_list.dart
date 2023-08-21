import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    super.initState();
    _LoadItems();
  }

  void _LoadItems() async {
    final url = Uri.https("flutter-backend-dummy-default-rtdb.firebaseio.com",
        'shopping-list.json');
    final response = await http.get(url);
    // ! json encode decode method from dart:convert package
    final parsedJSON = json.decode(response.body);
    final Map<String, dynamic> listData = parsedJSON;

    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final Category categoryFound = categories.entries
          .firstWhere((element) => element.value.name == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: categoryFound));
    }

    setState(() {
      _groceryItems = loadedItems;
    });
  }

  void _addNewItem() async {
    // if await is not added we will get errors below
    // ! We are adding await now to make sure that we await the future which we get
    // ! after the new item has been added.
    final newItem = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const NewItem();
      },
    ));

    if (newItem == null) return;
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_groceryItems.isEmpty) {
      content = const Center(
        child: Text("No data found"),
      );
    } else {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_groceryItems[index].id),
            onDismissed: (direction) {
              setState(() {
                _groceryItems.remove(_groceryItems[index]);

                // _groceryItems = _groceryItems
                //     .where((element) => element.id != _groceryItems[index].id)
                //     .toList();
              });
            },
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItems[index].category.colordata,
              ),
              trailing: Text(_groceryItems[index].quantity.toString()),
            ),
          );
        },
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your grocery list"),
          centerTitle: false,
          actions: [
            IconButton(onPressed: _addNewItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
