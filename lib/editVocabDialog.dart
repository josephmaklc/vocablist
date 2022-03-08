import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'db/controller/vocabListController.dart';
import 'db/model/VocabInfo.dart';



Future<void> showVocabularyDialog(BuildContext context, Database db, VocabInfo vocabInfo) async  {
  var wordController = TextEditingController(text: vocabInfo.word);
  var definitionController = TextEditingController(text: vocabInfo.definition);
  String errorMessage="";

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Configuration', textAlign: TextAlign.center),
          content: SingleChildScrollView(

              child:

              Column(children: <Widget>[
                Text("Vocabulary:"),
                TextFormField(
                    controller: wordController,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10))
                ),
                Text("Definition:"),
                TextFormField(
                    controller: definitionController,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10))
                ),


                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                          )
                      )
                    ]
                )
              ]
              )

          ),
          actions: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                      child: const Text('OK'),
                      onPressed: () {

                        String word = wordController.text;
                        String definition= definitionController.text;

                        VocabListController c = VocabListController();

                        if (vocabInfo.id==0) {
                          print("insert new word: "+word+" defn: "+definition);
                          VocabInfo newVocab = new VocabInfo(id: null, word: word, definition: definition);

                          c.insertVocabulary(db, newVocab);
                        }
                        else {
                          print("edit word "+vocabInfo.id.toString());
                          VocabInfo editVocabInfo = new VocabInfo(id: vocabInfo.id, word: word, definition: definition);
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

