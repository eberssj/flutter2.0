import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path_provider/path_provider.dart';
import '../models/projeto.dart';

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
      String path = join(documentsDirectory.path, 'projetos.db');
      return await openDatabase(path, version: 1, onCreate: _onCreate);
    } else {
      // Suporte para web
      var factory = createDatabaseFactoryFfiWeb();
      return await factory.openDatabase('projetos.db', options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ));
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projetos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertProjeto(Projeto projeto) async {
    Database db = await database;
    return await db.insert('projetos', projeto.toMap());
  }

  Future<List<Projeto>> getProjetos({String? statusFiltro}) async {
    Database db = await database;
    String where = statusFiltro != null && statusFiltro != 'Todos' ? 'status = ?' : '';
    List<dynamic> whereArgs = statusFiltro != null && statusFiltro != 'Todos' ? [statusFiltro] : [];
    List<Map<String, dynamic>> maps = await db.query('projetos', where: where, whereArgs: whereArgs);
    return List.generate(maps.length, (i) => Projeto.fromMap(maps[i]));
  }

  Future<int> updateProjeto(Projeto projeto) async {
    Database db = await database;
    return await db.update('projetos', projeto.toMap(), where: 'id = ?', whereArgs: [projeto.id]);
  }

  Future<int> deleteProjeto(int id) async {
    Database db = await database;
    return await db.delete('projetos', where: 'id = ?', whereArgs: [id]);
  }
}