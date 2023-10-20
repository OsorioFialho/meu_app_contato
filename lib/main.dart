import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:meu_app_contato/pages/contato_http_page.dart';
import 'package:meu_app_contato/repository/contato_back4app_repository.dart';

void main() => runApp(const MyApp());

class Contact {
  String nome;
  String nascimento;
  String fone;
  String cep;
  File? image;

  Contact(
      {required this.nome,
      required this.nascimento,
      required this.fone,
      required this.cep,
      this.image});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Usuário',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contacts = <Contact>[];
  final _picker = ImagePicker();
  //final _uuid = Uuid();

  late TextEditingController _nomeController;
  late TextEditingController _nascimentoController;
  late TextEditingController _foneController;
  late TextEditingController _cepController;

  Future pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        setState(() {
          _contacts.last.image = File(croppedFile.path);
          File lastImage = File(croppedFile.path);
          bool exists = lastImage.existsSync();
          if (exists) {
            setState(() {
              _contacts.last.image = lastImage;
              File(pickedFile.path).deleteSync();
            });
          }
        });
      }
    }
  }

  cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    return croppedFile;
  }

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _nascimentoController = TextEditingController();
    _foneController = TextEditingController();
    _cepController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nascimentoController.dispose();
    _foneController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nascimentoController,
                decoration:
                    const InputDecoration(labelText: 'Data de Nascimento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma data de nascimento';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _foneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um número de telefone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(labelText: 'CEP'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um CEP';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final ContatoBack4AppRepository repository =
                      ContatoBack4AppRepository();

                  if (_formKey.currentState!.validate()) {
                    Contact novoContact = Contact(
                        nome: _nomeController.text,
                        nascimento: _nascimentoController.text,
                        fone: _foneController.text,
                        cep: _cepController.text,
                        image: null);

                    _contacts.add(novoContact);

                    await pickImage();

                    await repository.criarContatos(
                        novoContact.nome,
                        novoContact.nascimento,
                        novoContact.fone,
                        novoContact.cep,
                        novoContact.image.toString());

                    _nomeController.clear();
                    _nascimentoController.clear();
                    _foneController.clear();
                    _cepController.clear();

                    setState(() {});
                  }
                },
                child: const Text('Salvar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ContactListScreen(contacts: _contacts)),
                  );
                },
                child: const Text('Ver Lista de Contatos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
