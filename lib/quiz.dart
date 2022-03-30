import 'package:flutter/material.dart';

import 'db/model/VocabInfo.dart';

enum SingingCharacter { lafayette, jefferson }

class QuizForm extends StatefulWidget {
  List<VocabInfo> vocabList;

  QuizForm({Key? key, required this.vocabList}) : super(key: key);

  @override
  State<QuizForm> createState() => _QuizFormState();
}

class _QuizFormState extends State<QuizForm> {
  SingingCharacter? _character = SingingCharacter.lafayette;

  @override
  Widget build(BuildContext context) {

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
                ListTile(
                  title: const Text('Lafayette'),
                  leading: Radio<SingingCharacter>(
                    value: SingingCharacter.lafayette,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Thomas Jefferson'),
                  leading: Radio<SingingCharacter>(
                    value: SingingCharacter.jefferson,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                ),
              ],
            ))
    ));
  }
}