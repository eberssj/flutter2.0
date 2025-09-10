import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/item.dart';

class AdicionarEditarScreen extends StatefulWidget {
  final Item? item;

  const AdicionarEditarScreen({super.key, this.item});

  @override
  _AdicionarEditarScreenState createState() => _AdicionarEditarScreenState();
}

class _AdicionarEditarScreenState extends State<AdicionarEditarScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _quantidadeController;
  late TextEditingController _precoController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.item?.nome ?? '');
    _quantidadeController = TextEditingController(text: widget.item?.quantidade.toString() ?? '');
    _precoController = TextEditingController(text: widget.item?.preco.toString() ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _salvarItem() async {
    if (_formKey.currentState!.validate()) {
      Item item = Item(
        id: widget.item?.id,
        nome: _nomeController.text,
        quantidade: int.parse(_quantidadeController.text),
        preco: double.parse(_precoController.text),
      );

      try {
        if (widget.item == null) {
          await DatabaseHelper.instance.insertItem(item);
        } else {
          await DatabaseHelper.instance.updateItem(item);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar item: $e'),
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
        title: Text(widget.item == null ? 'Adicionar Item' : 'Editar Item'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Item',
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Campo obrigatório';
                        if (int.tryParse(value) == null) return 'Quantidade deve ser um número';
                        if (int.parse(value) < 0) return 'Quantidade não pode ser negativa';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _precoController,
                      decoration: const InputDecoration(
                        labelText: 'Preço (R\$)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value!.isEmpty) return 'Campo obrigatório';
                        if (double.tryParse(value) == null) return 'Preço deve ser um número';
                        if (double.parse(value) <= 0) return 'Preço deve ser maior que zero';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _salvarItem,
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