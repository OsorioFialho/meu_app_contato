import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meu_app_contato/main.dart';
import 'package:meu_app_contato/model/contato_back4app_model.dart';
import 'package:meu_app_contato/repository/contato_back4app_repository.dart';

class ContactListScreen extends StatefulWidget {
  final List<Contact> contacts;

  const ContactListScreen({Key? key, required this.contacts}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final ContatoBack4AppRepository _repository = ContatoBack4AppRepository();

  Future<ContatoBack4AppModel> _obterContatosFuture() {
    return _repository.obterContatos();
  }

  void _deletarContato(String objectId) async {
    await _repository.deletarTodosContatos(objectId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Contatos'),
      ),
      body: FutureBuilder<ContatoBack4AppModel>(
          future: _obterContatosFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.contatos.isEmpty) {
              return const Center(child: Text('Nenhum dado encontrado.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.contatos.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data!.contatos[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: item.imagePath != null
                          ? FileImage(File(
                              item.imagePath!.substring(6).replaceAll("'", "")))
                          : null,
                    ),
                    title: Text('${item.nome}'),
                    subtitle: Text(
                        'Data de Nascimento: ${item.nascimento}\nTelefone: ${item.fone}\nCEP: ${item.cep}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        /*IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Feature para Proxima atualização
                          // ...
                        },
                      ),*/
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Excluir Contato"),
                                  content: const Text(
                                      "Tem certeza que deseja excluir este contato?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("Cancelar"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Excluir"),
                                      onPressed: () {
                                        setState(() {
                                          _deletarContato(item.objectId!);
                                          File file = File(item.imagePath!
                                              .substring(6)
                                              .replaceAll("'", ""));
                                          if (file.existsSync()) {
                                            file.deleteSync();
                                          }
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }),
    );
  }
}
