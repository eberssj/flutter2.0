import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/projeto.dart';

class AdicionarEditarScreen extends StatefulWidget {
  final Projeto? projeto;

  const AdicionarEditarScreen({super.key, this.projeto});

  @override
  _AdicionarEditarScreenState createState() => _AdicionarEditarScreenState();
}

class _AdicionarEditarScreenState extends State<AdicionarEditarScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  String _status = 'Em andamento';

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.projeto?.nome ?? '');
    _descricaoController = TextEditingController(text: widget.projeto?.descricao ?? '');
    _status = widget.projeto?.status ?? 'Em andamento';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarProjeto() async {
    if (_formKey.currentState!.validate()) {
      Projeto projeto = Projeto(
        id: widget.projeto?.id,
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        status: _status,
      );

      try {
        if (widget.projeto == null) {
          await DatabaseHelper.instance.insertProjeto(projeto);
        } else {
          await DatabaseHelper.instance.updateProjeto(projeto);
        }
        Navigator.pop(context);
      } catch (e) {
        // Exibir erro ao usuário
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar projeto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.projeto == null ? 'Adicionar Projeto' : 'Editar Projeto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Em andamento', 'Concluído'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _salvarProjeto, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}