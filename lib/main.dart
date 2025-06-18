import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hangman/screens/DashBoeard.dart';
import 'package:flutter_hangman/screens/Splash_Screen1.dart';
import 'package:flutter_hangman/screens/home_screen.dart';
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

  Map<String, Map<String, List<String>>> wordData = {
    'beginner': {
      'gk': ["apple", "tree", "book", "pen", "clock", "sun", "rain", "map", "bus", "hat"],
      'science_and_nature': ["sun", "leaf", "atom", "plant", "rock", "wind", "snow", "water", "fire", "moon"],
      'history_and_politics': ["war", "king", "map", "law", "vote", "flag", "rule", "deed", "era", "code"],
      'sports_and_games': ["ball", "goal", "race", "run", "jump", "game", "team", "bat", "win", "play"],
      'geography_and_travel': ["hill", "river", "map", "road", "trip", "camp", "path", "city", "rail", "tent"],
      'music_and_pop_culture': ["song", "note", "beat", "band", "pop", "rap", "hit", "fan", "star", "rock"],
      'movies_and_tv_shows': ["film", "hero", "plot", "cast", "clip", "show", "set", "take", "reel", "edit"],
      'literature_and_books': ["book", "poem", "page", "line", "read", "text", "pen", "plot", "title", "write"],
      'tech_and_creativity': ["code", "app", "idea", "bot", "web", "tech", "tool", "game", "hack", "site"],
    },
    'easy': {
      'gk': ["nation", "leader", "globe", "region", "country", "capital", "event", "world", "news", "speech"],
      'science_and_nature': ["energy", "planet", "animal", "object", "earth", "system", "light", "force", "metal", "air"],
      'history_and_politics': ["empire", "battle", "revolt", "speech", "freedom", "civil", "council", "rule", "leader", "allies"],
      'sports_and_games': ["tennis", "cricket", "athlete", "match", "score", "striker", "referee", "medal", "field", "coach"],
      'geography_and_travel': ["valley", "desert", "island", "forest", "ocean", "border", "coast", "travel", "trip", "bridge"],
      'music_and_pop_culture': ["guitar", "rhythm", "melody", "lyrics", "tune", "chorus", "solo", "drums", "beats", "harmony"],
      'movies_and_tv_shows': ["cinema", "screen", "script", "acting", "camera", "director", "comedy", "scene", "ending", "actor"],
      'literature_and_books': ["novel", "story", "poetry", "verse", "fiction", "author", "chapter", "reader", "genre", "library"],
      'tech_and_creativity': ["robot", "design", "gadget", "device", "media", "logic", "graphic", "input", "output", "system"],
    },
    'medium': {
      'gk': ["constitution", "democracy", "election", "assembly", "republic", "citizen", "governance", "ballot", "policy", "reform"],
      'science_and_nature': ["photosynthesis", "gravity", "molecule", "reaction", "eclipse", "genetics", "ecosystem", "volcano", "climate", "experiment"],
      'history_and_politics': ["renaissance", "independence", "revolution", "treaty", "dynasty", "uprising", "military", "colony", "campaign", "conflict"],
      'sports_and_games': ["tournament", "championship", "olympics", "athletics", "competition", "equipment", "strategies", "ranking", "league", "finale"],
      'geography_and_travel': ["continent", "equator", "longitude", "hemisphere", "topography", "altitude", "itinerary", "latitude", "cartography", "glacier"],
      'music_and_pop_culture': ["symphony", "orchestra", "composer", "concert", "playlist", "grammy", "microphone", "festival", "genre", "harmonica"],
      'movies_and_tv_shows': ["blockbuster", "narrative", "animation", "cinematography", "sequel", "dialogue", "premiere", "villain", "musical", "genre"],
      'literature_and_books': ["manuscript", "bibliography", "metaphor", "protagonist", "plotline", "narrative", "context", "dialogue", "fable", "critique"],
      'tech_and_creativity': ["interface", "algorithm", "innovation", "prototype", "rendering", "virtual", "framework", "compiler", "databases", "protocol"],
    },
    'hard': {
      'gk': ["philosophy", "metaphysics", "anthropology", "epistemology", "existentialism", "sociology", "dialectics", "parliament", "jurisprudence", "pluralism"],
      'science_and_nature': ["electromagnetism", "neuroscience", "crystallography", "metabolism", "chromatography", "microbiology", "radiochemistry", "biomechanics", "quantum", "astronomy"],
      'history_and_politics': ["byzantine", "industrialization", "colonialism", "aristocracy", "imperialism", "federalism", "enlightenment", "sovereignty", "treatises", "inquisition"],
      'sports_and_games': ["triathlon", "gymnastics", "equestrian", "pentathlon", "freestyle", "decathlon", "synchronized", "badminton", "strategy", "precision"],
      'geography_and_travel': ["archipelago", "cartography", "topography", "geopolitics", "demography", "hydrology", "biogeography", "tectonic", "latitude", "terrain"],
      'music_and_pop_culture': ["counterpoint", "improvisation", "polyphony", "avantgarde", "concerto", "ethnomusicology", "pitchfork", "multitrack", "autotune", "synesthesia"],
      'movies_and_tv_shows': ["cinematography", "characterization", "adaptation", "screenwriting", "documentary", "foreshadowing", "postproduction", "anthology", "reminiscence", "subplot"],
      'literature_and_books': ["intertextuality", "bildungsroman", "postmodernism", "satirical", "monologue", "semantics", "dialectical", "persona", "allegory", "synecdoche"],
      'tech_and_creativity': ["cryptography", "machinelearning", "augmentedreality", "neuralnetworks", "computervision", "blockchain", "cybersecurity", "internetofthings", "quantumcomputing", "datamining"],
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
