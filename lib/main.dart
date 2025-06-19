import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hangman/screens/DashBoeard.dart';
import 'package:flutter_hangman/screens/Splash_Screen1.dart';
import 'package:flutter_hangman/screens/score_screen.dart';
import 'package:flutter_hangman/utilities/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize sqflite for all platforms


  print("🔄 Initializing Firebase...");

  if (Firebase.apps.isEmpty) {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyCkaerJ_lYP7ubFk1SQf2jvjuDdAXyC2Ak',
            appId: '1:568972077157:web:fa0babb05765507cc1be8c',
            messagingSenderId: "568972077157",
            authDomain: "wordscue-f227f.firebaseapp.com",
            databaseURL: "https://wordscue-f227f-default-rtdb.firebaseio.com",
            projectId: "wordscue-f227f",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
      print("✅ Firebase initialized");
      await uploadWordsToFirebase();
    } catch (e) {
      print("❌ Firebase error: $e");
    }
  }

  print("🚀 Running app...");
  runApp(const MainApp());
}
Future<void> uploadWordsToFirebase() async {
  final dbRef = FirebaseDatabase.instance.ref();

  Map<String, Map<String, List<String>>> wordData =
  {
    'beginner': {
      'gk': ["quiz", "lynx", "grip", "twig", "myth", "brim", "scrub", "clump", "flint", "brawn"],
      'science_and_nature': ["smog", "bark", "grub", "clod", "sprig", "glow", "crust", "flask", "drift", "silt"],
      'history_and_politics':
      ["flag", "coup", "deed", "law", "helm",
        "clan", "plot", "vow", "realm", "oath"],
      'sports_and_games': ["grip", "vault", "puck", "judo", "track", "blitz", "toss", "jump", "dunk", "dash"],
      'geography_and_travel': ["ridge", "trail", "fjord", "camp", "cliff", "path", "crag", "glade", "brook", "bluff"],
      'music_and_pop_culture': ["pop", "jam", "hymn", "riff", "drum", "bass", "loop", "note", "beat", "song"],
      'movies_and_tv_shows': ["clip", "zoom", "grim", "prop", "cut", "take", "edit", "cast", "plot", "set"],
      'literature_and_books': ["text", "line", "book", "read", "plot", "pen", "note", "page", "word", "tale"],
      'tech_and_creativity': ["code", "bot", "ping", "web", "hack", "site", "link", "tool", "bit", "data"],
    },
    'easy': {
      'gk': ["crest", "badge", "globe", "realm", "chart", "bluff", "prong", "stunt", "plumb", "trunk"],
      'science_and_nature': ["plant", "cliff", "drift", "flint", "cloud", "bloom", "stone", "smoke", "flask", "spore"],
      'history_and_politics': ["council", "speech", "troops", "empire", "ruling", "edict", "banner", "summon", "scribe", "throne"],
      'sports_and_games': ["striker", "vault", "rally", "tackle", "crunch", "tennis", "match", "jockey", "skater", "paddle"],
      'geography_and_travel': ["summit", "island", "travel", "cliffs", "border", "valley", "terrain", "bridge", "hills", "coast"],
      'music_and_pop_culture': ["lyrics", "beats", "chorus", "solo", "hymnal", "concert", "note", "jammer", "guitar", "remix"],
      'movies_and_tv_shows': ["screen", "acting", "ending", "cinema", "script", "comedy", "scene", "trailer", "dialog", "actor"],
      'literature_and_books': ["author", "reader", "chapter", "fiction", "library", "story", "volume", "poetry", "tale", "essay"],
      'tech_and_creativity': ["widget", "binary", "device", "prompt", "system", "plugin", "output", "upload", "script", "module"],
    },
    'medium': {
      'gk': ["ballot", "verdict", "govern", "reform", "citizen", "pledge", "justice", "notion", "mandate", "resolve"],
      'science_and_nature': ["gravity", "climate", "volcano", "reaction", "protein", "molecule", "weather", "biology", "element", "erosion"],
      'history_and_politics': ["treaty", "revolt", "freedom", "dynasty", "colony", "uprising", "edict", "campaign", "tribunal", "doctrine"],
      'sports_and_games': ["champion", "ranking", "rebound", "athletics", "tourney", "stadium", "dribble", "scoring", "equipment", "defense"],
      'geography_and_travel': ["province", "longitude", "latitude", "summit", "terrain", "volcano", "glacier", "coastal", "elevation", "region"],
      'music_and_pop_culture': ["symphony", "playlist", "composer", "festival", "concert", "lyrical", "choruses", "notated", "backbeat", "melodic"],
      'movies_and_tv_shows': ["animation", "premiere", "narrative", "dialogue", "director", "cinematic", "sequence", "actoring", "editing", "subplot"],
      'literature_and_books': ["fable", "prologue", "manuscript", "narrative", "symbolic", "contextual", "passages", "dialogue", "lexicon", "essays"],
      'tech_and_creativity': ["compiler", "protocol", "framework", "interface", "debugger", "backend", "database", "frontend", "algorithm", "concepts"],
    },
    'hard': {
      'gk': ["pluralism", "jurisdict", "sovereign", "diplomacy", "amendment", "manifesto", "republics", "legislate", "democracy", "principle"],
      'science_and_nature': ["organisms", "genetics", "reaction", "radioactive", "photosynth", "biomass", "spectrums", "enzymatic", "radiation", "neutrinos"],
      'history_and_politics': ["aristocrat", "enlighten", "propaganda", "emancipate", "constitution", "revolution", "colonized", "treatises", "federalism", "inquisition"],
      'sports_and_games': ["triathlon", "strategist", "precision", "gymnastic", "scrimmage", "freestyle", "champions", "synchronized", "reflexive", "tactician"],
      'geography_and_travel': ["archipelago", "cartograph", "topography", "altimeter", "hydrology", "tectonics", "demography", "landscape", "elevation", "geopolitics"],
      'music_and_pop_culture': ["polyphony", "syncopate", "orchestra", "notation", "dissonant", "audiogram", "conducted", "discograph", "multitrack", "resonance"],
      'movies_and_tv_shows': ["adaptation", "cinematics", "foreshadow", "subtitles", "characterize", "animation", "tragedian", "reminiscence", "screenplay", "narratives"],
      'literature_and_books': ["satirical", "metaphors", "protagonist", "postmodern", "allegoric", "intertext", "symbolism", "persona", "lexicology", "narrative"],
      'tech_and_creativity': ["encryption", "blockchain", "interface", "cybernetic", "framework", "neuralnet", "algorithm", "protocol", "compiler", "debugging"],
    },
  };

  try {
    await dbRef.child("words").set(wordData);
    print("✅ Words uploaded successfully.");
  } catch (e) {
    print("❌ Failed to upload words: $e");
  }
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       home: SplashScreen(),
      //home: Dashboeard(),

      theme: ThemeData.dark().copyWith(
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: kTooltipColor,
            borderRadius: BorderRadius.circular(5.0),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),

        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'PatrickHand'),
      ),

    );
  }
}
