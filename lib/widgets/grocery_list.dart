import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  void _addNewItem() async {
    // if await is not added we will get errors below
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const NewItem();
      },
    ));

    if (result == null) return;
    setState(() {
      _groceryItems.add(result);
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
