import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vocablist2/db/model/VocabInfo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:vocablist2/talking.dart';

import 'configDialog.dart';
import 'db/controller/vocabListController.dart';
import 'toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String translateAPI = "http://api.microsofttranslator.com/V2/Ajax.svc/Translate?oncomplete=mycallback&appId=B3E6A7DFAC5FC07CFFD6496F5F79012228A35E86";
const String translateAPIResultPrefix = "mycallback";
const String defaultLanguagePref = "Traditional Chinese";

const String dictionaryAPI = "https://api.dictionaryapi.dev/api/v2/entries/en/";

class VocabForm extends StatefulWidget {
  VocabInfo vocabInfo;
  String languagePref=defaultLanguagePref;
  Database db;
//  String errorMessage="";

  VocabForm({Key? key, required this.vocabInfo, required this.db}) : super(key: key);

  @override
  _VocabFormState createState() => _VocabFormState();

}


class _VocabFormState extends State<VocabForm> {

  @override
  void initState() {
    super.initState();
    _doInit();
  }

  String wordLanguage = "";
  String wordTTS="";
  String translationLanguage="";
  String translationTTS = "";

  void _doInit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      print("setting init language pref in vocabForm");
      print("wordLanguage:"+ prefs.getString("wordLanguage")!);
      print("wordTTS:"+ prefs.getString("wordTTS")!);
      print("translationLanguage:"+ prefs.getString("translationLanguage")!);
      print("translationTTS:"+ prefs.getString("translationTTS")!);

      wordLanguage =  prefs.getString("wordLanguage")!;
      wordTTS =  prefs.getString("wordTTS")!;
      translationLanguage =  prefs.getString("translationLanguage")!;
      translationTTS =  prefs.getString("translationTTS")!;

//      widget.languagePref=prefs.getString("translationLanguage") ?? defaultLanguagePref;
      //widget.languagePref = (prefs.getString('languagePref') ?? defaultLanguagePref);
    });
  }

  // validate word on Ok
  Future<bool> validate(VocabListController c, String originalWord, word) async {

    if (word.trim().isEmpty) {
      showToast(context, "Please enter a word");
      return false;
    }
    else {
      if (widget.vocabInfo.id==0 && await c.doesWordExistAlready(widget.db, word)) {
        showToast(context, "This word is already on your list");
        return false;
      }
      if (widget.vocabInfo.id!=0 && (word != originalWord) && await c.doesWordExistAlready(widget.db, word)) {
        showToast(context, "This word is already on your list");
        return false;
      }

    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var wordController = TextEditingController(text: widget.vocabInfo.word);
    var definitionController = TextEditingController(text: widget.vocabInfo.definition);

    return Scaffold(
        appBar:
        AppBar(title: Text(widget.vocabInfo.id==0?"New Vocabulary" : "Edit Vocabulary"),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),

                actions:<Widget>[

                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () async {
                      ConfigInfo result = await showConfigurationDialog(
                          context, wordLanguage, wordTTS, translationLanguage,
                          translationTTS);
                      final prefs = await SharedPreferences.getInstance();

                      setState(() {
                        wordLanguage = result.wordLanguage;
                        wordTTS = result.wordTTS;
                        translationLanguage = result.translationLanguage;
                        translationTTS = result.translationTTS;
                        prefs.setString("wordLanguage", wordLanguage);
                        prefs.setString("wordTTS", wordTTS);
                        prefs.setString(
                            "translationLanguage", translationLanguage);
                        prefs.setString("translationTTS", translationTTS);
                      });
                    }
                 )
                ]),

        body:
        Container(
            padding: const EdgeInsets.all(12.0),

            child: SingleChildScrollView(
                child:

                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Text("Word ("+wordLanguage+")", textAlign: TextAlign.left),
                      ),
                      TextFormField(
                          autofocus: true,
                          controller: wordController,
                          decoration: InputDecoration(border: OutlineInputBorder())
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            OutlinedButton.icon(
                              onPressed: () async {
                                if (!wordController.text.isEmpty) {

                                  final prefs = await SharedPreferences.getInstance();
                                  String ttsLanguage = prefs.getString("wordTTS")!;
                                  String ttsCode = getLanguageCodeForTTS(ttsLanguage);
                                  //print("ttsLanguage: "+ttsLanguage);
                                  //print("ttsCode: "+ttsCode);

                                  doTalking(context, ttsCode,wordController.text);
                                }

                              },
                              icon: Icon(
                                Icons.volume_up,
                                size: 24.0,
                              ),
                              label: Text("Pronounce in "+wordTTS),
                            )
                          ]

                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[


                          OutlinedButton(onPressed: () async {

                            String translation = await getTranslation(context, wordController.text,wordLanguage,translationLanguage);

                            setState(() {
                              widget.vocabInfo.word = wordController.text;
                              widget.vocabInfo.definition=translation;

                            });
                          }, child: Text("Translate to "+translationLanguage)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          OutlinedButton(onPressed: wordLanguage!="English"?null: () {
                            _launchURL("https://en.wiktionary.org/wiki/"+wordController.text);
                          },
                              child:Text("Look up on Wikitionary >"))
                        ]

                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            OutlinedButton(onPressed: wordLanguage!="English"?null: () async {

                              String definition = await getDefinition(context, wordController.text);
                              setState(() {
                                widget.vocabInfo.word = wordController.text;
                                widget.vocabInfo.definition=definition;

                              });
                            },
                                child:Text("Get definition >"))
                          ]

                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text("Definition:", textAlign: TextAlign.left),
                      ),

                      TextFormField(
                          controller: definitionController,
                          decoration: InputDecoration(border: OutlineInputBorder()),
                          minLines: 3, // any number you need (It works as the rows for the textarea)
                          keyboardType: TextInputType.multiline,
                          maxLines: null
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[

                            OutlinedButton.icon(
                              onPressed: () async {
                                if (!definitionController.text.isEmpty) {
                                  final prefs = await SharedPreferences.getInstance();

                                  String ttsLanguage = prefs.getString("translationTTS")!;

                                  String ttsCode = getLanguageCodeForTTS(ttsLanguage);
                                  print("ttsLanguage: "+ttsLanguage);
                                  print("ttsCode: "+ttsCode);

                                  doTalking(context, ttsCode, definitionController.text);

                                }

                              },
                              icon: Icon(
                                Icons.volume_up,
                                size: 24.0,
                              ),
                              label: Text("Pronounce in "+translationTTS),
                            )

                          ]),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                          children: <Widget>[
                        ElevatedButton(
                            child: const Text('OK'),
                            onPressed: () async {
                              String word = wordController.text;
                              String definition = definitionController.text;
                              VocabListController c = VocabListController();

                              bool validateResult = await validate(c,widget.vocabInfo.word,word);
                              if (!validateResult) return;

                              if (widget.vocabInfo.id == 0) {
                                //print("insert new word: " + word + " defn: " + definition);
                                VocabInfo newVocab = new VocabInfo(
                                    id: null, word: word, definition: definition);

                                c.insertVocabulary(widget.db, newVocab);
                              } else {
                                //print("edit word " + widget.vocabInfo.id.toString());
                                VocabInfo editVocabInfo = new VocabInfo(
                                    id: widget.vocabInfo.id, word: word, definition: definition);
                                // check if word exist already
                                c.updateVocabulary(widget.db, editVocabInfo);
                              }

                              Navigator.pop(context, 'Ok');
                            }),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        )
                      ])
                    ])


            )
        ),


    );
  }
}


