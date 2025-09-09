import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 255, 255, 255)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: ListaComprasScreen(),
    );
  }
}

class ListaComprasScreen extends StatefulWidget {
  @override
  _ListaComprasScreenState createState() => _ListaComprasScreenState();
}

class _ListaComprasScreenState extends State<ListaComprasScreen> {
  final _itemController = TextEditingController();
  List<Map<String, dynamic>> _itens = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/compras.json');
  }

  Future<void> _carregarItens() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);
        setState(() {
          _itens = jsonData.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      setState(() {
        _itens = [];
      });
    }
  }

  Future<void> _salvarItens() async {
    final file = await _localFile;
    await file.writeAsString(json.encode(_itens));
  }

  void _adicionarItem() {
    if (_itemController.text.isNotEmpty) {
      setState(() {
        _itens.add({
          'nome': _itemController.text,
          'comprado': false,
        });
      });
      _salvarItens();
      _itemController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item adicionado!'),
          backgroundColor: Colors.teal,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digite o nome do item!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _marcarComprado(int index) {
    setState(() {
      _itens[index]['comprado'] = !_itens[index]['comprado'];
    });
    _salvarItens();
  }

  void _excluirItem(int index) {
    setState(() {
      _itens.removeAt(index);
    });
    _salvarItens();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item excluído!'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Compras',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _itemController,
                    decoration: InputDecoration(
                      labelText: 'Adicionar Item',
                      prefixIcon: Icon(Icons.add_shopping_cart, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Adicionar'),
                      onPressed: _adicionarItem,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Itens da Lista',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _itens.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum item na lista.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _itens.length,
                      itemBuilder: (context, index) {
                        final item = _itens[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal[100],
                              child: Icon(
                                item['comprado']
                                    ? Icons.check_circle
                                    : Icons.shopping_cart,
                                color: Colors.teal,
                              ),
                            ),
                            title: Text(
                              item['nome'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: item['comprado']
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _excluirItem(index),
                            ),
                            onTap: () => _marcarComprado(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}