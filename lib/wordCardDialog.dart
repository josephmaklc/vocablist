import 'package:flutter/material.dart';
import 'package:vocablist2/db/model/VocabInfo.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocablist2/talking.dart';
import 'package:shared_preferences/shared_preferences.dart';

void wordCardDialog(BuildContext context, VocabInfo vocabInfo) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title:
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(vocabInfo.word, textAlign: TextAlign.center),
          IconButton(
              icon: Icon(
                Icons.volume_up,
              ),
              onPressed: () async {

                final prefs = await SharedPreferences.getInstance();
                String ttsLanguage = prefs.getString("wordTTS")!;
                String ttsCode = getLanguageCodeForTTS(ttsLanguage);
                doTalking(context,ttsCode,vocabInfo.word);

                //tts.speak(vocabInfo.word);

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
                    Icons.volume_up,
                  ),
                  onPressed: () async {

                    final prefs = await SharedPreferences.getInstance();
                    String ttsLanguage = prefs.getString("translationTTS")!;
                    String ttsCode = getLanguageCodeForTTS(ttsLanguage);
                    doTalking(context,ttsCode,vocabInfo.definition);

                    //tts.speak(vocabInfo.definition);

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