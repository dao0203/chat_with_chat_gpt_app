import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var chat = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: chat.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(chat[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //APIキーを.envから取得
          final apiKey = dotenv.get("OPENAI_API_KEY");
          //リクエストボディを追加してリクエストを送信
          final response = await http.post(
            Uri.parse("https://api.openai.com/v1/chat/completions"),
            //https://platform.openai.com/docs/api-reference/chat/create
            body: jsonEncode({
              "model": "gpt-3.5-turbo",
              "messages": [
                {"role": "user", "content": "Hello, I'm a human."}
              ],
            }),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $apiKey"
            },
          );
          setState(() {
            final decoded = jsonDecode(response.body);
            final content = decoded["choices"][0]["message"]["content"];
            debugPrint(decoded.toString());
            debugPrint(content);
            chat.add(content);
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
