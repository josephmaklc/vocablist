import 'package:flutter/material.dart';
import 'package:vocablist2/db/model/VocabInfo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'db/controller/vocabListController.dart';
import 'toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String translateAPI = "http://api.microsofttranslator.com/V2/Ajax.svc/Translate?oncomplete=mycallback&appId=B3E6A7DFAC5FC07CFFD6496F5F79012228A35E86";
const String translateAPIResultPrefix = "mycallback";
const String defaultLanguagePref = "Traditional Chinese";

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

      widget.languagePref=prefs.getString("translationLanguage") ?? defaultLanguagePref;
      //widget.languagePref = (prefs.getString('languagePref') ?? defaultLanguagePref);
    });
  }

  // https://cloud.google.com/text-to-speech/docs/voices
  String getLanguageCodeForTTS(String ttsDescription) {
    if (ttsDescription=='English UK') return "en-GB";
    if (ttsDescription=='English US') return "en-US";
    if (ttsDescription=='French') return "fr-FR";
    if (ttsDescription=='Spanish') return "es-ES";
    if (ttsDescription=='Mandarin Chinese') return "zh-CN";
    if (ttsDescription=='Cantonese Chinese') return "yue-HK";

    return "en-US";
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
                })
        ),

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
                            TextButton(onPressed: () async {

                              if (!wordController.text.isEmpty) {

                                final prefs = await SharedPreferences.getInstance();
                                String ttsLanguage = prefs.getString("wordTTS")!;
                                String ttsCode = getLanguageCodeForTTS(ttsLanguage);
                                print("ttsLanguage: "+ttsLanguage);
                                print("ttsCode: "+ttsCode);

                                doTalking(context, ttsCode,wordController.text);


                              }
                            },
                                child:Text("Pronounce in "+wordTTS)),
                            TextButton(onPressed: () {
                              _launchURL("https://en.wiktionary.org/wiki/"+wordController.text);
                            },
                                child:Text("Definition on Web >"))

                          ]

                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[


                          ElevatedButton(onPressed: () async {
                            //print("translate");
                            String translation = await getTranslation(context, wordController.text,widget.languagePref);

                            setState(() {
                              widget.vocabInfo.word = wordController.text;
                              widget.vocabInfo.definition=translation;

                            });
                          }, child: Text("Translate to "+widget.languagePref)),
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
                            TextButton(onPressed: () async {


                              if (!definitionController.text.isEmpty) {
                                final prefs = await SharedPreferences.getInstance();

                                String ttsLanguage = prefs.getString("translationTTS")!;

                                String ttsCode = getLanguageCodeForTTS(ttsLanguage);
                                print("ttsLanguage: "+ttsLanguage);
                                print("ttsCode: "+ttsCode);

                                doTalking(context, ttsCode, definitionController.text);

                              }

                            }, child: Text("Pronounce in "+translationTTS)),
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

void doTalking(BuildContext context,String ttsCode, String text) async {
  try {
    FlutterTts fluttertts = FlutterTts();

    fluttertts.setStartHandler(() {
      print("playing");
    });
    fluttertts.setErrorHandler((message) { print("error: "+message); });
    bool available = await fluttertts.isLanguageAvailable(ttsCode);
    if (!available) {
      showToast(context, "Sorry Text To Speech for "+ttsCode+" not available");
    }
    else {
      //fluttertts.setLanguage(ttsCode);

      print("speaking: "+text);
      fluttertts.speak(text);
    }

  } on Exception catch (exception) {
    // only executed if error is of type Exception
    print("Exception! "+exception.toString());
  } catch (error) {
    // executed for errors of all types other than Exception
    print("Error! "+error.toString());
  }

}

void _launchURL(String _url) async {
  if (!await launch(_url)) {
    throw 'Could not launch $_url';
  }
}

Future<String> getTranslation(BuildContext context, String word, String language) async {
  String langCode = "en";
  if (language=="Spanish")
    langCode = "es";
  if (language=="French")
    langCode = "fr";
  if (language=="Simplified Chinese")
    langCode = "zh-CHS"; // bing
  if (language=="Traditional Chinese")
    langCode = "zh-CHT"; // bing

  String url = translateAPI+"&from=en&to="+langCode+"&text="+word;
//  print("url:"+url);

  try {
    final response = await http
        .get(Uri.parse(url));

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