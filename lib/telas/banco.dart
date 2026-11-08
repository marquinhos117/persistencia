import 'package:lista_loja/telas/database_helper.dart';
import 'package:lista_loja/telas/tela_cadastro.dart';
import 'package:sqflite/sqflite.dart';


class AnuncioHelper {
  static final String table = "anuncios";
  static final String idColumn = "id";
  static final String tituloColumn = "titulo";
  static final String descricaoColumn = "descricao";
  static final String precoColumn = "preco";
  static final String imagePathColumn = "imagePath";

  static String get createScript {
    return "CREATE TABLE $table($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$tituloColumn TEXT NOT NULL, $descricaoColumn TEXT NOT NULL, "
        "$precoColumn REAL NOT NULL, $imagePathColumn STRING);";
  }

  // salva um anuncio
  Future<Anuncio?> saveAnuncio(Anuncio anuncio) async {
    Database? _db = await DatabaseHelper().db;
    if (_db == null) return null;

    anuncio.id = await _db.insert(table, anuncio.toMap());
    return anuncio;
  }

  // busca todos os anuncios 
  Future<List<Anuncio>> getAll() async {
    Database? _db = await DatabaseHelper().db;
    List<Anuncio> anuncios = [];

    if (_db == null) return anuncios;

    List<Map> anunciosRetornados = await _db.query(
      table,
      columns: [
        idColumn,
        tituloColumn,
        descricaoColumn,
        precoColumn,
        imagePathColumn,
      ],
    );

    for (Map map in anunciosRetornados) {
      anuncios.add(Anuncio.fromMap(map));
    }

    return anuncios;
  }

  // atualiza um anuncio 
  Future<int?> editAnuncio(Anuncio anuncio) async {
    Database? _db = await DatabaseHelper().db;
    if (_db == null) return null;

    return await _db.update(
      table,
      anuncio.toMap(),
      where: "$idColumn = ?",
      whereArgs: [anuncio.id],
    );
  }

  // apaga um anuncio 
  Future<int?> deleteAnuncio(Anuncio anuncio) async {
    Database? _db = await DatabaseHelper().db;
    if (_db == null) return null;

    return await _db.delete(
      table,
      where: "$idColumn = ?",
      whereArgs: [anuncio.id],
    );
  }
}
