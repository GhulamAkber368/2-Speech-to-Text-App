import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextView extends StatefulWidget {
  const SpeechToTextView({super.key});

  @override
  State<SpeechToTextView> createState() => _SpeechToTextViewState();
}

class _SpeechToTextViewState extends State<SpeechToTextView> {
  bool startRecord = false;
  final SpeechToText speechToText = SpeechToText();
  bool isAvailable = false;
  String text = "Press the mic button to start recording speech";

  @override
  void initState() {
    super.initState();
    make();
  }

  Future<bool> make() async {
    // Request microphone permission
    var status = await Permission.microphone.request();

    if (status.isGranted) {
      isAvailable = await speechToText.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );
      return true;
    } else {
      print("Microphone permission not granted");
      isAvailable = false;
    }

    setState(() {});
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speech to Text"),
      ),
      body: SafeArea(
          child: Center(
              child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(text),
      ))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: AvatarGlow(
          animate: startRecord,
          glowColor: Colors.purple,
          child: GestureDetector(
            onTapDown: (val) async {
              setState(() {
                startRecord = true;
              });
              print("Is Available: $isAvailable");
              isAvailable = await make();
              if (isAvailable) {
                speechToText.listen(
                  onResult: (result) {
                    setState(() {
                      print("Recogonize Words: ${result.recognizedWords}");
                      text = result.recognizedWords;
                      print("Text: $text");
                    });
                  },
                );
              }
            },
            onTapUp: (val) {
              setState(() {
                startRecord = false;
              });
              speechToText.stop();
            },
            child: FloatingActionButton(
                onPressed: null,
                child: Icon(startRecord ? Icons.mic : Icons.mic_none_rounded)),
          ),
        ),
      ),
    );
  }
}
