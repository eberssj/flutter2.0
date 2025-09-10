import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/tarefa.dart';

class AdicionarEditarScreen extends StatefulWidget {
  final Tarefa? tarefa;

  const AdicionarEditarScreen({super.key, this.tarefa});

  @override
  _AdicionarEditarScreenState createState() => _AdicionarEditarScreenState();
}

class _AdicionarEditarScreenState extends State<AdicionarEditarScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  String _prioridade = 'Média';

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.tarefa?.titulo ?? '');
    _prioridade = widget.tarefa?.prioridade ?? 'Média';
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _salvarTarefa() async {
    if (_formKey.currentState!.validate()) {
      Tarefa tarefa = Tarefa(
        id: widget.tarefa?.id,
        titulo: _tituloController.text,
        prioridade: _prioridade,
      );

      try {
        if (widget.tarefa == null) {
          await DatabaseHelper.instance.insertTarefa(tarefa);
        } else {
          await DatabaseHelper.instance.updateTarefa(tarefa);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar tarefa: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tarefa == null ? 'Adicionar Tarefa' : 'Editar Tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              DropdownButtonFormField<String>(
                value: _prioridade,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: ['Alta', 'Média', 'Baixa'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _prioridade = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _salvarTarefa, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}