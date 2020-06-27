import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String url = 'https://owlbot.info/api/v4/dictionary/';
  String token = 'b6f6ef429d2f2c04fabcdb85fdf0dd9b283a6b4d';

  TextEditingController _controller = TextEditingController();

  StreamController streamController;
  Stream stream;

  Timer _timer;

  _search() async{
    if(_controller.text == null || _controller.text.length==0) {
      streamController.add(null);
      return;
    }

    streamController.add("waiting");
    Response response = await get(url + _controller.text.trim(), headers: {"Authorization": "Token " + token});
    streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    streamController = StreamController();
    stream = streamController.stream;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Dictionary'),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: TextFormField(
//                    onChanged: (String text) {
//                      if(_timer?.isActive ?? false) _timer.cancel();
//                      _timer = Timer(const Duration(milliseconds: 1000), () {
//                        _search();
//                      });
//                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Search word here",
                      contentPadding: const EdgeInsets.only(left: 24.0),
                      border: InputBorder.none
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search,
                  color: Colors.white,),
                onPressed: (){
                  _search();
                },
              )
            ],
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.data == null) {
              return Center(
                child: Text("Enter a word"),
              );
            }

            if(snapshot.data == "waiting") {
              return Center (
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context, int index) {
                return ListBody(
                  children: <Widget>[
                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        leading: snapshot.data["definitions"][index]["image_url"] == null ? null : CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data["definitions"][index]["image_url"]),
                        ),
                        title: Text(_controller.text.trim() + "(" + snapshot.data["definitions"][index]["type"] + ")"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(snapshot.data["definitions"][index]["definition"]),
                    )
                  ],
                );

              },
            );
          },

        ),
      )
      );
  }
}
