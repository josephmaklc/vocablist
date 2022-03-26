
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocablist2/toast.dart';

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

void doTalking(BuildContext context,String ttsCode, String text) async {
  try {
    FlutterTts fluttertts = FlutterTts();

    /*
    fluttertts.setStartHandler(() {
      print("playing");
    });
    fluttertts.setErrorHandler((message) { print("error: "+message); });
    */
    print("ttsCode: "+ttsCode);
    if (ttsCode!=null) {
      bool available = await fluttertts.isLanguageAvailable(ttsCode);
      if (!available) {
        showToast(context, "Sorry Text To Speech for " + ttsCode + " not available");
      }
      else {
        fluttertts.setLanguage(ttsCode);
      }
    }
    print("speaking: "+text);
    fluttertts.speak(text);


  } on Exception catch (exception) {
    // only executed if error is of type Exception
    print("Exception! "+exception.toString());
  } catch (error) {
    // executed for errors of all types other than Exception
    print("Error! "+error.toString());
  }

}
