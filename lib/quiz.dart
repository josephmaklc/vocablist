import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vocablist2/toast.dart';

import 'db/model/VocabInfo.dart';

class QuizForm extends StatefulWidget {
  List<VocabInfo> vocabList;

  QuizForm({Key? key, required this.vocabList}) : super(key: key);

  @override
  State<QuizForm> createState() => _QuizFormState();
}

class QuizQuestion {
  String text="";
  List<String> choice = ['','','',''];
  int correct=0;
  String userAnswered="";
}

class _QuizFormState extends State<QuizForm> {

  //String choiceSelection="";
  int whereAt=0;

  int score=0;
  Random random = new Random();

  List<String> getWrongChoices(List<VocabInfo> wordList, String correctWord) {

    List<VocabInfo> mixupList= [];
    mixupList.addAll(wordList);

    mixupList.shuffle();

    List<String> result = [];
    for (VocabInfo v in mixupList) {
      if (v.word==correctWord) continue;
      result.add(v.definition);
      if (result.length==3) break;
    }
    return result;

  }

  Future<List<QuizQuestion>> _getThingsOnStartup() async {

    if (quizList.length>0) return quizList;
    print("do Init");

    List<QuizQuestion> questions = [];

    int i=0;
    for (VocabInfo v in widget.vocabList) {
      QuizQuestion q = new QuizQuestion();
      q.text=v.word;
      q.correct = random.nextInt(4);
      List<String> wrongChoices = getWrongChoices(widget.vocabList,v.word);

      int k=0;
      for (int j=0; j < 4; j++) {
        if (j==q.correct) q.choice[j] = v.definition;
        else {
          q.choice[j] = wrongChoices[k];
          k++;
        }
      }


      //print("adding word: "+q.text);
      questions.add(q);
      i++;
    }
    questions.shuffle();

    for (QuizQuestion q in questions) {
      print("question text: "+q.text);
      print("correct: "+q.correct.toString());
      for (String c in q.choice) {
        print("choice: "+c);
      }
      print("------------");
    }
    return questions;
  }

  List<QuizQuestion> quizList = [];
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuizQuestion>>(
        future: _getThingsOnStartup(),
        builder: (context, AsyncSnapshot<List<QuizQuestion>> snapshot) {
          if (snapshot.hasData) {
            quizList = snapshot.data!;
            return quizScaffold(context, quizList);
          } else {
            return const CircularProgressIndicator();
          }
        }
    );
  }

  Scaffold quizScaffold(BuildContext context, List<QuizQuestion> quizList) {
    QuizQuestion question = quizList[whereAt];
    return Scaffold(
        appBar:
        AppBar(title: Text("Quiz"),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body:
        Container(
            padding: const EdgeInsets.all(12.0),

            child: SingleChildScrollView(
                child:
                Column(
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text((whereAt + 1).toString() + ": " + question.text,
                                style:TextStyle(fontSize:20))
                         ]
                      ),
                      ListTile(
                        title: Text(question.choice[0]),
                        leading: Radio<String>(
                          value: question.choice[0],
                          groupValue: question.userAnswered,
                          onChanged: (String? value) {
                            setState(() {
                              question.userAnswered = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(question.choice[1]),
                        leading: Radio<String>(
                          value: question.choice[1],
                          groupValue: question.userAnswered,
                          onChanged: (String? value) {
                            setState(() {
                              question.userAnswered = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(question.choice[2]),
                        leading: Radio<String>(
                          value: question.choice[2],
                          groupValue: question.userAnswered,
                          onChanged: (String? value) {
                            setState(() {
                              question.userAnswered = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(question.choice[3]),
                        leading: Radio<String>(
                          value: question.choice[3],
                          groupValue: question.userAnswered,
                          onChanged: (String? value) {
                            setState(() {
                              question.userAnswered = value!;
                            });
                          },
                        ),
                      ),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [

                            ElevatedButton(onPressed: () {
                              setState(() {
                                if (whereAt == 0)
                                  showToast(context,
                                      "Cannot go previous question");
                                else {
                                  whereAt--;
                                  print("whereAt=" + whereAt.toString());
                                }
                              });
                            }, child: Text("<")),

                            ElevatedButton(onPressed: () {
                              print("check choice");
                              //print("selected: "+choiceSelection+" correct answer: "+question.correct.toString());
                              setState(() {
                                if (whereAt == quizList.length - 1) {
                                  showToast(context, "Game over");
                                  return;
                                }
                                //if (choiceSelection==question.correct) score++;
                                whereAt++;
                                print("whereAt=" + whereAt.toString() +
                                    " score: " + score.toString());
                              });
                            }, child: Text(">"))
                          ])
                    ]))));
  }
}