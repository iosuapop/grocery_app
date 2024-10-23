import 'dart:convert';

import 'package:flutter/material.dart';

//import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:http/http.dart';

import 'package:http_requests/data/categories.dart';

import 'package:http_requests/models/grocery_item.dart';
import 'package:http_requests/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  var _isLoading = true;
  // late Future<List<GroceryItem>> _loadedItems;
  String? _error;
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    // _loadedItems =
    _loadItems();
  }

  // Future<List<GroceryItem>>
  void _loadItems() async {
    // final url = Uri.https(
    //     'flutter-prep-194d7-default-rtdb.firebaseio.com', 'shopping-list.json');

    const url ='https://flutter-prep-194d7-default-rtdb.firebaseio.com/shopping-list.json';

    try {
      final response = await dio.get(url);

      if (response.statusCode! >= 400) {
        // throw Exception('Failed to fetch data. Please try again later.');
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }
      if (response.data == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
        // [];
      }
      final Map<String, dynamic> listData = response.data;
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    setState(() {
      _groceryItems.remove(item);
    });

    // final url = Uri.https('flutter-prep-194d7-default-rtdb.firebaseio.com',
    //     'shopping-list/${item.id}.json');

    final url =
        'https://flutter-prep-194d7-default-rtdb.firebaseio.com/shopping-list/${item.id}.json';

    try {
      final response = await dio.delete(url);

      if (response.statusCode! >= 400) {
        setState(() {
          _groceryItems.add(item);
        });
      }
    } catch (error) {
      setState(() {
        _groceryItems.add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
      // FutureBuilder(
      //     future: _loadedItems,
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return const Center(
      //           child: CircularProgressIndicator(),
      //         );
      //       }
      //       if (snapshot.hasError) {
      //         return Center(
      //           child: Text(snapshot.error.toString()),
      //         );
      //       }

      //       if (snapshot.data!.isEmpty) {
      //         print('e gol');
      //         const Center(child: Text('No items added yet.'));
      //       }
      //       return ListView.builder(
      //         itemCount: snapshot.data!.length,
      //         itemBuilder: (ctx, index) => Dismissible(
      //           onDismissed: (direction) {
      //             _removeItem(_groceryItems[index]);
      //           },
      //           key: ValueKey(_groceryItems[index].id),
      //           child: ListTile(
      //             title: Text(_groceryItems[index].name),
      //             leading: Container(
      //               width: 24,
      //               height: 24,
      //               color: _groceryItems[index].category.color,
      //             ),
      //             trailing: Text(
      //               _groceryItems[index].quantity.toString(),
      //             ),
      //           ),
      //         ),
      //       );
      //     }),
    );
  }
}
