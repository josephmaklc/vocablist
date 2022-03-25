import 'package:flutter/material.dart';

class ConfigInfo {
  String wordLanguage;
  String wordTTS;
  String translationLanguage;
  String translationTTS;

  ConfigInfo(this.wordLanguage, this.wordTTS, this.translationLanguage,
      this.translationTTS);
}

List<String> availableLanguages = <String>[
  'English',
  'Spanish',
  'French',
  'Traditional Chinese',
  'Simplified Chinese'
];

List<String> getTTSForLanguage(String language) {
  if (language == "English") {
    return <String>['English US (Female)', 'English US (Male)', 'English UK (Female)','English UK (Male)'];
  }
  if (language == "Spanish") {
    return <String>['Spanish (Female)', 'Spanish (Male)'];
  }
  if (language == "French") return <String>['French (Female)', 'French (Male)'];

  if (language == "Traditional Chinese" || language == "Simplified Chinese") {
    return <String>[
      'Mandarin Chinese (Female)',
      'Mandarin Chinese (Male)',
      'Cantonese Chinese (Female)',
      'Cantonese Chinese (Male)'
    ];
  }
  return <String>['Not available'];
}

String getDefaultTTSForLanguage(String language) {
  if (language == "English") return 'English US (Female)';
  if (language == "Spanish") return 'Spanish (Female)';
  if (language == "French") return 'French (Female)';
  if (language == "Traditional Chinese" || language == "Simplified Chinese") {
    return 'Cantonese Chinese (Female)';
  }
  return 'English US (Female)';
}

Future<ConfigInfo> showConfigurationDialog(
    BuildContext context,
    String wordLanguage,
    String wordTTS,
    String translationLanguage,
    String translationTTS) async {
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Settings', textAlign: TextAlign.center),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            const Text("Vocabulary",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(""),
            const Text("Language"),

            DropdownButton<String>(
                value: wordLanguage,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    wordLanguage = newValue!;
                    wordTTS = getDefaultTTSForLanguage(wordLanguage);
                  });
                },
                items: availableLanguages
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList()),
            const Text("Text to Speech"),
            DropdownButton<String>(
                value: wordTTS,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    wordTTS = newValue!;
                  });
                },
                items: getTTSForLanguage(wordLanguage)
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList()),
            const Text(""),
            const Text("Translation",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(""),
            const Text("Language"),
            DropdownButton<String>(
                value: translationLanguage,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    translationLanguage = newValue!;
                    translationTTS = getDefaultTTSForLanguage(translationLanguage);
                  });
                },
                items: availableLanguages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList()),
            const Text("Text to Speech"),
            DropdownButton<String>(
                value: translationTTS,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    translationTTS = newValue!;
                  });
                },
                items: getTTSForLanguage(translationLanguage).map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList())
          ])),
          actions: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              TextButton(
                  child: const Text('OK'),
                  onPressed: () {
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
  return ConfigInfo(wordLanguage, wordTTS, translationLanguage, translationTTS);
}
