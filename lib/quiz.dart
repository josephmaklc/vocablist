import 'dart:math';

import 'package:flutter/material.dart';

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
  bool checkedAnswer=false;
}

class _QuizFormState extends State<QuizForm> {

  //String choiceSelection="";
  int whereAt=0;
  bool showScore = false;
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
    if (quizList.length > 0) return quizList;
    return initQuestions();
  }

  List<QuizQuestion> initQuestions() {

    List<QuizQuestion> questions = [];

    int i=0;
    for (VocabInfo v in widget.vocabList) {
      QuizQuestion q =  QuizQuestion();
      q.text=v.word;
      q.correct = random.nextInt(4);
      q.checkedAnswer=false;
      q.userAnswered="";
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
/*
    for (QuizQuestion q in questions) {
      print("question text: "+q.text);
      print("correct: "+q.correct.toString());
      print("checked: "+q.checkedAnswer.toString());
      for (String c in q.choice) {
        print("choice: "+c);
      }
      print("------------");
    }
*/
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

  Color _determineColor(QuizQuestion q, int choice) {
    if (!showScore) {
      if (!q.checkedAnswer) return Colors.white;
      if (q.userAnswered.isEmpty) return Colors.white;
    }
    if (q.correct==choice) return Colors.green;
    return Colors.white;
  }

  bool _disableCheckAnswer(QuizQuestion q) {
    if (q.checkedAnswer) return true;
    if (q.userAnswered.isEmpty) return true;
    return false;
  }

  String scorePct() {
    double pct = score*100/quizList.length;
    return pct.toStringAsFixed(2)+"%";
  }

  Scaffold quizScaffold(BuildContext context, List<QuizQuestion> quizList) {
    if (quizList.isEmpty) return new Scaffold();

    QuizQuestion question = quizList[whereAt];

    double grade = score/quizList.length;
    bool poorJob = grade < 0.5;
    bool goodJob = (grade >= 0.8 && grade < 1);
    bool perfect = grade==1;

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
                            Text((whereAt + 1).toString() + ": What's the meaning of '" + question.text+"'?",
                                style:TextStyle(fontSize:20))
                         ]
                      ),
                      RadioListTile(

                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: _determineColor(question,0)
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        title: Text(question.choice[0]),

                          value: question.choice[0],

                          groupValue: question.userAnswered,
                          onChanged: question.checkedAnswer?null: (String? value) {
                            setState(() {
                              question.userAnswered = value!;
                            });
                          },

                      ),
                      RadioListTile(

                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: _determineColor(question,1)
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        title: Text(question.choice[1]),

                        value: question.choice[1],

                        groupValue: question.userAnswered,
                        onChanged: question.checkedAnswer?null: (String? value) {
                          setState(() {
                            question.userAnswered = value!;
                          });
                        },

                      ),
                      RadioListTile(

                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: _determineColor(question,2)
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        title: Text(question.choice[2]),

                        value: question.choice[2],

                        groupValue: question.userAnswered,
                        onChanged: question.checkedAnswer?null: (String? value) {
                          setState(() {
                            question.userAnswered = value!;
                          });
                        },

                      ),
                      RadioListTile(

                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: _determineColor(question,3)
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        title: Text(question.choice[3]),

                        value: question.choice[3],

                        groupValue: question.userAnswered,
                        onChanged: question.checkedAnswer?null: (String? value) {
                          setState(() {
                            question.userAnswered = value!;
                          });
                        },

                      ),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [

                            ElevatedButton(onPressed: whereAt==0 ? null : () {

                              setState(() {
                                  whereAt--;
                                });

                            }, child: Text("<")),
                           /* ElevatedButton(
                                child: Text("Check Answer"),
                              onPressed: _disableCheckAnswer(question) ? null : () {

                                setState(() {
                                  question.checkedAnswer=true;
                                });
                                questionsAnswered++;

                              if (question.userAnswered==question.choice[question.correct]) {
                                showToast(context, "You are right!");
                                setState(() {
                                  score++;
                                });
                              }
                              else {
                                showToast(context, "Sorry, wrong answer");
                              }


                            }),*/
                            ElevatedButton(onPressed: whereAt == quizList.length - 1 ? null : () {
                              //print("selected: "+choiceSelection+" correct answer: "+question.correct.toString());
                              setState(() {
                                whereAt++;
                              });
                            }, child: Text(">"))
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[SizedBox(height: 50),]
                      ),
                      if (showScore==false) Row (
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                              ElevatedButton(

                              child: Text("Submit Answers"),
                              onPressed: () {

                                score=0;
                                setState(() {
                                  for (QuizQuestion q in quizList) {
                                    q.checkedAnswer = true;
                                    if (q.userAnswered == q.choice[q.correct]) score++;
                                  }
                                  showScore=true;

                              });
                              })
                          ]
                      ),
                      if (showScore) Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Text("End of Quiz",  style:TextStyle(fontSize:20)),
                          ]
                      ),
                      if (showScore) Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Text("\nScore: "+score.toString()+"/"+quizList.length.toString()+" "+scorePct(),  style:TextStyle(fontSize:20)),
                          ]
                      ),
                      if (showScore && poorJob) Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Text("\nYou can do better next time",  style:TextStyle(fontSize:20, color: Colors.amber)),
                          ]
                      ),
                      if (showScore && goodJob) Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Text("\nYou did a good job!",  style:TextStyle(fontSize:20, color: Colors.blue)),
                          ]
                      ),
                      if (showScore && perfect) Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Text("\nYou got a perfect score!",  style:TextStyle(fontSize:20, color: Colors.green)),
                          ]
                      ),
                      if (showScore) Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                                ElevatedButton(

                                child: Text("Try Again"),
                                onPressed: () {

                                  setState(()
                                  {
                                    quizList.clear();
                                    whereAt=0;
                                    showScore = false;
                                    score=0;
                                  });

                                })
                          ]
                      ),

                    ]))));
  }
}