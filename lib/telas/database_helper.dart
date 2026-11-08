import 'package:lista_loja/telas/banco.dart';
import 'package:sqflite/sqflite.dart';

// classe para abrir e gerenciar o banco de dados padrao singleton ensinado na aula 
class DatabaseHelper {
  Database? _db;

  static final DatabaseHelper _instancia = DatabaseHelper.internal();

  DatabaseHelper.internal();

  factory DatabaseHelper() => _instancia;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database?> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = "$databasePath/anunciosDatabase.db";

    try {
      return _db = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreateDB,
        onUpgrade: _onUpgradeDB,
      );
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future _onCreateDB(Database db, int version) async {
    await db.execute(AnuncioHelper.createScript);
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute("DROP TABLE ${AnuncioHelper.table};");
      await _onCreateDB(db, newVersion);
    }
  }
}
