import 'package:flutter/material.dart';
import 'package:gifSearcher/ui/gifpage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

const requestGifs =
    "https://api.giphy.com/v1/gifs/trending?api_key=KXWwQQ0Betdm0F1kvg6jnSRAiEU1tBbj&limit=25&rating=G";

class GifSearcher extends StatefulWidget {
  @override
  _GifSearcherState createState() => _GifSearcherState();
}

class _GifSearcherState extends State<GifSearcher> {
  final searcher = TextEditingController();
  String search;
  int offset = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Divider(),
          TextField(
            controller: searcher,
            onSubmitted: (value) {
              setState(() {
                search = value;
                offset = 0;
              });
            },
            decoration: InputDecoration(
                labelText: "pesquisar Gif",
                labelStyle: TextStyle(color: Colors.white, fontSize: 25.0),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent))),
            style: TextStyle(color: Colors.white, fontSize: 25.0),
            textAlign: TextAlign.center,
          ),
          Expanded(
              child: FutureBuilder(
            future: getGifs(),
            builder: (context, snapdata) {
              switch (snapdata.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Container(
                    width: 400.0,
                    height: 400.0,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 10.0,
                    ),
                  );
                default:
                  if (snapdata.hasError) {
                    return Center(
                      child: Text(
                        "Ouve um erro ao carregar os Dados :(",
                        style: TextStyle(color: Colors.yellow),
                      ),
                    );
                  } else {
                    return createGifTable(context, snapdata);
                  }
              }
            },
          ))
        ],
      ),
    );
  }

  int getCountGifs(List gifs) {
    if (search == null) {
      return gifs.length;
    } else {
      return gifs.length + 1;
    }
  }

  Future<Map> getGifs() async {
    if (search != null) {
      http.Response gifsBySearch = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=KXWwQQ0Betdm0F1kvg6jnSRAiEU1tBbj&q=$search&limit=19&offset=$offset&rating=G&lang=en");

      return json.decode(gifsBySearch.body);
    }
    http.Response gifs = await http.get(requestGifs);
    return json.decode(gifs.body);
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshotdata) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: getCountGifs(snapshotdata.data["data"]),
        itemBuilder: (context, index) {
          if (search == null || index < snapshotdata.data["data"].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshotdata.data["data"][index]["images"]
                    ["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshotdata.data["data"][index])),
                );
              },
              onLongPress: () {
                Share.share(snapshotdata.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
            );
          } else {
            return GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.more, color: Colors.white),
                  Text(
                    "More Gifs",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  offset += 19;
                });
              },
            );
          }
        });
  }
}
