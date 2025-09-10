import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/projeto.dart';
import 'tela_adicionar_editar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Projetos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ListaProjetosScreen(),
    );
  }
}

class ListaProjetosScreen extends StatefulWidget {
  const ListaProjetosScreen({super.key});

  @override
  _ListaProjetosScreenState createState() => _ListaProjetosScreenState();
}

class _ListaProjetosScreenState extends State<ListaProjetosScreen> {
  List<Projeto> _projetos = [];
  String _filtroStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    _carregarProjetos();
  }

  Future<void> _carregarProjetos() async {
    List<Projeto> projetos = await DatabaseHelper.instance.getProjetos(statusFiltro: _filtroStatus);
    setState(() {
      _projetos = projetos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Projetos'),
        actions: [
          DropdownButton<String>(
            value: _filtroStatus,
            items: ['Todos', 'Em andamento', 'Concluído'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _filtroStatus = newValue!;
                _carregarProjetos();
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _projetos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_projetos[index].nome),
            subtitle: Text('${_projetos[index].descricao} - Status: ${_projetos[index].status}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdicionarEditarScreen(projeto: _projetos[index]),
                      ),
                    );
                    _carregarProjetos();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await DatabaseHelper.instance.deleteProjeto(_projetos[index].id!);
                    _carregarProjetos();
                  },
                ),
              ],
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
          _carregarProjetos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}