import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TTS Experiments',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final FlutterTts _flutterTts = FlutterTts();
  List languages;
  String language;
  List voices;
  double speechRate;
  double pitch;

  String text = "";
  bool playing;

  @override
  void initState() {
    super.initState();
    initFlutterTts();
  }

  initFlutterTts() async {
    language = 'en-US';
    speechRate = 1.0;
    pitch = 1.0;
    playing = false;
    languages = await _flutterTts.getLanguages;
    voices = await _flutterTts.getVoices;
    _flutterTts.setCompletionHandler(() {
      setState(() {
        playing = false;
      });
    });
  }

  _play() async {
    if (text == null) return;
    var result = await _flutterTts.speak(text);
    if (result == 1)
      setState(() {
        playing = true;
      });
  }

  _stop() async {
    var result = await _flutterTts.stop();
    if (result == 1)
      setState(() {
        playing = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Flutter TTS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "enter text to read"),
              onChanged: (value) {
                setState(() {
                  text = value;
                });
              },
            ),
            RaisedButton.icon(
              label: Text(playing ? "Stop Playing" : "Start Playing"),
              icon: Icon(playing
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled),
              onPressed: text.isEmpty ? null : playing ? _stop : _play,
            ),
            Divider(),
            ListTile(
              title: Text("Settings"),
              subtitle: Text("change language, pitch, voice..."),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: PopupMenuButton(
                enabled: !playing,
                child: Row(
                  children: <Widget>[
                    Text("Language: $language"),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_down)
                  ],
                ),
                initialValue: language,
                itemBuilder: (context) {
                  return languages
                      .map((lang) => PopupMenuItem(
                            child: Text(lang),
                            value: lang,
                          ))
                      .toList();
                },
                onSelected: (lang) async {
                  setState(() {
                    language = lang;
                  });
                  await _flutterTts.setLanguage(lang);
                },
              ),
            ),
            const SizedBox(height: 10.0),
            Divider(),
            Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Text("Speech Rate:  $speechRate")),
            Slider(
              value: speechRate,
              onChanged: playing ? null : (val) async {
                setState(() {
                  speechRate = val;
                });
                await _flutterTts.setSpeechRate(val);
              },
              max: 3.0,
              min: 0.5,
              divisions: 5,
              label: "$speechRate",
            ),
            const SizedBox(height: 10.0),
            Divider(),
            Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Text("Pitch: $pitch")),
            Slider(
              value: pitch,
              onChanged: playing ? null : (val) async {
                setState(() {
                  pitch = val;
                });
                await _flutterTts.setPitch(val);
              },
              max: 3.0,
              min: 0.5,
              divisions: 5,
              label: "$pitch",
            ),
          ],
        ),
      ),
    );
  }
}
