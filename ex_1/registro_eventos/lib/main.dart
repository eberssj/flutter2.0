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
      title: 'Registro de Eventos',
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
      home: EventoScreen(),
    );
  }
}

class EventoScreen extends StatefulWidget {
  @override
  _EventoScreenState createState() => _EventoScreenState();
}

class _EventoScreenState extends State<EventoScreen> {
  final _descricaoController = TextEditingController();
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  List<Map<String, dynamic>> _eventos = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/eventos.json');
  }

  Future<void> _carregarEventos() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);
        setState(() {
          _eventos = jsonData.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      setState(() {
        _eventos = [];
      });
    }
  }

  Future<void> _salvarEventos() async {
    final file = await _localFile;
    await file.writeAsString(json.encode(_eventos));
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  Future<void> _selecionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _horaSelecionada) {
      setState(() {
        _horaSelecionada = picked;
      });
    }
  }

  void _salvarEvento() {
    if (_dataSelecionada != null &&
        _horaSelecionada != null &&
        _descricaoController.text.isNotEmpty) {
      final evento = {
        'data': DateFormat('dd/MM/yyyy').format(_dataSelecionada!),
        'hora': _horaSelecionada!.format(context),
        'descricao': _descricaoController.text,
      };
      setState(() {
        _eventos.add(evento);
      });
      _salvarEventos();
      _descricaoController.clear();
      _dataSelecionada = null;
      _horaSelecionada = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evento salvo com sucesso!'),
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
    _carregarEventos();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de Eventos',
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
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.teal),
                    title: Text(
                      _dataSelecionada == null
                          ? 'Selecionar Data'
                          : 'Data: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}',
                      style: TextStyle(
                        color: _dataSelecionada == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    onTap: () => _selecionarData(context),
                    tileColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 12),
                  ListTile(
                    leading: Icon(Icons.access_time, color: Colors.teal),
                    title: Text(
                      _horaSelecionada == null
                          ? 'Selecionar Hora'
                          : 'Hora: ${_horaSelecionada!.format(context)}',
                      style: TextStyle(
                        color: _horaSelecionada == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    onTap: () => _selecionarHora(context),
                    tileColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _descricaoController,
                    decoration: InputDecoration(
                      labelText: 'Descrição do Evento',
                      prefixIcon: Icon(Icons.description, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Salvar Evento'),
                      onPressed: _salvarEvento,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Eventos Salvos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _eventos.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum evento salvo ainda.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _eventos.length,
                      itemBuilder: (context, index) {
                        final evento = _eventos[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal[100],
                              child: Icon(Icons.event, color: Colors.teal),
                            ),
                            title: Text(
                              evento['descricao'],
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${evento['data']} - ${evento['hora']}',
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