import 'package:flutter/material.dart';
import 'package:vocablist2/db/model/VocabInfo.dart';
import 'package:flutter_tts/flutter_tts.dart';

void wordCardDialog(BuildContext context, FlutterTts tts, VocabInfo vocabInfo) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title:
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(vocabInfo.word, textAlign: TextAlign.center),
            IconButton(
              icon: Icon(
                Icons.chat,
              ),
              onPressed: () async {
                tts.speak(vocabInfo.word);

              }, // Handle your onTap here.
            )]),

        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Text(vocabInfo.definition, textAlign: TextAlign.center),

                IconButton(
                  icon: Icon(
                    Icons.chat,
                  ),
                  onPressed: () async {
                    tts.speak(vocabInfo.definition);

                  }, // Handle your onTap here.
              )
            ])],
          ),
        ),
        actions: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Ok'),
              child: const Text('Ok'),
            )
          ])
        ],
      );
    },
  );
}