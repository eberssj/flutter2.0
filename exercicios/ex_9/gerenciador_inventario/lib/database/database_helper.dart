import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path_provider/path_provider.dart';
import '../models/item.dart';

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
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS || Platform.isAndroid || Platform.isIOS) {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'inventario.db');
      return await openDatabase(path, version: 1, onCreate: _onCreate);
    } else {
      // Suporte para web
      var factory = createDatabaseFactoryFfiWeb();
      return await factory.openDatabase('inventario.db', options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ));
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE itens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        preco REAL NOT NULL
      )
    ''');
  }

  Future<int> insertItem(Item item) async {
    Database db = await database;
    return await db.insert('itens', item.toMap());
  }

  Future<List<Item>> getItens() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('itens');
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  Future<int> updateItem(Item item) async {
    Database db = await database;
    return await db.update('itens', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteItem(int id) async {
    Database db = await database;
    return await db.delete('itens', where: 'id = ?', whereArgs: [id]);
  }
}