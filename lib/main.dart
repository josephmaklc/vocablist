import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vocablist2/aboutDialog.dart';
import 'package:vocablist2/areYouSureDialog.dart';
import 'package:vocablist2/flashCardForm.dart';
import 'package:vocablist2/quiz.dart';
import 'package:vocablist2/toast.dart';
import 'package:vocablist2/vocabForm.dart';
import 'package:vocablist2/wordCardDialog.dart';
import 'db/controller/vocabListController.dart';
import 'db/model/VocabInfo.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

import 'configDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String appTitle = "Vocabulary List";
const String author = "Joseph Mak";
const String version = "v 2.0";
const String appDate = "March 7, 2022";

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: MyApp(),
    ),
  );
}

class Constants{
  static const String FLASH_CARDS= 'Flash Cards';
  static const String QUIZ = 'Quiz';
  static const String SETTINGS = 'Settings';

  static const List<String> choices = <String>[
      FLASH_CARDS, QUIZ, SETTINGS
  ];
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

List<VocabInfo> vocabList = [];
class _MyAppState extends State<MyApp> {

  String title=appTitle;
  double fontSize=20;

  String wordLanguage="English", wordTTS="English US";
  String translationLanguage="Traditional Chinese", translationTTS="Cantonese Chinese";

  @override
  void initState() {
    super.initState();
    _doInit();
  }

