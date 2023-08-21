import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  // we need to provide the generic FormState to tell the
  // GlobalKey that this is of form data type
  final _formKey = GlobalKey<FormState>();

  String _newName = '';
  int _newQuantity = 1;
  Category _category = categories[Categories.carbs]!;

  bool _isSending = false;

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });
      // ! the second argument is the path to the first
      Uri url = Uri.https("flutter-backend-dummy-default-rtdb.firebaseio.com",
          'shopping-list.json');
      var result = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            "name": _newName,
            "quantity": _newQuantity,
            "category": _category.name,
          },
        ),
      );

      final Map<String, dynamic> resData = json.decode(result.body);

      // ! IMP we shouldn't use context across async as can be seen on hovering over
      // ! it. So we just check if its not mounted we return it without doing anything
      // ! This is the correct way and officially recommended way of using context
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
        id: resData['name'],
        name: _newName,
        quantity: _newQuantity,
        category: _category,
      ));

      // print(_newName +
      //     " " +
      //     _newQuantity.toString() +
      //     " " +
      //     _category.name.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add a new item"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  onSaved: (newValue) {
                    // this is redundant here and we should remove it
                    // but im letting this stay. its redundant because its getting validated
                    if (newValue == null) return;
                    _newName = newValue;
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.length <= 1 ||
                        value.length > 50) {
                      return 'Must be between 1 and 50 characters.';
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // wrapped with expanded since text form fill will try to take all available
                    // space and cause overflow possibly
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text("Quantity"),
                        ),
                        // also all values are shown as strings on the widget
                        initialValue: _newQuantity.toString(),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              // if tryparse is null that means the value is not a integer
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Must be a valid positive number.';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          if (newValue == null) return;
                          // new value can't be not integer
                          _newQuantity = int.parse(newValue);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        // This works and mine approach
                        // onSaved: (newValue) {
                        //   _category = newValue!;
                        // },
                        // validator: (value) {
                        //   if (value == null) return "Select a value";
                        //   return null;
                        // },
                        value: _category,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _category = value;
                          });
                        },
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              // ! IMP : if the value is not supplied it will throw an error
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.colordata,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.name),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _isSending
                            ? null
                            : () {
                                // ! For resetting we are automatically provided
                                // ! with the reset method
                                _formKey.currentState!.reset();
                              },
                        child: const Text("Reset")),
                    ElevatedButton(
                      onPressed: _isSending ? null : _saveForm,
                      child: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text("Add Item"),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
