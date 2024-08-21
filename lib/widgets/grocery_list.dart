import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shop_kepper_app/data/categories.dart';
import 'package:shop_kepper_app/models/grocery_item.dart';
import 'package:shop_kepper_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceriesList extends StatefulWidget {
  const GroceriesList({super.key});

  @override
  State<GroceriesList> createState() => _GroceriesListState();
}

class _GroceriesListState extends State<GroceriesList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoadign=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https(
        'flut-bc2bd-default-rtdb.firebaseio.com',
        'AbdelahForm-app.json'); 
    final response = await http.get(url);
    if(response.body=='null'){
      _isLoadign=false;
    }
          
    final Map<String, dynamic> Listdata = json.decode(response.body);
    print(response.body);
    final List<GroceryItem> _LoadedItem = [];
    
     
    for (final item in Listdata.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value["category"])
          .value;

      _LoadedItem.add(GroceryItem(
          id: item.key,
          name: item.value[" name"  ],
          quantity: item.value["quantity"],
          category: category),);
           print(item.value[" name"]);
          


    
      
     setState(() {
         _groceryItems = _LoadedItem.map((i) => i).toList();
         _isLoadign=false;
           });
    }
    
    
    
    
  }
   


  void _addItem() async {
    final newItem=  await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const NewItem()));
    if(newItem==null){
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });

  }

  @override
  Widget build(BuildContext context) {

    void removed(GroceryItem item) async {
      final index = _groceryItems.indexOf(item);
      final url = Uri.https(
          'flut-bc2bd-default-rtdb.firebaseio.com',
        'AbdelahForm-app/${item.id}.json');
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        _groceryItems.insert(index, item);
      }
      setState(() {
        _groceryItems.remove(item);
      });
    }

    Widget content = const Center(
      child: Text(
        'There is No grocery Item Pleace \n Add By Using the above Plus button',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if(_isLoadign){
      content=const Center(child: CircularProgressIndicator(),);
      
    }




    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(_groceryItems[index].id),
                onDismissed: (direction) {
                  removed(_groceryItems[index]);
                },
                child: ListTile(
                  title: Text(_groceryItems[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _groceryItems[index].category.color,
                  ),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
              ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Grouseries'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
          ],
        ),
        body: content);
  }
}
