import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _edProduto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controle de Compras'),
      ),
      body: _body(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _showMaterialDialog,
        tooltip: 'Remover todos os itens da lista',
        child: const Icon(Icons.autorenew),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Exclusão da Lista'),
            content: Text('Confirma a exclusão de todos os itens da lista?'),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _produtos.clear();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Sim')),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Não'),
              )
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();

    _readData().then((value) => {
          setState(() {
            _produtos = json.decode(value);
          })
        });
  }

  Column _body(context) {
    return Column(
      children: <Widget>[
        _form(),
        _listagem(context),
      ],
    );
  }

  Container _form() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 2, 5, 5),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 70,
            child: TextFormField(
              controller: _edProduto,
              keyboardType: TextInputType.name,
              style: const TextStyle(
                fontSize: 20,
              ),
              decoration: const InputDecoration(
                labelText: 'Produto',
              ),
            ),
          ),
          Expanded(
            flex: 30,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: () {
                  _addProduto();
                },
                child: Text(
                  'Adicionar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List _produtos = [];

  _addProduto() {
    String produto = _edProduto.text;

    var novoProduto = new Map();

    novoProduto["nome"] = produto;
    novoProduto["ok"] = false;

    setState(() {
      _produtos.add(novoProduto);
      _edProduto.text = "";
    });

    _saveData();
  }

  Expanded _listagem(context) {
    return Expanded(
      child: ListView.builder(
        itemCount: _produtos.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(_produtos[index]["nome"]),
            value: _produtos[index]["ok"],
            onChanged: (bool? value) {
              setState(() {
                _produtos[index]["ok"] = value;
              });
              _saveData();
            },
            // secondary: const Icon(Icons.hourglass_empty),
          );
        },
      ),
    );
  }

  Future<File> _getFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    return File(appDocPath + "/compras.json");
  }

  Future<File> _saveData() async {
    String compras = json.encode(_produtos);

    final file = await _getFile();
    return file.writeAsString(compras);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      print("Erro na leitura do arquivo ${e.toString()}");
      return "";
    }
  }
}
