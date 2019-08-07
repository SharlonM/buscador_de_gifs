import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _pesquisar;
  int _offset = 0;
  final _textoController = TextEditingController();

  Future<Map> _getGifs() async {
    http.Response response;

    if (_pesquisar == null)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=dy7ZJkxGcR2ptVCPN6lkfNBMNcT0mdr8&limit=25&rating=G");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=dy7ZJkxGcR2ptVCPN6lkfNBMNcT0mdr8&q=$_pesquisar&limit=25&offset=$_offset&rating=G&lang=pt");

    return json.decode(response.body);
  } // GET GIFS

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: layoutPrincipal(),
    );
  }

  appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Image.network(
        "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif",
        scale: 2,
      ),
      centerTitle: true,
    );
  } // AAP BAR

  layoutPrincipal() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar(),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: campoDeTexto(),
          ),
          Expanded(
            child: checkConnections(),
          )
        ],
      ),
    );
  } // LAYOUT PRINCIPAL

  checkConnections() {
    return FutureBuilder(
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return progressBar();
          default:
            if (snapshot.hasError)
              return Container();
            else
              return createTabelaGifs(context, snapshot);
        }
      },
      future: _getGifs(),
    );
  }

  progressBar() {
    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 5,
      ),
    );
  }

  campoDeTexto() {
    return Theme(
      data: new ThemeData(hintColor: Colors.white),
      child: TextFormField(
        controller: _textoController,
        decoration: InputDecoration(
            labelText: "Pesquise aqui",
            fillColor: Colors.white,
            labelStyle: TextStyle(color: Colors.white, fontSize: 18),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(30.0))),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(30.0)))),
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
        onFieldSubmitted: (text) {
          setState(() {
            _pesquisar = text;
            _offset = 0;
          });
        },
      ),
    );
  }

  int _getRange(List data){
    if(_pesquisar == null){
      return data.length;
    }else{
      return data.length +1;
    }
  }

  createTabelaGifs(context, snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 5),
        itemCount: _getRange(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_pesquisar == null || index < snapshot.data["data"].length) {
            return GestureDetector(
              child: Image.network(
                snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return carregarMais();
          }
        });
  }

  carregarMais() {
    return Container(
      color: Colors.black,
      child: GestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.more_horiz, color: Colors.white, size: 50),
            Text(
              "Carregar mais",
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
          ],
        ),
        onTap: (){
          setState(() {
            _offset += 25;
          });
        },
      ),
    );
  }
}
