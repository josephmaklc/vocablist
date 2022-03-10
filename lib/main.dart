import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vocablist2/aboutDialog.dart';
import 'package:vocablist2/areYouSureDialog.dart';
import 'db/controller/vocabListController.dart';
import 'db/model/VocabInfo.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';

import 'editVocabDialog.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

List<VocabInfo> vocabList = [];
class _MyAppState extends State<MyApp> {

  String title=appTitle;
  double fontSize=20;

  @override
  void initState() {
    super.initState();
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

  final FlutterTts tts = FlutterTts();
  Scaffold vocabListScaffold(BuildContext context, List<VocabInfo> vocabList) {
    return Scaffold(
        appBar: AppBar(

            title: Text(title),
            actions: [
              /*IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'About',
                onPressed: () => {
                      myShowAboutDialog(context, appTitle, author, version, appDate)
                },
              )
              */
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    print("search");
                  })

            ]
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
                trailing: Wrap(

                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.hearing,
                      ),
                      onPressed: () async {
                        tts.speak(vocabList[index].word);

                      }, // Handle your onTap here.
                    ), // icon-1

                    IconButton(
                      icon: Icon(
                        Icons.edit,
                      ),
                      onPressed: () async {
                        await showVocabularyDialog(context, db, tts, vocabList[index]);
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
         await showVocabularyDialog(context, db, tts, new VocabInfo(id: 0, word: "", definition: ""));
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


    return await c.getAllVocabulary(db);

  }
}