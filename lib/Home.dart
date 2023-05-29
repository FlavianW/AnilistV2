import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as dartpath;
import 'package:http/http.dart' as http;
import 'Anime.dart';

class Anime {
  final int id;
  final String name;
  final String imageUrl;

  Anime({required this.id, required this.name, required this.imageUrl});
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = dartpath.join(databasesPath, 'my_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS my_table (
      email TEXT PRIMARY KEY,
      name TEXT
    )
  ''');
  }

  Future<String?> getPseudoByEmail(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      'my_table',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (results.isNotEmpty) {
      return results.first['name'] as String?;
    } else {
      return null;
    }
  }
}

Future<List<Anime>> _fetchAnimeData(String searchQuery) async {
  final encodedQuery = Uri.encodeQueryComponent(searchQuery.replaceAll(' ', '%20'));
  final apiUrl = 'https://api.jikan.moe/v4/anime?q=$encodedQuery&sfw';
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final animeList = (jsonData['data'] as List)
        .map((item) => Anime(
      id: item['mal_id'] as int,
      name: item['title'] as String,
      imageUrl: item['images']['jpg']['large_image_url'] as String,
    ))
        .toList();
    return animeList;
  } else {
    throw Exception('Erreur');
  }
}

void main() async {
  runApp(MyApp());
}

class HomePage extends StatefulWidget {
  final String userEmail;

  HomePage({required this.userEmail});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String?> _pseudoFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late Future<List<Anime>> _animeListFuture;
  bool _isNoAnimeFoundDialogDisplayed = false; // Suivre l'état de l'affichage du popup

  @override
  void initState() {
    super.initState();
    _pseudoFuture = _fetchPseudo();
    _animeListFuture = Future.value([]); // Initialisation avec une liste vide
  }

  Future<String?> _fetchPseudo() async {
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    return await databaseHelper.getPseudoByEmail(widget.userEmail);
  }

  void _searchAnime() {
    setState(() {
      _searchQuery = _searchController.text;
      _animeListFuture = _fetchAnimeData(_searchQuery);
    });
  }

  void _navigateToAnimeDetails(Anime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => new AnimePage(idMal: anime.id),
      ),
    );
  }

  void _showNoAnimeFoundDialog() {
    if (!_isNoAnimeFoundDialogDisplayed) {
      _isNoAnimeFoundDialogDisplayed = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Aucun animé trouvé'),
            content: Text('Aucun animé n\'a été trouvé pour votre recherche.'),
            actions: [
              TextButton(
                child: Text('Fermer'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _isNoAnimeFoundDialogDisplayed = false;
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Accueil'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            FutureBuilder<String?>(
              future: _pseudoFuture,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                    'Erreur lors du chargement du pseudo',
                    style: TextStyle(fontSize: 25),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  final pseudo = snapshot.data!;
                  return Column(
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Bonjour $pseudo',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 16)
                    ],
                  );
                } else {
                  return Text(
                    'Bienvenue',
                    style: TextStyle(fontSize: 16),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cherchez un animé',
              ),
            ),
            ElevatedButton(
              onPressed: _searchAnime,
              child: Text('Chercher'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Anime>>(
                future: _animeListFuture,
                builder: (BuildContext context, AsyncSnapshot<List<Anime>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      'Erreur lors du chargement des animes',
                      style: TextStyle(fontSize: 25),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final animeList = snapshot.data!;
                    if (animeList.isEmpty && _searchQuery.isNotEmpty) {

                      // Aucun anime trouvé
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        _showNoAnimeFoundDialog();
                      });
                      return Container(); // Retourne un conteneur vide pour éviter de construire le GridView
                    } else {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75, // Ajustez ce ratio selon vos besoins
                        ),
                        itemCount: animeList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              _navigateToAnimeDetails(animeList[index]);
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(animeList[index].imageUrl),
                                ),
                                SizedBox(height: 8),
                                Text(animeList[index].name),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  } else {
                    return Text(
                      'Aucun anime trouvé',
                      style: TextStyle(fontSize: 16),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimeDetailsPage extends StatelessWidget {
  final Anime anime;

  AnimeDetailsPage({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(anime.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(anime.imageUrl),
            SizedBox(height: 16),
            Text(
              anime.name,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnilistV2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(userEmail: ''),
      routes: <String, WidgetBuilder>{
        '/anime': (BuildContext context) => new AnimePage( idMal: 0,),
      },
    );
  }
}
