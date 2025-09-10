import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/tarefa.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._privateConstructor();
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._privateConstructor();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'tarefas.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        prioridade TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTarefa(Tarefa tarefa) async {
    Database db = await database;
    return await db.insert('tarefas', tarefa.toMap());
  }

  Future<List<Tarefa>> getTarefas() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'tarefas',
      orderBy: "CASE prioridade WHEN 'Alta' THEN 1 WHEN 'Média' THEN 2 WHEN 'Baixa' THEN 3 END",
    );
    return List.generate(maps.length, (i) => Tarefa.fromMap(maps[i]));
  }

  Future<int> updateTarefa(Tarefa tarefa) async {
    Database db = await database;
    return await db.update('tarefas', tarefa.toMap(), where: 'id = ?', whereArgs: [tarefa.id]);
  }

  Future<int> deleteTarefa(int id) async {
    Database db = await database;
    return await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }
}