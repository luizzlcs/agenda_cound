import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Instancia do banco Cloud Firestone
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController _textController = TextEditingController();
  List<String> listName = [];

  @override
  void initState() {
    // Atualização inicial
    // refresh();

    // Atualização em tempo real
    db.collection("contato").snapshots().listen((query) {
      listName = [];
      query.docs.forEach((doc) {
        setState(() {
          listName.add(doc.get('name'));
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adiconando dados no FireStore'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Vamos gravar nome nas nuvens',
                style: TextStyle(fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _textController,
                  decoration: const InputDecoration(
                      isDense: true,
                      label: Text('Nome Inserido'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        ),
                      ),
                      hintText: 'Insira um nome:'),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => sendData(),
                icon: const Icon(Icons.near_me),
                label: const Text('Adicionar'),
              ),
              const SizedBox(height: 8),
              (listName.isEmpty)
                  ? const Text(
                      'Nenhum contato registrado',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    )
                  : Column(
                      children: [
                        for (String s in listName)
                          Text(
                            s,
                            style: const TextStyle(color: Colors.blue),
                          ),
                      ],
                    )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () {
          refresh();
        },
      ),
    );
  }

  void refresh() async {
    // atualização manual
    QuerySnapshot query = await db.collection("contato").get();
    listName = [];
    query.docs.forEach((doc) {
      String name = doc.get('name');
      setState(() {
        listName.add(name);
      });
    });
  }

  void sendData() {
    // atualização do ID
    String id = Uuid().v1();
    db.collection("contato").doc(id).set({
      "name": _textController.text,
    });

    // Feedback visual
    _textController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Salvo no Firestore'),
      ),
    );
  }
}
