import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'db/controller/vocabListController.dart';
import 'db/model/VocabInfo.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

const String translateAPI = "http://api.microsofttranslator.com/V2/Ajax.svc/Translate?oncomplete=mycallback&appId=B3E6A7DFAC5FC07CFFD6496F5F79012228A35E86";

void _launchURL(String _url) async {
  if (!await launch(_url)) {
    throw 'Could not launch $_url';
  }
}

Future<String> getTranslation(String word, String language) async {
  String langCode = "";
  if (language=="Spanish")
    langCode = "es";
  if (language=="French")
    langCode = "fr";
  if (language=="Simplified Chinese")
    langCode = "zh-CHS"; // bing
  if (language=="Traditional Chinese")
    langCode = "zh-CHT"; // bing

  String url = translateAPI+"&from=en&to="+langCode+"&text="+word;
  //print("url:"+url);
  final response = await http
      .get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    //print("translation: "+response.body);
    String bingResult = response.body;
    String translatedText="";
    String thePrefix = "mycallback";
    if (bingResult.indexOf(thePrefix)>=0) {
      translatedText = bingResult.substring(thePrefix.length+2,bingResult.length-3);
    }
    else {
      translatedText=bingResult;
    }
    //print("translation: "+translatedText);
    return translatedText;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to call translation API');
  }
  return "";
}

Future<void> showVocabularyDialog(
    BuildContext context, Database db, FlutterTts fluttertts, VocabInfo vocabInfo) async {
  var wordController = TextEditingController(text: vocabInfo.word);
  var definitionController = TextEditingController(text: vocabInfo.definition);
  String errorMessage = "";

  String languagePref="Spanish";
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
                    decoration: InputDecoration(border: OutlineInputBorder())
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(onPressed: () {
                        if (!wordController.text.isEmpty) {
                          fluttertts.speak(wordController.text);
                        }
                      },
                        child:Text("Pronounce")),
                      TextButton(onPressed: () {
                        _launchURL("https://en.wiktionary.org/wiki/"+wordController.text);
                      },
                          child:Text("Definition on Web"))

                      ]

                ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[

                        Flexible(
                            child: DropdownButton<String>(
                                value: languagePref,
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 16,
                                style: const TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (String? newValue) async {
                                  //String translation = await getTranslation(wordController.text,newValue!);

                                  setState(() {
                                    languagePref = newValue!;
                                    //definitionController.text=translation;
                                  });
                                },
                                items: <String>[
                                  'Spanish',
                                  'French',
                                  'Traditional Chinese',
                                  'Simplified Chinese'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList()),

                        ),
                        TextButton(onPressed: () async {
                          String translation = await getTranslation(wordController.text,languagePref);

                          setState(() {
                            definitionController.text=translation;
                          });
                        }, child: Text("Translate")),
                      ],
                    ),
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
