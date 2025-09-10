import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Senhas',
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
      home: SenhaScreen(),
    );
  }
}

class SenhaScreen extends StatefulWidget {
  @override
  _SenhaScreenState createState() => _SenhaScreenState();
}

class _SenhaScreenState extends State<SenhaScreen> {
  final _servicoController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  List<Map<String, dynamic>> _senhas = [];
  Database? _database;

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final pathDb = path.join(dbPath, 'senhas.db');
    _database = await openDatabase(
      pathDb,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE senhas (id INTEGER PRIMARY KEY AUTOINCREMENT, servico TEXT, usuario TEXT, senha TEXT)',
        );
      },
    );
    _carregarSenhas();
  }

  Future<void> _carregarSenhas() async {
    final List<Map<String, dynamic>> senhas = await _database!.query('senhas');
    setState(() {
      _senhas = senhas;
    });
  }

  Future<void> _adicionarSenha() async {
    if (_servicoController.text.isNotEmpty &&
        _usuarioController.text.isNotEmpty &&
        _senhaController.text.isNotEmpty) {
      await _database!.insert(
        'senhas',
        {
          'servico': _servicoController.text,
          'usuario': _usuarioController.text,
          'senha': _senhaController.text,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _servicoController.clear();
      _usuarioController.clear();
      _senhaController.clear();
      _carregarSenhas();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Senha salva!'),
          backgroundColor: Colors.teal,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  @override
  void dispose() {
    _servicoController.dispose();
    _usuarioController.dispose();
    _senhaController.dispose();
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gerenciador de Senhas',
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
                    controller: _servicoController,
                    decoration: InputDecoration(
                      labelText: 'Nome do Serviço',
                      prefixIcon: Icon(Icons.web, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _usuarioController,
                    decoration: InputDecoration(
                      labelText: 'Nome de Usuário',
                      prefixIcon: Icon(Icons.person, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _senhaController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Salvar Senha'),
                      onPressed: _adicionarSenha,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Senhas Cadastradas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _senhas.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma senha cadastrada.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _senhas.length,
                      itemBuilder: (context, index) {
                        final senha = _senhas[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal[100],
                              child: Icon(Icons.lock, color: Colors.teal),
                            ),
                            title: Text(
                              senha['servico'],
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Usuário: ${senha['usuario']}\nSenha: ${senha['senha']}',
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