void _launchURL(String _url) async {
  if (!await launch(_url)) {
    throw 'Could not launch $_url';
  }
}

String bingLangCode(String language) {
  String langCode = "en";
  if (language=="Spanish")
    langCode = "es";
  if (language=="French")
    langCode = "fr";
  if (language=="Simplified Chinese")
    langCode = "zh-CHS"; // bing
  if (language=="Traditional Chinese")
    langCode = "zh-CHT"; // bing
  return langCode;
}

Future<String> getTranslation(BuildContext context, String word, String fromLanguage, String toLanguage) async {
  String url = translateAPI+"&from="+bingLangCode(fromLanguage)+"&to="+bingLangCode(toLanguage)+"&text="+word;
  print("url:"+url);

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      String bingResult = response.body;
      String translatedText = "";
      if (bingResult.indexOf(translateAPIResultPrefix) >= 0) {
        translatedText = bingResult.substring(
            translateAPIResultPrefix.length + 2, bingResult.length - 3);
      }
      else {
        translatedText = bingResult;
      }
      //print("translation: "+translatedText);
      return translatedText;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      showToast(context, "Sorry, cannot get translation");
      throw Exception('Failed to call translation API');
    }
  } catch (Exception) {
    print("can't get translation: "+url);
    showToast(context, "Sorry, cannot get translation");
    throw Exception;
  }
}

Future<String> getDefinition(BuildContext context, String word) async {
  String url = dictionaryAPI+word;

  print("url:"+url);

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      String receivedJson = response.body;
      List<dynamic> list = json.decode(receivedJson);
      //print("word is: "+list[0]['word']);
      dynamic meaning1  = list[0]['meanings'][0];
      //print("meaning1: "+meaning1.toString());
      dynamic def1 = meaning1['definitions'][0]['definition'];
      //print("def1: "+def1.toString());
      //[0]['definition'][0]['definition'];
      //print("def1: "+def1);

      return def1;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      showToast(context, "Sorry, cannot get definition");
      throw Exception('Failed to call defintion API');
    }
  } catch (Exception) {
    print("can't get definition: "+url);
    showToast(context, "Sorry, cannot get defintion");
    throw Exception;
  }

}