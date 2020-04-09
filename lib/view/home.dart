import 'dart:convert';
import 'package:buscagifs/view/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  String _search;
  String _urlMelhoresGifs = "https://api.giphy.com/v1/gifs/trending?api_key=3jM1WSOuMbCyX5eTcxLpk3Qf8rw4M8WR&limit=20&rating=G";
  int _offset = 0;

  //métodos
  //buscando gifs pela api
  Future<Map> _getGifs() async {
    http.Response response;
    
    if(_search == null || _search.isEmpty){
      response = await http.get(_urlMelhoresGifs);
    }else {
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=3jM1WSOuMbCyX5eTcxLpk3Qf8rw4M8WR&q=$_search&limit=19&offset=$_offset&rating=G&lang=en");
    }

    return json.decode(response.body);
  }

  int _getCount(List data){
    if(_search == null || _search.isEmpty){
      //retorna exatamento a quantidade de itens da lista (lembrando que na url
      //de melhores gifs foi determinado 20)
      return data.length;
    }else{
      //retorna a aquantidade de itens da lista acrescido de 1 (lembradando que
      //na url de busca foi determinao 19)
      return data.length + 1;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise Aqui...",
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              ),
              textAlign: TextAlign.center,
              onSubmitted: (texto) {
                //atualizando a tela com o texto de busca digitado
                setState(() {
                  _search = texto;
                  //é necessário ressetar o offset para uma nova busca
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if(snapshot.hasError){
                      return Container();
                    }else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    var qtItens;
    if (snapshot.hasData) {
      print("Existe o snapshot.data: ${snapshot.hasData}");
      //qtItens = snapshot.data["data"].length;
      qtItens = _getCount(snapshot.data["data"]);
      print("Quantidade de itens: $qtItens");
    } else {
      qtItens = 0;
      print("Existe o snapshot.data: ${snapshot.hasData}");
      print("Quantidade de itens: $qtItens");
    }
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //quamtos itens ele terá na horizontal
        crossAxisCount: 2,
        //espaçamento horizontal entre os itens
        crossAxisSpacing: 10,
        //espaçamento vertical entre os itens
        mainAxisSpacing: 10
      ),
      //quantidade de itens na tela
      //ATENÇÃO: para obter a quantidade ".length" é necessário tratar se existe
      //através da sintaxe   "snapshot.data?..."
      //itemCount: snapshot.data?["data"].length ?? 0,
      //itemCount: snapshot.data?["data"].length != null : 0,
      itemCount: qtItens,
      itemBuilder: (context, index) {
        if(_search == null || index < snapshot.data["data"].length){
          //usando o Gesturedetector para possibilitar o toque na imagem
          return GestureDetector(
//            child: Image.network(snapshot.data["data"][index]["images"]["fixed_height"]["url"],
//              height: 300,
//              fit: BoxFit.cover,),
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover,),
            onTap: () {
              Navigator.push(context,
              MaterialPageRoute(
                builder: (context) {
                  //mandando os dados da gif que queremos carregar na próxima tela
                  return GifPage(snapshot.data["data"][index]);
                }
              ));
            },
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );
        }else{
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text("Carregar mais...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  ),)
                ],
              ),
              onTap: () {
                setState(() {
                  //pegando os próximos 19 itens
                  _offset += 19;
                });
              },
            ),
          );
        }
      });

  }
}
