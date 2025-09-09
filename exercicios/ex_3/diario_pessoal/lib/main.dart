import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      title: 'Diário Pessoal',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[800]),
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
      home: DiarioScreen(),
    );
  }
}

class DiarioScreen extends StatefulWidget {
  @override
  _DiarioScreenState createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();
  final _buscaController = TextEditingController();
  List<Map<String, dynamic>> _entradas = [];
  List<Map<String, dynamic>> _entradasFiltradas = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/diario.json');
  }

  Future<void> _carregarEntradas() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);
        setState(() {
          _entradas = jsonData.map((e) => e as Map<String, dynamic>).toList();
          _entradasFiltradas = _entradas;
        });
      }
    } catch (e) {
      setState(() {
        _entradas = [];
        _entradasFiltradas = [];
      });
    }
  }

  Future<void> _salvarEntradas() async {
    final file = await _localFile;
    await file.writeAsString(json.encode(_entradas));
  }

  void _adicionarEntrada() {
    if (_tituloController.text.isNotEmpty && _conteudoController.text.isNotEmpty) {
      final entrada = {
        'titulo': _tituloController.text,
        'conteudo': _conteudoController.text,
        'data': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      };
      setState(() {
        _entradas.add(entrada);
        _entradasFiltradas = _entradas;
      });
      _salvarEntradas();
      _tituloController.clear();
      _conteudoController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entrada salva!'),
          backgroundColor: Colors.teal,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha título e conteúdo!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _buscarEntradas(String query) {
    setState(() {
      _entradasFiltradas = _entradas
          .where((entrada) =>
              entrada['titulo'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarEntradas();
    _buscaController.addListener(() {
      _buscarEntradas(_buscaController.text);
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Diário Pessoal',
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
                    controller: _tituloController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _conteudoController,
                    decoration: InputDecoration(
                      labelText: 'Conteúdo',
                      prefixIcon: Icon(Icons.description, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Salvar Entrada'),
                      onPressed: _adicionarEntrada,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                labelText: 'Buscar por título',
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Entradas do Diário',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _entradasFiltradas.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma entrada encontrada.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _entradasFiltradas.length,
                      itemBuilder: (context, index) {
                        final entrada = _entradasFiltradas[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal[100],
                              child: Icon(Icons.book, color: Colors.teal),
                            ),
                            title: Text(
                              entrada['titulo'],
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${entrada['data']}\n${entrada['conteudo']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
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