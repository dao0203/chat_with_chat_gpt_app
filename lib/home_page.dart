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
  var chat = [];

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    Future<void> sendMessage(String message) async {
      //APIキーを.envから取得
      final apiKey = dotenv.get("OPENAI_API_KEY");
      //リクエストボディを追加してリクエストを送信
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        //https://platform.openai.com/docs/api-reference/chat/create
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": message}
          ],
        }),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey"
        },
      );

      //レスポンスをデコードして表示
      setState(() {
        //日本語だと文字化けするのでutf8でデコード
        final decodedResponse = utf8.decode(response.body.runes.toList());

        final decodedToJson = jsonDecode(decodedResponse);
        final content = decodedToJson["choices"][0]["message"]["content"];
        debugPrint(decodedResponse.toString());
        //チャットに追加
        chat.add(content);
      });
    }

    //画面を作成していく
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    maxLines: 1,
                    cursorRadius: const Radius.circular(10),
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "メッセージを入力",
                    ),
                    onEditingComplete: () {
                      //キーボードの完了ボタンを押したときに送信
                      sendMessage(messageController.text);
                      //入力欄をクリア
                      messageController.clear();
                    },
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
