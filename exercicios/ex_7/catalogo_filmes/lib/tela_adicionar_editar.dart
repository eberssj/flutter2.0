import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/filme.dart';

class AdicionarEditarScreen extends StatefulWidget {
  final Filme? filme;

  const AdicionarEditarScreen({super.key, this.filme});

  @override
  _AdicionarEditarScreenState createState() => _AdicionarEditarScreenState();
}

class _AdicionarEditarScreenState extends State<AdicionarEditarScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _diretorController;
  late TextEditingController _anoController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.filme?.titulo ?? '');
    _diretorController = TextEditingController(text: widget.filme?.diretor ?? '');
    _anoController = TextEditingController(text: widget.filme?.ano.toString() ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _diretorController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  Future<void> _salvarFilme() async {
    if (_formKey.currentState!.validate()) {
      Filme filme = Filme(
        id: widget.filme?.id,
        titulo: _tituloController.text,
        diretor: _diretorController.text,
        ano: int.parse(_anoController.text),
      );

      try {
        if (widget.filme == null) {
          await DatabaseHelper.instance.insertFilme(filme);
        } else {
          await DatabaseHelper.instance.updateFilme(filme);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar filme: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filme == null ? 'Adicionar Filme' : 'Editar Filme'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        prefixIcon: Icon(Icons.movie),
                      ),
                      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _diretorController,
                      decoration: const InputDecoration(
                        labelText: 'Diretor',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _anoController,
                      decoration: const InputDecoration(
                        labelText: 'Ano',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Campo obrigatório';
                        if (int.tryParse(value) == null) return 'Ano deve ser um número';
                        if (int.parse(value) < 1888 || int.parse(value) > 2025) {
                          return 'Ano deve ser entre 1888 e 2025';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _salvarFilme,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Salvar', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}