  void _doInit() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      wordLanguage = (prefs.getString('wordLanguage') ?? "English");
      wordTTS = (prefs.getString('wordTTS') ?? "English US");
      translationLanguage = (prefs.getString('translationLanguage') ?? "Traditional Chinese");
      translationTTS = (prefs.getString('translationTTS') ?? "Cantonese Chinese");

    });
  }

  @override
  Widget build(BuildContext context) {

    // initialize database. This FutureBuilder will call a _getThingsOnStartup,
    // once done, return the scaffold widget, before then, show the progress indicator
    return FutureBuilder<List<VocabInfo>>(
        future: _getThingsOnStartup(),
        builder: (context, AsyncSnapshot<List<VocabInfo>> snapshot) {
          if (snapshot.hasData) {
            vocabList = snapshot.data as List<VocabInfo>;

            return vocabListScaffold(context,vocabList);
          } else {
            return const CircularProgressIndicator();
          }
        }
    );

  }

  void choiceAction(String choice) async{
    if(choice == Constants.FLASH_CARDS){
      showToast(context,"Tap on card to flip card, swipe for another card");

      await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FlashCardWidget(vocabList: vocabList)));
    }
    else if(choice == Constants.QUIZ) {

      await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizForm(vocabList: vocabList)));
    }
    else if(choice== Constants.SETTINGS) {
      ConfigInfo result = await showConfigurationDialog(context, wordLanguage, wordTTS, translationLanguage, translationTTS);
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        wordLanguage = result.wordLanguage;
        wordTTS = result.wordTTS;
        translationLanguage = result.translationLanguage;
        translationTTS = result.translationTTS;
        prefs.setString("wordLanguage",wordLanguage);
        prefs.setString("wordTTS",wordTTS);
        prefs.setString("translationLanguage",translationLanguage);
        prefs.setString("translationTTS",translationTTS);
      });
      Navigator.pop(context);
    }
  }

  bool determineChoiceAvailable(String choice) {
    if (choice==Constants.QUIZ) return vocabList.length>3;
    return true;
  }

  Scaffold vocabListScaffold(BuildContext context, List<VocabInfo> vocabList) {

    return Scaffold(
        appBar: AppBar(

            title: Text(title),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext context){
                return Constants.choices.map((String choice){
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                    enabled: determineChoiceAvailable(choice),

                  );
                })
                    .toList();
              }
              ,)]
          ),


        drawer:
        Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[

              DrawerHeader(
                child: Text(title,style: TextStyle(color: Colors.white,fontSize:fontSize)),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),


/*              ListTile(
                leading: const Icon(Icons.note_outlined),
                title: Text('Flash Cards',style:TextStyle(fontSize: fontSize)),
                enabled: vocabList.length>0,
                onTap: () async {
                  //flashCardDialog(context, tts, vocabList);
                  showToast(context,"Tap on card to flip card, swipe for another card");

                  await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FlashCardWidget(vocabList: vocabList)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: Text('Quiz',style:TextStyle(fontSize: fontSize)),
                enabled: vocabList.length>3,
                onTap: () async {

                  await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizForm(vocabList: vocabList)));
                },
              ),
              ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text('Settings',style:TextStyle(fontSize: fontSize)),
                  onTap: () async {
                    ConfigInfo result = await showConfigurationDialog(context, wordLanguage, wordTTS, translationLanguage, translationTTS);
                    final prefs = await SharedPreferences.getInstance();

                    setState(() {
                      wordLanguage = result.wordLanguage;
                      wordTTS = result.wordTTS;
                      translationLanguage = result.translationLanguage;
                      translationTTS = result.translationTTS;
                      prefs.setString("wordLanguage",wordLanguage);
                      prefs.setString("wordTTS",wordTTS);
                      prefs.setString("translationLanguage",translationLanguage);
                      prefs.setString("translationTTS",translationTTS);
                    });


                    Navigator.pop(context);
                  }

              ),*/
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text('About',style:TextStyle(fontSize: fontSize)),
                onTap: () {
                  myShowAboutDialog(context, appTitle, author, version, appDate);
                },
              ),

            ],
          ),
        ),

        body:
        ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.black,
          ),
          itemCount: vocabList.length,
          itemBuilder: (context, index) {

            ListTile item = ListTile(


                title: Text(vocabList[index].word,style:TextStyle(fontSize: fontSize)),
                onTap: () {
                  wordCardDialog(context, vocabList[index]);
                },
                trailing: Wrap(

                  children: <Widget>[

                    IconButton(
                      icon: Icon(
                        Icons.edit,
                      ),
                      onPressed: () async {
                        //await showVocabularyDialog(context, db, tts, vocabList[index]);

                        await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VocabForm(vocabInfo: vocabList[index], db: db)));

                        var refreshedList=await _getThingsOnStartup();
                        setState(() {
                          vocabList=refreshedList;
                        });

                      }, // Handle your onTap here.
                    ), // icon-1
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                      ),
                      onPressed: () async {
                        bool reallyDelete = await areYouSureDialog(context, "Delete Word","Are you sure to delete '"+vocabList[index].word+"'?");
                        if (reallyDelete) {
                          VocabListController c = VocabListController();
                          c.deleteWord(db, vocabList[index].id!);
                          var refreshedList = await _getThingsOnStartup();
                          setState(() {
                            vocabList = refreshedList;
                          });
                        }


                      }, // Handle your onTap here.
                    )
                  ],
                )
            );
            return item;
          },
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            //await showVocabularyDialog(context, db, tts, new VocabInfo(id: 0, word: "", definition: ""));
            await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VocabForm(vocabInfo:  new VocabInfo(id: 0, word: "", definition: ""), db: db)));

            var refreshedList=await _getThingsOnStartup();
            setState(() {
              vocabList=refreshedList;
            });


          },
          child: const Icon(Icons.add),
        )

    );
  }



  Future<String> loadAsset(String name) async {
//    print("trying to load asset: "+name);
    try {
      return await rootBundle.loadString(name);
    }
    catch (e) {
      print ("exception: "+e.toString());
      return "cannot load file: "+name;
    }
  }

  late Database db;
  Future<List<VocabInfo>> _getThingsOnStartup() async {

    //print("getThingsOnStartup");

    VocabListController c = VocabListController();
    db = await c.initVocabularyTable();

    //await c.clearVocabListTable(db);


    List<VocabInfo> result = await c.getAllVocabulary(db);
//    if (result.isEmpty) {
//      showToast(context, "Use Add button to add some words");
//    }

    return result;


  }
}