import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=0a014bcb";

void main() async {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(hintColor: Colors.black, primaryColor: Colors.white),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<Map> getData() async {
    http.Response response = await http.get(request);
    return json.decode(response.body);
  }

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text=(real/dolar).toStringAsFixed(2);
    euroController.text=(real/euro).toStringAsFixed(2);
  }
  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text=(dolar*this.dolar).toStringAsFixed(2);
    euroController.text=(dolar*this.dolar/euro).toStringAsFixed(2);

  }
  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text=(euro*this.euro).toStringAsFixed(2);
    dolarController.text=(euro*this.euro/dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(
        title: Text(
          "\$ Conversor de Moedas \$",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando Dados",
                  style: TextStyle(color: Colors.black, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  child:
                  Text(
                    "Erro ao Carregar Dados :(",
                    style: TextStyle(color: Colors.black, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.monetization_on,
                            size: 150, color: Colors.black),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField("Dólares", "US\$", dolarController,_dolarChanged),
                        Divider(),
                        buildTextField("Euros", "€", euroController,_euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

//FUNÇÃO PARA CRIAR O TEXTFIELD DE TODAS AS MOEDAS
Widget buildTextField(String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(
        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25.0),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
