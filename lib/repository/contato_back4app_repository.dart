import 'package:dio/dio.dart';
import 'package:meu_app_contato/model/contato_back4app_model.dart';

class ContatoBack4AppRepository {
  Future<ContatoBack4AppModel> obterContatos() async {
    var dio = Dio();
    dio.options.headers["X-Parse-Application-Id"] =
        "g8OCxgWYddOW8DDVornqdCH4prNMHIM8tQttWo3q";
    dio.options.headers["X-Parse-REST-API-Key"] =
        "lM3GgZv9p7ULK9VaVfrjVLAoItD6JkqezJdcA4Xv";
    dio.options.headers["Content-Type"] = "application/json";
    var result =
        await dio.get("https://parseapi.back4app.com/classes/Contatos");
    return ContatoBack4AppModel.fromJson(result.data);
  }

  Future<void> criarContatos(
      var nome, var nascimento, var fone, var cep, var imagePath) async {
    var verificaContatos = await obterContatos();
    var existeContatos = verificaContatos.contatos
        .where((existingContato) => existingContato.nome == nome)
        .toList();
    if (existeContatos.isEmpty) {
      var dio = Dio();
      dio.options.headers["X-Parse-Application-Id"] =
          "g8OCxgWYddOW8DDVornqdCH4prNMHIM8tQttWo3q";
      dio.options.headers["X-Parse-REST-API-Key"] =
          "lM3GgZv9p7ULK9VaVfrjVLAoItD6JkqezJdcA4Xv";
      dio.options.headers["Content-Type"] = "application/json";

      Map<String, dynamic> data = {
        "nome": nome,
        "nascimento": nascimento,
        "fone": fone,
        "cep": cep,
        "image_path": imagePath
      };
      await dio.post("https://parseapi.back4app.com/classes/Contatos",
          data: data);
    } else {
      //print("Contato já existe");
    }
  }

  Future<void> deletarTodosContatos(String id) async {
    var dio = Dio();
    dio.options.headers["X-Parse-Application-Id"] =
        "g8OCxgWYddOW8DDVornqdCH4prNMHIM8tQttWo3q";
    dio.options.headers["X-Parse-REST-API-Key"] =
        "lM3GgZv9p7ULK9VaVfrjVLAoItD6JkqezJdcA4Xv";
    dio.options.headers["Content-Type"] = "application/json";

    await dio.delete("https://parseapi.back4app.com/classes/Contatos/$id");
  }
}
