import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practica_10_puntos/pages/preferences_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<String> imageUrls;
  late Map<String, dynamic> jsonData; // Define jsonData variable

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=fa3e844ce31744388e07fa47c7c5d8c3'));
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body); // Assign value to jsonData
        final List<dynamic> results = jsonData['results'];
        setState(() {
          imageUrls = results
              .map<String>((result) =>
                  'https://image.tmdb.org/t/p/w500${result['poster_path']}')
              .toList();
        });
      } else {
        throw Exception('Failed to load images');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching images: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Home Page",
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Pagina de login'),
              const SizedBox(
                  width: 20), // Add spacing between the title and IconButton
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreferencesPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (imageUrls == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        children: List.generate(imageUrls.length, (index) {
          // Extract movie information from jsonData
          Map<String, dynamic> movieData = jsonData['results'][index];
          String title = movieData['title'];
          String imageUrl =
              'https://image.tmdb.org/t/p/w500${movieData['poster_path']}';
          String overview = movieData['overview'];

          return Card(
            child: Center(
              // Center content vertically
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center content horizontally
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                      overflow:
                          TextOverflow.ellipsis, // Cut text if it overflows
                      maxLines: 1, // Limit to 1 line
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      overview,
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                      overflow:
                          TextOverflow.ellipsis, // Cut text if it overflows
                      maxLines: 3, // Limit to 3 lines
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    }
  }
}
