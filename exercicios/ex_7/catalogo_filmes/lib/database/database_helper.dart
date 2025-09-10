import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/filme.dart';

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
    String path = join(documentsDirectory.path, 'filmes.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE filmes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        diretor TEXT NOT NULL,
        ano INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertFilme(Filme filme) async {
    Database db = await database;
    return await db.insert('filmes', filme.toMap());
  }

  Future<List<Filme>> getFilmes({String? busca}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps;
    if (busca != null && busca.isNotEmpty) {
      maps = await db.query(
        'filmes',
        where: 'titulo LIKE ? OR diretor LIKE ?',
        whereArgs: ['%$busca%', '%$busca%'],
      );
    } else {
      maps = await db.query('filmes');
    }
    return List.generate(maps.length, (i) => Filme.fromMap(maps[i]));
  }

  Future<int> updateFilme(Filme filme) async {
    Database db = await database;
    return await db.update('filmes', filme.toMap(), where: 'id = ?', whereArgs: [filme.id]);
  }

  Future<int> deleteFilme(int id) async {
    Database db = await database;
    return await db.delete('filmes', where: 'id = ?', whereArgs: [id]);
  }
}