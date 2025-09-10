import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/tarefa.dart';
import 'tela_adicionar_editar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ListaTarefasScreen(),
    );
  }
}

class ListaTarefasScreen extends StatefulWidget {
  const ListaTarefasScreen({super.key});

  @override
  _ListaTarefasScreenState createState() => _ListaTarefasScreenState();
}

class _ListaTarefasScreenState extends State<ListaTarefasScreen> {
  List<Tarefa> _tarefas = [];

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    List<Tarefa> tarefas = await DatabaseHelper.instance.getTarefas();
    setState(() {
      _tarefas = tarefas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
      ),
      body: ListView.builder(
        itemCount: _tarefas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_tarefas[index].titulo),
            subtitle: Text('Prioridade: ${_tarefas[index].prioridade}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdicionarEditarScreen(tarefa: _tarefas[index]),
                      ),
                    );
                    _carregarTarefas();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await DatabaseHelper.instance.deleteTarefa(_tarefas[index].id!);
                    _carregarTarefas();
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
          _carregarTarefas();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}