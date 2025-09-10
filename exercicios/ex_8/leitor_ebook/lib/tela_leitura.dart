import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TelaLeitura extends StatefulWidget {
  const TelaLeitura({super.key});

  @override
  _TelaLeituraState createState() => _TelaLeituraState();
}

class _TelaLeituraState extends State<TelaLeitura> {
  final PageController _pageController = PageController();
  int _paginaAtual = 0;
  final String _jsonFileName = 'progresso_ebook.json';

  @override
  void initState() {
    super.initState();
    _carregarProgresso();
  }

  Future<void> _carregarProgresso() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_jsonFileName');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonData = jsonDecode(contents);
        setState(() {
          _paginaAtual = jsonData['pagina'] ?? 0;
        });
        _pageController.jumpToPage(_paginaAtual);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar progresso: $e')),
      );
    }
  }

  Future<void> _salvarProgresso() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_jsonFileName');
      final jsonData = {'pagina': _paginaAtual};
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar progresso: $e')),
      );
    }
  }

  @override
  void dispose() {
    _salvarProgresso();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lendo E-book')),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _paginaAtual = page;
          });
        },
        itemCount: 10,  // Simulando 10 páginas
        itemBuilder: (context, index) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Página ${index + 1}\n\nConteúdo fictício da página ${index + 1}. Aqui vai o texto do e-book.',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Página atual: ${_paginaAtual + 1}'),
          ],
        ),
      ),
    );
  }
}