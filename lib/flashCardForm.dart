import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:vocablist2/talking.dart';

import 'db/model/VocabInfo.dart';

import 'package:shared_preferences/shared_preferences.dart';

class FlashCardWidget extends StatefulWidget {
  List<VocabInfo> vocabList;

  FlashCardWidget(
      {Key? key,
      required this.vocabList,
      })
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyFlashCardState();
}

class _MyFlashCardState extends State<FlashCardWidget> {
  int _currentIndex = 0;
  List<Flashcard> _flashcards = [];
  double WIDTH = 250;
  double HEIGHT = 200;

  @override
  void initState() {
    super.initState();

    for (VocabInfo vocabInfo in widget.vocabList) {
      _flashcards.add(
          Flashcard(word: vocabInfo.word, definition: vocabInfo.definition));
    }
    _flashcards.shuffle();

  }

  @override
  Widget build(BuildContext context) {
    // turn list into array for use with FlipCard
    String dir="";
    return Scaffold(
      appBar: AppBar(title: const Text("Flash Cards")),
      body:
      GestureDetector(
        onPanUpdate: (details) {
          // Swiping in left direction.
          if (details.delta.dx < 0) {
            //print("left");
            dir="left";
          //  showPreviousCard();
          }

          // Swiping in right direction.
          if (details.delta.dx > 0) {
            //print("right");
            dir="right";
            //showNextCard();
          }
        },
        onPanEnd: (dragEndDetails) {
          //print("end");
          if (dir=="left") showPreviousCard();
          if (dir=="right") showNextCard();
        },
        child:

        Row(
          children: <Widget>[
            SizedBox(
              width: 10
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                  onPressed: showPreviousCard, child: Text('<')),
            ),
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: SizedBox(
                    width: WIDTH,
                    height: HEIGHT,
                    child: FlipCard(
                        direction: FlipDirection.HORIZONTAL,
                        front: FlashcardView(
                          vocabInfo: _flashcards[_currentIndex],
                        ),
                        back: FlashcardBackView(
                            vocabInfo: _flashcards[_currentIndex]

                        )))

              ),
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(onPressed: showNextCard, child: Text('>')),
            ),
            SizedBox(
                width: 10
            ),

          ],
        )

    ));

  }

  void showNextCard() {
    setState(() {
      _currentIndex =
          (_currentIndex + 1 < _flashcards.length) ? _currentIndex + 1 : 0;
    });
  }

  void showPreviousCard() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 >= 0) ? _currentIndex - 1 : _flashcards.length - 1;
    });
  }
}

class Flashcard {
  final String word;
  final String definition;

  Flashcard({required this.word, required this.definition});
}

class FlashcardView extends StatelessWidget {
  final Flashcard vocabInfo;

  FlashcardView({required this.vocabInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Center(
        child: Text(
          vocabInfo.word,
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class FlashcardBackView extends StatelessWidget {
  final Flashcard vocabInfo;

  FlashcardBackView({required this.vocabInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 4,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(vocabInfo.word, textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
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
                        })
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(vocabInfo.definition, textAlign: TextAlign.center,style: TextStyle(fontSize: 20)),
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
                        })
                  ])
            ])

        /*Center(
        child: Text(
          vocabInfo.definition,
          style: TextStyle(fontSize:20),
          textAlign: TextAlign.center,
        ),
      ),

       */
        );
  }
}
