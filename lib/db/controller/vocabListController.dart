import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/VocabInfo.dart';

class VocabListController {


  Future<Database> initVocabularyTable() async {
//    print("init chapters table");
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();

    //print("dbPath: " + await getDatabasesPath());
    // Open the database and store the reference.
    var database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'vocablist_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        print("on create...");
        return db.execute(
          'CREATE TABLE vocabulary(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, word TEXT, definition TEXT) ',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    return database;
  }

  Future<void> clearVocabListTable(var db) async {
    print("clear vocabulary table");
    try {
      db.execute("DROP TABLE vocabulary");
      db.execute(
          'CREATE TABLE vocabulary(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, word TEXT, definition TEXT) ');
    } catch (e) {
      print(e.toString());
    }
  }

  // Define a function that insert chapter into the database
  Future<void> insertVocabulary(var db,VocabInfo vocabInfo) async {

    print("inserting vocab: "+vocabInfo.toString());
    await db.insert(
      'vocabulary',
      vocabInfo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getAllVocabularyWords(var db) async {
    // Get a reference to the database.

    List<Map<String, dynamic>> maps = await db.rawQuery("SELECT * FROM vocabulary ORDER BY word");

    List<VocabInfo> vocabList = List.generate(maps.length, (i) {
      return VocabInfo(
          id: maps[i]['id'],
          word: maps[i]['word'],
          definition: maps[i]['definition']
      );
    });

    List<String> result = <String>[];
    for(VocabInfo v in vocabList) {
      result.add(v.word);
    }
    return result;
  }

  // A method that retrieves all chapters
  Future<List<VocabInfo>> getAllVocabulary(var db) async {
    // Get a reference to the database.

    final List<Map<String, dynamic>> maps = await db.query('vocabulary',orderBy: "word");

    var result = List.generate(maps.length, (i) {
      return VocabInfo(
          id: maps[i]['id'],
          word: maps[i]['word'],
          definition: maps[i]['definition']

      );
    });
/*
    print("all vocab");
    print("---------");
    for (VocabInfo v in result) {
      print(v);
    }

 */
    return result;
  }

  Future<VocabInfo> getWord(var db, int i) async {
    //print("Trying to get chapter... "+i.toString()+" language="+language);
    try {
      List<Map> result = await db.rawQuery("SELECT * FROM vocabulary WHERE id=?",[i]);

      return VocabInfo(
          id: result[0]['id'],
          word: result[0]['word'],
          definition: result[0]['definition'],

      ); }
    catch (e) {
      print ("Error getWord: "+e.toString());
      return VocabInfo(id:i,word:'bad',definition:'badbad');
    }
  }

  Future<void> updateVocabulary(var db,VocabInfo vocabInfo) async {
    // Get a reference to the database.

    // Update the given Dog.
    await db.update(
      'vocabulary',
      vocabInfo.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      whereArgs: [vocabInfo.id],
    );
  }

  Future<void> deleteWord(var db,int id) async {
    // Get a reference to the database.

    // Remove the Dog from the database.
    await db.delete(
      'vocabulary',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}