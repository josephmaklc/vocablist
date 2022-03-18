import 'package:flutter/material.dart';
import 'package:swiping_card_deck/swiping_card_deck.dart';
import 'package:vocablist2/db/model/VocabInfo.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math' as math;

import 'package:vocablist2/flashCardForm.dart';

/*
void flashCardDialog(BuildContext context, FlutterTts tts, List<VocabInfo> vocabList) async {

  FlashCardWidget flashCardWidget = FlashCardWidget(fluttertts: null, vocabList: const [],);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(

        content: flashCardWidget, // deck
        actions: <Widget>[

          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Close'),
              child: const Text('Close'),
            )
          ])
        ],
      );
    },
  );
}

class VocabCard extends StatelessWidget {
  VocabCard(this.vocabInfo);
  VocabInfo vocabInfo;

  @override
  Widget build(BuildContext context) {
    return
        Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

            Row(
                mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Text(vocabInfo.word, textAlign: TextAlign.center),

                IconButton(
                icon: Icon(
                Icons.chat,
                ),
                onPressed: () async {
                //tts.speak(vocabInfo.definition);

                })
            ]),

              Row(
                  mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Text(vocabInfo.definition, textAlign: TextAlign.center),

                IconButton(
                    icon: Icon(
                      Icons.chat,
                    ),
                    onPressed: () async {
                      //tts.speak(vocabInfo.definition);

                    })
              ])

            ]);

  }

}
 */