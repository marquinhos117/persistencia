import 'package:flutter/material.dart';
import 'package:lista_loja/telas/banco.dart';
import 'package:lista_loja/telas/tela_cadastro.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaPrincipal(),
    );
  }
}

// tela principal com a lista
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  // ajudante do banco de dados sqlite
  AnuncioHelper _helper = AnuncioHelper();

  // lista dos anuncios salva na memoria
  List<Anuncio> listaAnuncios = [];

  @override
  void initState() {
    super.initState();
    // busca todos os anuncios salvos no banco quando abre o app
    _helper.getAll().then((data) {
      setState(() {
        listaAnuncios = data;
      });
    });
  }

  // vai para a tela de cadastro
  void _irParaCadastro() async {
    // abre a tela 2 e espera voltar com os dados
    Anuncio? resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaCadastro()),
    );

    // se voltou com anuncio preenchido, salva no banco e adiciona na lista
    if (resultado != null) {
      Anuncio? anuncioSalvo = await _helper.saveAnuncio(resultado);
      if (anuncioSalvo != null) {
        setState(() {
          listaAnuncios.add(anuncioSalvo);
          const snackBar = SnackBar(
            content: Text('Anúncio criado com sucesso!'),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      }
    }
  }

  // vai para a tela de editar
  void _irParaEditar(int index) async {
    // abre a tela 2 no anuncio que quer editar
    Anuncio? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TelaCadastro(anuncioParaEditar: listaAnuncios[index]),
      ),
    );

    // se voltou com o anuncio editado, atualiza no banco e na lista
    if (resultado != null) {
      var result = await _helper.editAnuncio(resultado);
      if (result != null) {
        setState(() {
          listaAnuncios[index] = resultado;
          const snackBar = SnackBar(
            content: Text('Anúncio editado com sucesso!'),
            backgroundColor: Colors.orange,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      }
    }
  }

  // apaga o anuncio do banco e da lista
  void _remover(int index) async {
    var result = await _helper.deleteAnuncio(listaAnuncios[index]);
    if (result != null) {
      setState(() {
        listaAnuncios.removeAt(index);
        const snackBar = SnackBar(
          content: Text('Anúncio apagado com sucesso!'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }
  }

  // abre o bottom sheet quando segura apertado no card para compartilhar
  void _compartilhar(BuildContext context, Anuncio item) {
    String texto =
        "Anúncio: ${item.titulo} - ${item.descricao} - R\$ ${item.preco}";

    showBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Enviar por e-mail"),
                onTap: () async {
                  Uri url = Uri(
                    scheme: "mailto",
                    path: "marcel.melo@ifgoiano.edu.br",
                    queryParameters: {
                      "subject": "Anúncio - ${item.titulo}",
                      "body": texto,
                    },
                  );

                  launchUrl(url.normalizePath());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sms),
                title: const Text("Enviar por sms"),
                onTap: () async {
                  Uri url = Uri(
                    scheme: "sms",
                    path: "(34)99636-8898",
                    queryParameters: {
                      "body": texto,
                    },
                  );

                  launchUrl(url.normalizePath());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.send),
                title: const Text("Enviar por whatsapp"),
                onTap: () async {
                  Uri url = Uri(
                    scheme: "https",
                    path: "wa.me/+5534996368898",
                    queryParameters: {
                      "text": texto,
                    },
                  );

                  launchUrl(url.normalizePath());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text("Sair"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // esqueleto da tela principal
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mercado Preso"),
        backgroundColor: Colors.red,
      ),
      // botao de adicionar 
      floatingActionButton: FloatingActionButton(
        shape: const RoundedRectangleBorder(),
        backgroundColor: Colors.red,
        onPressed: _irParaCadastro,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: listaAnuncios.length,
        itemBuilder: (context, index) {
          Anuncio item = listaAnuncios[index];

          // card para cada anuncio
          return Card(
            shape: const RoundedRectangleBorder(),
            margin: const EdgeInsets.all(8),
            child: ListTile(
              // se tiver foto mostra no circulo, se nao tiver mostra a sacola
              leading: item.imagem != null
                  ? Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.file(
                          item.imagem!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.shopping_bag,
                      size: 40,
                      color: Colors.red,
                    ), // icone do produto
              title: Text(
                item.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${item.descricao}\nR\$ ${item.preco}"),
              // segurar apertado no anuncio abre o bottom sheet de compartilhar
              onLongPress: () => _compartilhar(context, item),
              // botao de editar e excluir no final do card
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _irParaEditar(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _remover(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
