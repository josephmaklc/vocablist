import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'db/controller/vocabListController.dart';
import 'db/model/VocabInfo.dart';

Future<void> showVocabularyDialog(
    BuildContext context, Database db, VocabInfo vocabInfo) async {
  var wordController = TextEditingController(text: vocabInfo.word);
  var definitionController = TextEditingController(text: vocabInfo.definition);
  String errorMessage = "";

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Vocabulary', textAlign: TextAlign.center),
          content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text("Word:", textAlign: TextAlign.left),
                ),
                TextFormField(
                    controller: wordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a vocabulary';
                      }
                      return null;
                    },
                    decoration: InputDecoration(border: OutlineInputBorder())),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text("Definition:", textAlign: TextAlign.left),
                    ),

                TextFormField(
                    controller: definitionController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    minLines: 6, // any number you need (It works as the rows for the textarea)
                    keyboardType: TextInputType.multiline,
                    maxLines: null
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                          ))
                    ])
              ])),
          actions: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    String word = wordController.text;
                    String definition = definitionController.text;
                    VocabListController c = VocabListController();

                    if (vocabInfo.id == 0) {
                      print("insert new word: " + word + " defn: " + definition);
                      VocabInfo newVocab = new VocabInfo(
                          id: null, word: word, definition: definition);

                      c.insertVocabulary(db, newVocab);
                    } else {
                      print("edit word " + vocabInfo.id.toString());
                      VocabInfo editVocabInfo = new VocabInfo(
                          id: vocabInfo.id, word: word, definition: definition);
                      // check if word exist already
                      c.updateVocabulary(db, editVocabInfo);
                    }

                    Navigator.pop(context, 'Ok');
                  }),
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              )
            ])
          ],
        );
      });
    },
  );
}
