import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as dartpath;

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

  Future<int> insertData(String email, String name) async {
    Database db = await instance.database;
    return await db.insert('my_table', {'email': email, 'name': name});
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    Database db = await instance.database;
    return await db.query('my_table');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnilistV2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegisterPage(),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => new LoginPage(),
      },
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email, _password, _pseudo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 0.5,
                child: TextFormField(
                  validator: (input) {
                    if (input == null || input == '') {
                      return 'Veuillez entrer un email';
                    }
                    return null;
                  },
                  onSaved: (input) => _pseudo = input!,
                  decoration: InputDecoration(
                    labelText: 'Pseudo',
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: TextFormField(
                  validator: (input) {
                    if (input == null || input == '') {
                      return 'Veuillez entrer un email';
                    }
                    return null;
                  },
                  onSaved: (input) => _email = input!,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: TextFormField(
                  validator: (input) {
                    if (input == null || input.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                  onSaved: (input) => _password = input!,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: register,
                child: Text('S\'inscrire'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> register() async {
    final formState = _formKey.currentState;
    if (formState!.validate()) {
      formState.save();
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // L'utilisateur est inscrit avec succès
        print(userCredential.user);
        await DatabaseHelper.instance.insertData(_email, _pseudo);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => new LoginPage(),
          ),
        );
        // Naviguer vers la page de connexion ou effectuer une autre action souhaitée
      } catch (e) {
        // Une erreur s'est produite lors de l'inscription de l'utilisateur
        print(e);
      }
    }
  }
}
