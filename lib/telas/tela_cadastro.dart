import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lista_loja/telas/banco.dart';
import 'package:path_provider/path_provider.dart';

// molde do anuncio com os dados
class Anuncio {
  int? id;
  late String titulo;
  late String descricao;
  late double preco;
  File? imagem;

  Anuncio({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.preco,
    this.imagem,
  });

  // converte o map vindo do banco para o objeto Anuncio 
  Anuncio.fromMap(Map map) {
    this.id = map[AnuncioHelper.idColumn];
    this.titulo = map[AnuncioHelper.tituloColumn];
    this.descricao = map[AnuncioHelper.descricaoColumn];
    this.preco = (map[AnuncioHelper.precoColumn] as num).toDouble();
    this.imagem = map[AnuncioHelper.imagePathColumn] != null &&
            map[AnuncioHelper.imagePathColumn] != ''
        ? File(map[AnuncioHelper.imagePathColumn])
        : null;
  }

  // transforma o objeto Anuncio em map para salvar no sqlite
  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      AnuncioHelper.idColumn: id,
      AnuncioHelper.tituloColumn: titulo,
      AnuncioHelper.descricaoColumn: descricao,
      AnuncioHelper.precoColumn: preco,
      AnuncioHelper.imagePathColumn: imagem != null ? imagem!.path : '',
    };
    return map;
  }
}

//coloquei StatefulWidget para conseguir pegar o texto digitado e saber ta digitando
class TelaCadastro extends StatefulWidget {
  // se vier preenchido e edicao, se vier vazio e um novo cadastro
  final Anuncio? anuncioParaEditar;

  const TelaCadastro({super.key, this.anuncioParaEditar});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  // controlador pra pegar o texto dos campos
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();

  // guarda a foto tirada na camera
  File? _imagem;

  @override
  void initState() {
    super.initState();
    // se estiver editando, coloca os textos antigos e a foto nos campos
    if (widget.anuncioParaEditar != null) {
      _tituloController.text = widget.anuncioParaEditar!.titulo;
      _descricaoController.text = widget.anuncioParaEditar!.descricao;
      _precoController.text = widget.anuncioParaEditar!.preco.toString();
      _imagem = widget.anuncioParaEditar!.imagem;
    }
  }

  // funcao de salvar
  void _salvar() {
    // pega os valores digitados
    String nome = _tituloController.text;
    String desc = _descricaoController.text;
    double valor = double.tryParse(_precoController.text) ?? 0.0;

    // se tiver nome, cria o anuncio
    if (nome.isNotEmpty) {
      Anuncio novo = Anuncio(
        id: widget.anuncioParaEditar?.id,
        titulo: nome,
        descricao: desc,
        preco: valor,
        imagem: _imagem,
      );

      // volta para a tela 1 e devolve o anuncio
      Navigator.pop(context, novo);
    }
  }

  @override
  Widget build(BuildContext context) {
    // esqueleto da tela
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.anuncioParaEditar != null
              ? "Editar Anúncio"
              : "Cadastrar Anúncio",
        ),
        backgroundColor: Colors.red,
      ),
      // botao de salvar 
      floatingActionButton: FloatingActionButton(
        shape: const RoundedRectangleBorder(),
        backgroundColor: Colors.red,
        onPressed: _salvar,
        child: const Icon(Icons.check),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // circulo para tirar foto do produto pela camera
            GestureDetector(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(width: 1, color: Colors.grey),
                  shape: BoxShape.circle,
                ),
                child: _imagem == null
                    ? const Icon(
                        Icons.add_a_photo,
                        size: 30,
                      )
                    : ClipOval(
                        child: Image.file(
                          _imagem!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              onTap: () async {
                final ImagePicker _picker = ImagePicker();
                final XFile? pickedFile = await _picker.pickImage(
                  source: ImageSource.camera,
                );

                // salva a foto de forma permanente no diretorio do app 
                if (pickedFile != null) {
                  File image = File(pickedFile.path);
                  Directory directory =
                      await getApplicationDocumentsDirectory();
                  String _localPath = directory.path;
                  String uniqueID = UniqueKey().toString();

                  final File savedImage = await image.copy(
                    '$_localPath/image_$uniqueID.png',
                  );

                  setState(() {
                    _imagem = savedImage;
                  });
                }
              },
            ),

            // aqui coloco o nome dos produtos >
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: "Produto",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            // aqui coloco a descricao >
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: "Descrição",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            // aqui coloco preço >
            TextField(
              controller: _precoController,
              decoration: const InputDecoration(
                labelText: "Preço",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ], // sempre que vou iniciar um bloquinho novo, defino o sizedbox, posso criar uma e replicar as outras alterando somente os controllers e as labels.
        ),
      ),
    );
  }
}
