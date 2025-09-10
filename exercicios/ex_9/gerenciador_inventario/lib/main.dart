import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'database/database_helper.dart';
import 'models/item.dart';
import 'tela_adicionar_editar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Inventário',
      theme: ThemeData(
        primaryColor: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: Colors.tealAccent,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: const CardThemeData(  // Corrigido de CardTheme para CardThemeData
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
      ),
      home: const ListaItensScreen(),
    );
  }
}

class ListaItensScreen extends StatefulWidget {
  const ListaItensScreen({super.key});

  @override
  _ListaItensScreenState createState() => _ListaItensScreenState();
}

class _ListaItensScreenState extends State<ListaItensScreen> {
  List<Item> _itens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  Future<void> _carregarItens() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Item> itens = await DatabaseHelper.instance.getItens();
      setState(() {
        _itens = itens;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar itens: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _atualizarQuantidade(Item item, bool incrementar) async {
    try {
      item.quantidade = incrementar ? item.quantidade + 1 : item.quantidade - 1;
      if (item.quantidade < 0) item.quantidade = 0; // Evita quantidades negativas
      await DatabaseHelper.instance.updateItem(item);
      _carregarItens();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar quantidade: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Inventário'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCircle(
                color: Colors.teal,
                size: 50.0,
              ),
            )
          : _itens.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum item no inventário.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _itens.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          _itens[index].nome,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Quantidade: ${_itens[index].quantidade} | Preço: R\$ ${_itens[index].preco.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.red),
                              onPressed: () => _atualizarQuantidade(_itens[index], false),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.teal),
                              onPressed: () => _atualizarQuantidade(_itens[index], true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdicionarEditarScreen(item: _itens[index]),
                                  ),
                                );
                                _carregarItens();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await DatabaseHelper.instance.deleteItem(_itens[index].id!);
                                _carregarItens();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdicionarEditarScreen()),
          );
          _carregarItens();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}