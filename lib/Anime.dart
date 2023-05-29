import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Anime {
  final int id;
  final String name;
  final String imageUrl;
  final int episodes;
  final String synopsis;
  final int annee;
  final String studio;

  Anime({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.episodes,
    required this.synopsis,
    required this.annee,
    required this.studio,
  });
}

class AnimePage extends StatefulWidget {
  final int idMal;

  AnimePage({required this.idMal});

  @override
  _AnimePageState createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  late Future<Anime> _animeFuture;

  @override
  void initState() {
    super.initState();
    _animeFuture = _fetchAnimeData();
  }

  Future<Anime> _fetchAnimeData() async {
    final apiUrl = 'https://api.jikan.moe/v4/anime/${widget.idMal}/full';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body)['data'];
      final anime = Anime(
        id: jsonData['mal_id'] as int,
        name: jsonData['titles'][0]['title'] as String,
        imageUrl: jsonData['images']['jpg']['large_image_url'] as String,
        episodes: jsonData['episodes'] as int,
        synopsis: jsonData['synopsis'] as String,
        annee: jsonData['year'] as int,
        studio: jsonData['studios'][0]['name'] as String,
      );
      return anime;
    } else {
      throw Exception('Erreur ${widget.idMal}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails'),
      ),
      body: Center(
        child: FutureBuilder<Anime>(
          future: _animeFuture,
          builder: (BuildContext context, AsyncSnapshot<Anime> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text(
                'Erreur pendant le chargement',
                style: TextStyle(fontSize: 25),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              final anime = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Image.network(anime.imageUrl, height: 300),
                    SizedBox(height: 16),
                    Text(
                      anime.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Synopsis:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        anime.synopsis,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Autres informations :',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        // Action à effectuer lors du clic
                      },
                      child: ListTile(
                        title: Text('Episodes'),
                        subtitle: Text('${anime.episodes}'),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Action à effectuer lors du clic
                      },
                      child: ListTile(
                        title: Text('Année de sortie'),
                        subtitle: Text('${anime.annee}'),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Action à effectuer lors du clic
                      },
                      child: ListTile(
                        title: Text('Studio'),
                        subtitle: Text(anime.studio),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Text(
                'Pas de données trouvées',
                style: TextStyle(fontSize: 16),
              );
            }
          },
        ),
      ),
    );
  }
}
